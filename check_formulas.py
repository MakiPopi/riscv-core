#!/usr/bin/env python3
"""Checks the hand-derived cycle formulas against every ideal-store row of results/results.csv.
cycles = a + b * L, where L is the memory latency."""
import csv

FORMULAS = {   # (benchmark, cache on?): (a, b)
    ("copy_unrolled", 0): (66, 32),  ("copy_unrolled", 1): (90, 8),
    ("pim_copy", 0): (35, 2),        ("pim_copy", 1): (35, 2),
    ("and_unrolled", 0): (131, 64),  ("and_unrolled", 1): (179, 16),
    ("pim_and", 0): (69, 4),         ("pim_and", 1): (69, 4),
    ("cons_cpu", 0): (131, 64),      ("cons_cpu", 1): (179, 16),
    ("cons_pim", 0): (100, 34),      ("cons_pim", 1): (124, 10),
    ("hot_cpu", 0): (196, 96),       ("hot_cpu", 1): (244, 16),
    ("hot_pim", 0): (165, 66),       ("hot_pim", 1): (213, 18),
}

checked = bad = 0
with open("results/results.csv") as f:
    for r in csv.DictReader(f):
        key = (r["benchmark"], int(r["cache"]))
        if r["ideal_store"] != "1" or key not in FORMULAS:
            continue
        a, b = FORMULAS[key]
        want = a + b * int(r["latency"])
        checked += 1
        if int(r["cycles"]) != want:
            bad += 1
            print("MISMATCH", r["benchmark"], "cache", r["cache"], "L", r["latency"],
                  "csv", r["cycles"], "formula", want)
print(checked, "rows checked,", bad, "mismatches")
