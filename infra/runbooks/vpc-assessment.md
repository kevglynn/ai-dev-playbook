# VPC assessment runbook

How to **map a VPC from inside an EC2** (or any host) using the AWS CLI, document findings for agents, and capture security/cost signals.

## Goals

1. Know **who** you are (account, role, region).
2. Enumerate **VPCs, subnets, routing, gateways, endpoints**.
3. Map **instances** (and optionally ECS/Lambda) to roles and exposure.
4. Record **risks** (open SG rules, asymmetric routing, orphaned EIPs).
5. Write results into **`aws-infra.mdc`** (from `infra/templates/aws-infra.mdc.template`) on the instance — not in git.

## 1. Identity and permissions

```bash
aws sts get-caller-identity
aws configure list
echo "AWS_REGION=${AWS_REGION:-$(curl -s http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null || true)}"
```

Confirm the IAM role can run `ec2:Describe*`. If calls fail, fix IAM before spending time on mapping.

## 2. VPCs and main attributes

```bash
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0],IsDefault]' --output table
```

For each VPC of interest, note CIDR, whether it is default, and Name tag.

## 3. Subnets

```bash
VPC_ID=vpc-xxxxxxxx
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,MapPublicIpOnLaunch,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

## 4. Route tables

```bash
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'RouteTables[*].{RouteTableId:RouteTableId,Routes:Routes,Associations:Associations}' --output json
```

**Look for:**

- `0.0.0.0/0` → `igw-*` vs `nat-*` (public vs NAT egress).
- VPN / TGW routes (e.g. `10.x.0.0/16` → `vgw-*` or transit gateway).
- Asymmetric paths (subnet has public IP + default via NAT only) — document as a finding.

## 5. Internet / NAT / VPN gateways

```bash
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID"
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID"
aws ec2 describe-vpn-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID"
aws ec2 describe-customer-gateways
aws ec2 describe-vpn-connections
```

## 6. VPC endpoints

```bash
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'VpcEndpoints[*].[VpcEndpointId,VpcEndpointType,ServiceName,SubnetIds]' --output table
```

## 7. Security groups (spot-check)

```bash
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'SecurityGroups[*].[GroupId,GroupName,IpPermissions,IpPermissionsEgress]' --output json | less
```

Flag `0.0.0.0/0` on sensitive ports (22, RDP, app ports). Prefer EC2 Instance Connect + locked-down SGs over world-open SSH.

## 8. Instances in the VPC

```bash
aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,PrivateIpAddress,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

Correlate subnet + route table + public IP for each instance.

## 9. Cost / cleanup signals (optional)

- Stopped instances with volumes/EIPs.
- Unattached EIPs.
- Old snapshots without owner tag.

Use Cost Explorer / Trusted Advisor as a follow-up; CLI can list EIPs:

```bash
aws ec2 describe-addresses --query 'Addresses[*].[PublicIp,AllocationId,InstanceId,NetworkInterfaceId]' --output table
```

## 10. Document in `aws-infra.mdc`

Use `infra/templates/aws-infra.mdc.template`:

- Account, region, IAM role summary.
- One section per VPC (or primary + notable secondary).
- Tables for subnets and instances.
- VPN / endpoints / routing quirks.
- Security notes and open investigations (bead IDs).

Deploy with `install-agent-tools.sh --context-dir ...` so agents get the rule in Cursor.
