#!/usr/bin/env bash
# Bootstrap the robot-code workspace.
# Run once after cloning this repo to clone all sibling repos and install
# the shared Python environment.
set -euo pipefail

REPOS=(
    "https://github.com/personalrobotics/asset_manager"
    "https://github.com/personalrobotics/geodude"
    "https://github.com/personalrobotics/geodude_assets"
    "https://github.com/personalrobotics/mj_environment"
    "https://github.com/personalrobotics/mj_manipulator"
    "https://github.com/personalrobotics/mj_manipulator_ros"
    "https://github.com/personalrobotics/mj_viser"
    "https://github.com/personalrobotics/prl_assets"
    "https://github.com/personalrobotics/pycbirrt"
    "https://github.com/personalrobotics/tsr"
)

# mujoco_menagerie is an external repo (not a Python package) needed by demos
MENAGERIE_URL="https://github.com/google-deepmind/mujoco_menagerie"

cd "$(dirname "$0")"

echo "==> Cloning repos..."
for url in "${REPOS[@]}"; do
    dir=$(basename "$url")
    if [ ! -d "$dir" ]; then
        echo "    cloning $dir"
        git clone "$url"
    else
        echo "    $dir already present, skipping"
    fi
done

echo ""
echo "==> Cloning mujoco_menagerie (robot models)..."
if [ ! -d "mujoco_menagerie" ]; then
    git clone "$MENAGERIE_URL"
else
    echo "    mujoco_menagerie already present, skipping"
fi

echo ""
echo "==> Removing stale per-package venvs (workspace uses shared root .venv)..."
# `uv run` inside a workspace member with its own .venv ignores the shared
# workspace venv, which is a common silent footgun. See robot-code#62.
shopt -s nullglob
for d in */.venv; do
    echo "    removing $d"
    rm -rf "$d"
done
shopt -u nullglob

echo ""
echo "==> Installing Python workspace (uv sync)..."
uv sync

echo ""
echo "Done. Verify with:"
echo "  uv run python mj_manipulator/demos/cartesian_control.py"
