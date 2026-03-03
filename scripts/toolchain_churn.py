#!/usr/bin/env python3
"""
Estimate nixpkgs unstable toolchain rebuild cadence from a local git checkout.

Usage:
  python3 scripts/toolchain_churn.py /path/to/nixpkgs [--since YYYY-MM-DD] [--branch BRANCH]

Notes:
- Offline only: this script reads local git history and does not fetch.
- It counts commits touching toolchain-critical paths and reports events/week
  plus median days between events.
- Output is intentionally plain text and stable for CI/log parsing.
"""

from __future__ import annotations

import argparse
import datetime as dt
import statistics
import subprocess
import sys
from pathlib import Path

DEFAULT_PATHS = [
    "pkgs/stdenv",
    "pkgs/build-support/cc-wrapper",
    "pkgs/development/compilers/gcc",
    "pkgs/development/compilers/llvm",
    "pkgs/development/libraries/glibc",
    "pkgs/development/tools/misc/binutils",
    "pkgs/os-specific/linux/kernel-headers",
]


def run_git(repo: Path, args: list[str]) -> str:
    cmd = ["git", "-C", str(repo), *args]
    out = subprocess.run(cmd, check=True, capture_output=True, text=True)
    return out.stdout


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Estimate nixpkgs toolchain churn")
    p.add_argument("repo", type=Path, help="Local nixpkgs git checkout")
    p.add_argument(
        "--since",
        default="2024-01-01",
        help="Lower date bound (inclusive), format YYYY-MM-DD (default: 2024-01-01)",
    )
    p.add_argument(
        "--branch",
        default="origin/nixos-unstable",
        help="Branch/ref to inspect (default: origin/nixos-unstable)",
    )
    return p.parse_args()


def main() -> int:
    ns = parse_args()
    repo = ns.repo
    if not repo.exists():
        print(f"error: repo path does not exist: {repo}")
        return 2

    try:
        since = dt.datetime.strptime(ns.since, "%Y-%m-%d").date()
    except ValueError:
        print("error: --since must be YYYY-MM-DD")
        return 2

    try:
        raw = run_git(
            repo,
            [
                "log",
                "--date=short",
                "--pretty=format:%H\t%ad",
                f"--since={ns.since}",
                ns.branch,
                "--",
                *DEFAULT_PATHS,
            ],
        )
    except subprocess.CalledProcessError as e:
        print("error: failed to read git history")
        if e.stderr:
            print(e.stderr.strip())
        return 2

    rows = [line for line in raw.splitlines() if line.strip()]
    events: list[tuple[str, dt.date]] = []
    for row in rows:
        commit, day = row.split("\t", 1)
        events.append((commit, dt.datetime.strptime(day, "%Y-%m-%d").date()))

    today = dt.date.today()
    span_days = max(1, (today - since).days)
    span_weeks = span_days / 7.0

    print("nixpkgs toolchain churn estimate")
    print(f"repo: {repo}")
    print(f"ref: {ns.branch}")
    print(f"since: {since.isoformat()}")
    print("paths:")
    for p in DEFAULT_PATHS:
        print(f"  - {p}")

    print(f"events: {len(events)}")
    print(f"events_per_week: {len(events) / span_weeks:.2f}")

    if len(events) >= 2:
        chron = sorted(events, key=lambda x: x[1])
        gaps = [(chron[i][1] - chron[i - 1][1]).days for i in range(1, len(chron))]
        med = statistics.median(gaps)
        print(f"median_days_between_events: {med:.1f}")
    else:
        print("median_days_between_events: n/a")

    if events:
        latest_hash, latest_day = max(events, key=lambda x: x[1])
        print(f"latest_event: {latest_day.isoformat()} {latest_hash}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
