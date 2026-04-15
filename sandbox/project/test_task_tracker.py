"""Starter tests — the walkthrough will have you add more."""

import json
import tempfile
from pathlib import Path
from unittest import mock

import task_tracker


def test_add_task(tmp_path):
    with mock.patch.object(task_tracker, "TASKS_FILE", tmp_path / "tasks.json"):
        task = task_tracker.add_task("Buy groceries")
        assert task["id"] == 1
        assert task["title"] == "Buy groceries"
        assert task["done"] is False


def test_list_empty(tmp_path):
    with mock.patch.object(task_tracker, "TASKS_FILE", tmp_path / "tasks.json"):
        assert task_tracker.list_tasks() == []
