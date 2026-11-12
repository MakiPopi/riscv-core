#!/usr/bin/env python3
"""Reads results/results.csv; writes figures and a summary table to results/."""
import csv
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

cyc, instret, pim_ops = {}, {}, {}
with open("results/results.csv") as f:
    for r in csv.DictReader(f):
        key = (r["benchmark"], int(r["cache"]), int(r["ideal_store"]), int(r["latency"]))
        cyc[key] = int(r["cycles"])
        instret[key] = int(r["instret"])
        pim_ops[key] = int(r["pim_ops"])
lats = sorted({k[3] for k in cyc})

def best(bench, ideal, lat):
    """Cycles of the faster of cache off / cache on."""
    return min(cyc[(bench, c, ideal, lat)] for c in (0, 1))

# scenario: (best CPU version, unit version)
PAIRS = {
    "copy": ("copy_unrolled", "pim_copy"),
    "and": ("and_unrolled", "pim_and"),
    "copy + sum, cold destination": ("cons_cpu", "cons_pim"),
    "copy + sum, hot destination": ("hot_cpu", "hot_pim"),
}

def speedup(name, ideal):
    cpu, pim = PAIRS[name]
    return [best(cpu, ideal, l) / best(pim, ideal, l) for l in lats]

def plot_speedup(names, title, fname):
    plt.figure(figsize=(7, 4.5))
    for name in names:
        line, = plt.plot(lats, speedup(name, 1), marker="o", label=name + " (ideal stores)")
        plt.plot(lats, speedup(name, 0), marker="x", linestyle="--",
                 color=line.get_color(), label=name + " (normal stores)")
    plt.axhline(1.0, color="black", linewidth=1)
    plt.xlabel("memory latency (cycles)")
    plt.ylabel("speedup of the memory-side unit\n(best CPU cycles / unit cycles)")
    plt.title(title)
    plt.grid(True, alpha=0.3)
    plt.legend(fontsize=8)
    plt.tight_layout()
    plt.savefig(fname, dpi=150)
    plt.close()

plot_speedup(["copy", "and"], "Row copy and AND: unit vs best CPU baseline",
             "results/speedup.png")
plot_speedup(["copy + sum, cold destination", "copy + sum, hot destination"],
             "When the CPU uses the result afterwards", "results/consumer.png")

# Break-even: the largest unit cost (cycles per row operation) that still ties the best CPU.
# The unit benchmarks have no other stalls, so cycles = instret + pim_ops * unit_cost.
def breakeven(cpu, pim):
    out = []
    for l in lats:
        k = (pim, 0, 1, l)
        out.append((best(cpu, 1, l) - instret[k]) / pim_ops[k])
    return out

plt.figure(figsize=(7, 4.5))
plt.plot(lats, breakeven("copy_unrolled", "pim_copy"), marker="o", label="copy: largest unit cost that still wins")
plt.plot(lats, breakeven("and_unrolled", "pim_and"), marker="s", linestyle="--", label="AND: largest unit cost that still wins")
plt.plot(lats, [2 * l + 32 for l in lats], color="black", linestyle=":", label="default unit cost (2L + 32)")
plt.xlabel("memory latency (cycles)")
plt.ylabel("unit cost per row operation (cycles)")
plt.title("Break-even unit cost against the best CPU baseline (ideal stores)")
plt.grid(True, alpha=0.3)
plt.legend(fontsize=8)
plt.tight_layout()
plt.savefig("results/breakeven.png", dpi=150)
plt.close()

# Summary table (ideal stores)
print("%-30s %5s %10s %8s %9s" % ("scenario", "L", "best CPU", "unit", "speedup"))
for name, (cpu, pim) in PAIRS.items():
    for l in (0, 10, 20, 50, 100):
        if l in lats:
            c, p = best(cpu, 1, l), best(pim, 1, l)
            print("%-30s %5d %10d %8d %8.2fx" % (name, l, c, p, c / p))
