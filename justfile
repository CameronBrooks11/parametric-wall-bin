default:
    @just --list

# Render bins with short and long labels, and check the bin and label sizes
test:
    python3 tests/test_wall_bin.py

# Render the README picture into assets/
images:
    @mkdir -p assets
    openscad --render --camera=0,0,0,55,0,15,520 --viewall --autocenter --imgsize=700,450 --colorscheme=Tomorrow -o assets/wall-bin.png variable_wall_bin.scad
