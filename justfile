default:
    @just --list

# Render bins with short and long labels, and check the bin and label sizes
test:
    python3 tests/test_wall_bin.py

# Everything CI runs, bar the tests
check: fmt-check

# Format the .scad sources with topiary (.topiary/languages.ncl)
fmt:
    git ls-files -z '*.scad' | xargs -0 -r topiary format

# Check the .scad sources are formatted, without changing them
fmt-check:
    git ls-files -z '*.scad' | xargs -0 -r -n1 topiary format --check

# Render the README picture into assets/
images:
    @mkdir -p assets
    openscad --render --camera=0,0,0,55,0,15,520 --viewall --autocenter --imgsize=700,450 --colorscheme=Tomorrow -o assets/wall-bin.png variable_wall_bin.scad
