# robot-code

Workspace for MuJoCo-based robot manipulation research.
Contains a curated set of focused libraries that compose into a full manipulation stack.

## Stack

| Package | Repo | What it does |
|---------|------|--------------|
| `mj_environment` | [personalrobotics/mj_environment](https://github.com/personalrobotics/mj_environment) | MuJoCo environment wrapper |
| `mj_manipulator` | [siddhss5/mj_manipulator](https://github.com/siddhss5/mj_manipulator) | Generic arm control: planning, execution, Cartesian control, grasping |
| `pycbirrt` | [siddhss5/pycbirrt](https://github.com/siddhss5/pycbirrt) | CBiRRT motion planner with TSR constraints |
| `tsr` | [personalrobotics/tsr](https://github.com/personalrobotics/tsr) | Task Space Regions for grasp/place planning |
| `asset_manager` | [personalrobotics/asset_manager](https://github.com/personalrobotics/asset_manager) | Loads objects from `meta.yaml` files |
| `prl_assets` | [personalrobotics/prl_assets](https://github.com/personalrobotics/prl_assets) | Reusable MuJoCo objects (cans, bins, ...) |
| `geodude_assets` | [personalrobotics/geodude_assets](https://github.com/personalrobotics/geodude_assets) | MuJoCo models for Geodude (UR5e + Robotiq) |
| `geodude` | [siddhss5/geodude](https://github.com/siddhss5/geodude) | Full robot stack for the Geodude platform |

Robot base models (UR5e, Franka Panda) come from
[google-deepmind/mujoco_menagerie](https://github.com/google-deepmind/mujoco_menagerie),
cloned by `setup.sh`.

## Quick Start

```bash
git clone https://github.com/siddhss5/robot-code
cd robot-code
./setup.sh
```

`setup.sh` clones any missing repos, clones `mujoco_menagerie`, and runs `uv sync` to
install the shared Python environment. Repos you already have are left untouched.

Then verify the stack end-to-end:

```bash
uv run python mj_manipulator/demos/cartesian_control.py
uv run mjpython mj_manipulator/demos/recycling.py --robot ur5e --headless
```

## Using Individual Packages

Each package is independently installable:

```bash
uv add mj-manipulator @ git+https://github.com/siddhss5/mj_manipulator
```

See each package's own README for its standalone API.

## Workspace Layout

All repos live as siblings inside `robot-code/`:

```
robot-code/
├── asset_manager/
├── geodude/
├── geodude_assets/
├── mj_environment/
├── mj_manipulator/
├── mujoco_menagerie/      ← cloned by setup.sh, not a Python package
├── prl_assets/
├── pycbirrt/
├── tsr/
├── pyproject.toml         ← uv workspace root (this file)
└── setup.sh
```

The shared `.venv` at the workspace root is used by all packages.
Each package's `[tool.uv.sources]` table points to its siblings as editable installs,
so changes in any package are immediately visible to all others.

## Development

```bash
# Run tests for a specific package
uv run pytest mj_manipulator/tests/ -v

# Run tests across the whole workspace
uv run pytest */tests/ -v
```
