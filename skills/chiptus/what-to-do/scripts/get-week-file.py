#!/usr/bin/env python3
"""Prints the path to the current week's daily log file and today's heading."""
from datetime import date, timedelta

today = date.today()
days_since_sunday = today.weekday() + 1  # Mon=0 … Sat=5, Sun=6 → +1 wraps Sun to 0
if today.weekday() == 6:
    days_since_sunday = 0
sunday = today - timedelta(days=days_since_sunday)
saturday = sunday + timedelta(days=6)

rel_path = f"{sunday.strftime('%Y')}/{sunday.strftime('%Y-%m-%d')}_{saturday.day:02d}.md"
today_heading = today.strftime("%A, %B %-d")

print(rel_path)
print(today_heading)
