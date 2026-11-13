"""Render the bin and measure it and its engraved label.

usage: python3 tests/test_wall_bin.py [OPENSCAD]

Each bin renders with --hardwarnings. A binary STL's separate solids are
counted (triangles sharing a vertex belong to the same solid), and sizes are
checked to within 0.01 mm. tests/label_probe.scad imports a rendered bin and
shows where it isn't inside the engraving, so its size is the label's.

The label widths hold for Arial Bold and Liberation Sans Bold, which share
metrics; on a system with neither, OpenSCAD substitutes another font without
a warning, so the script stops first if fc-match finds neither.
"""

import os
import struct
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BIN = os.path.join(ROOT, "variable_wall_bin.scad")
PROBE = os.path.join(ROOT, "tests", "label_probe.scad")
LONG = "Soldering Supplies and Spare Tips"  # 285 mm at the default size


def measure(path):
    data = open(path, "rb").read()
    (n,) = struct.unpack_from("<I", data, 80)
    parent = {}

    def find(v):
        while parent[v] != v:
            parent[v] = parent[parent[v]]
            v = parent[v]
        return v

    for i in range(n):
        v = struct.unpack_from("<9f", data, 84 + i * 50 + 12)
        corners = [v[0:3], v[3:6], v[6:9]]
        for c in corners:
            parent.setdefault(c, c)
        root = find(corners[0])
        for c in corners[1:]:
            parent[find(c)] = root
    solids = len({find(v) for v in parent})
    size = [max(p[i] for p in parent) - min(p[i] for p in parent) for i in range(3)]
    return solids, size


def run(openscad, scad, out, defines):
    cmd = [openscad, "--hardwarnings", "--export-format", "binstl", "-o", out]
    for name, value in defines.items():
        cmd += ["-D", f"{name}={value}"]
    result = subprocess.run(cmd + [scad], capture_output=True, text=True)
    if result.returncode != 0:
        errors = [l for l in result.stderr.splitlines() if "WARNING" in l or "ERROR" in l]
        raise RuntimeError(f"openscad exited {result.returncode}: {'; '.join(errors)}")
    return measure(out)


# (label, bin defines, bin size, engraved label width)
CASES = [
    ("defaults", {}, (200, 70, 125), 122.32),
    ("long label, fitted", {"text_string": f'"{LONG}"'}, (200, 70, 125), 180),
    # Unfitted, the label runs past both ends of the probe, which stops at the
    # walls: 200 - 2 x 3.
    ("long label, not fitted", {"text_string": f'"{LONG}"', "label_max_width": 0}, (200, 70, 125), 194),
    ("long label, 300 mm bin", {"text_string": f'"{LONG}"', "box_length": 300}, (300, 70, 125), 280),
    ("120 x 50 x 60 bin", {"box_length": 120, "box_width": 50, "box_height": 60}, (120, 50, 85), 100),
]


def main():
    openscad = sys.argv[1] if len(sys.argv) > 1 else "openscad"
    font = subprocess.run(["fc-match", "-f", "%{family}", "Arial:style=Bold"], capture_output=True, text=True)
    if not any(name in font.stdout for name in ("Arial", "Liberation Sans")):
        sys.exit(f"Arial Bold resolves to {font.stdout!r}, not Arial or Liberation Sans; "
                 "the label widths depend on it.")

    failures = []
    with tempfile.TemporaryDirectory() as tmp:
        bin_stl = os.path.join(tmp, "bin.stl")
        label_stl = os.path.join(tmp, "label.stl")
        for label, defines, want_bin, want_label in CASES:
            probe = {"BIN": f'"{bin_stl}"'}
            for name in ("box_length", "box_width", "box_height"):
                if name in defines:
                    probe[name] = defines[name]
            try:
                solids, size = run(openscad, BIN, bin_stl, defines)
                _, label_size = run(openscad, PROBE, label_stl, probe)
            except RuntimeError as error:
                failures.append(label)
                print(f"FAIL {label}: {error}")
                continue
            ok = (solids == 1 and all(abs(a - b) <= 0.01 for a, b in zip(size, want_bin))
                  and abs(label_size[0] - want_label) <= 0.01)
            got = (f"bin {solids} solids, {' x '.join(f'{s:.2f}' for s in size)} mm; "
                   f"label {label_size[0]:.2f} mm wide")
            if not ok:
                failures.append(label)
                got += f"; expected 1 solid, {' x '.join(f'{s:.2f}' for s in want_bin)} mm, label {want_label:.2f}"
            print(f"{'ok  ' if ok else 'FAIL'} {label}: {got}")
    print("all checks passed" if not failures else f"{len(failures)} failed")
    sys.exit(1 if failures else 0)


main()
