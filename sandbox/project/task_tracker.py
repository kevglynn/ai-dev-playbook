"""
Minimal task tracker — the sandbox project for learning the playbook workflow.

This is intentionally simple. The exercise is about the *process* (beads,
Planner/Executor, scratchpad, evidence), not the code.
"""

import json
from pathlib import Path

TASKS_FILE = Path(__file__).parent / "tasks.json"


def load_tasks() -> list[dict]:
    if TASKS_FILE.exists():
        return json.loads(TASKS_FILE.read_text())
    return []


def save_tasks(tasks: list[dict]) -> None:
    TASKS_FILE.write_text(json.dumps(tasks, indent=2))


def add_task(title: str) -> dict:
    tasks = load_tasks()
    task = {"id": len(tasks) + 1, "title": title, "done": False}
    tasks.append(task)
    save_tasks(tasks)
    return task


def complete_task(task_id: int) -> dict | None:
    tasks = load_tasks()
    for task in tasks:
        if task["id"] == task_id:
            task["done"] = True
            save_tasks(tasks)
            return task
    return None


def list_tasks(show_done: bool = True) -> list[dict]:
    tasks = load_tasks()
    if not show_done:
        return [t for t in tasks if not t["done"]]
    return tasks


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python task_tracker.py [add|done|list] [args]")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "add" and len(sys.argv) > 2:
        task = add_task(" ".join(sys.argv[2:]))
        print(f"Added: #{task['id']} {task['title']}")

    elif cmd == "done" and len(sys.argv) > 2:
        result = complete_task(int(sys.argv[2]))
        if result:
            print(f"Done: #{result['id']} {result['title']}")
        else:
            print(f"Task #{sys.argv[2]} not found")

    elif cmd == "list":
        for task in list_tasks():
            status = "✓" if task["done"] else " "
            print(f"  [{status}] #{task['id']} {task['title']}")

    else:
        print("Unknown command. Use: add, done, list")
