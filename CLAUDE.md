# CLAUDE.md

This file provides guidance for AI assistants working in this repository.

## Project Overview

**legendary-fortnight** is a DevOps/infrastructure project for packaging and distributing a reproducible Python 3.13 data science and GUI environment using Conda/Micromamba. The packaged environment is distributed via Git LFS as a compressed tarball.

This repository contains **no application source code** — it is a configuration and tooling project.

## Repository Structure

```
legendary-fortnight/
├── .github/                    # GitHub configuration (no CI/CD workflows)
├── .vscode/
│   └── settings.json          # VS Code Python interpreter configuration
├── scripts/
│   └── package_and_push.sh    # Environment packaging and Git push script
├── .gitattributes              # Git LFS config — routes *.tar.gz through LFS
├── .gitignore                  # Ignores rm_env/, .mamba/, bin/, *.log
├── devfile.yaml                # Red Hat Devfile 2.2.0 — dev container definition
├── environment.yml             # Conda environment spec (Python 3.13, 144 deps)
└── README.md                   # Minimal project title
```

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Container Standard | Red Hat Devfile 2.2.0 |
| Base Image | `registry.access.redhat.com/ubi8/python-39` |
| Package Manager | Micromamba (Conda-compatible) |
| Python Version | 3.13.5 |
| Scientific Stack | NumPy, SciPy, Pandas, Matplotlib |
| GUI Framework | PySide6 6.9.1 (Qt6 bindings) |
| Data I/O | OpenPyXL, XlsxWriter |
| DB Client | libpq 17.6 (PostgreSQL) |
| Distribution | Git + Git LFS (for `*.tar.gz`) |

## Key Files

### `devfile.yaml`
Defines the development container using the Devfile 2.2.0 specification. Contains a single component (`python-builder`) with an 8 GB memory limit and a single `full-environment-build` command that:
1. Downloads Micromamba to `/projects/bin/`
2. Creates the Conda environment at `/projects/rm_env` from `environment.yml`
3. Installs `conda-pack` for environment packaging

### `environment.yml`
Specifies the complete `rm_env` Conda environment:
- Channels: `conda-forge`, `defaults`
- 144 pinned packages including system-level X11/Wayland/ALSA libraries for Qt6 GUI support
- All versions are fully pinned to ensure reproducibility

### `scripts/package_and_push.sh`
Packs the environment and publishes it:
```bash
conda-pack -p /projects/rm_env -o rm_env_packed.tar.gz --ignore-missing-files
git add rm_env_packed.tar.gz
git commit -m "Update packed environment <timestamp>"
git push origin main
```
The resulting `rm_env_packed.tar.gz` is stored via Git LFS.

## Development Workflow

### Building the Environment (via DevFile)
This is executed inside a Devfile-compatible runner (e.g., OpenShift Dev Spaces, odo):
```bash
# The devfile.yaml command handles the full build:
# 1. Install micromamba
# 2. micromamba create -y -p /projects/rm_env -f /projects/environment.yml
# 3. micromamba run -p /projects/rm_env pip install conda-pack
```

### Updating Dependencies
1. Edit `environment.yml` with new/changed package versions.
2. Rebuild the environment in the dev container.
3. Run `scripts/package_and_push.sh` to repackage and publish.

### Packaging and Releasing
```bash
cd /projects
bash scripts/package_and_push.sh
```
This creates `rm_env_packed.tar.gz` (tracked by Git LFS) and pushes it to the remote.

## Git Conventions

- `*.tar.gz` files are handled by **Git LFS** — do not attempt to commit them as regular files.
- The `.gitignore` excludes the unpacked environment directories (`rm_env/`, `.mamba/`, `bin/`) and log files — never commit these.
- Commit messages in the project history use short imperative descriptions.
- The primary working branch is `main`; feature/task branches follow the pattern `claude/<description>-<id>`.

## Environment Variables & System Requirements

| Requirement | Details |
|-------------|---------|
| OS | Linux x86_64 |
| RAM | 8 GB minimum (container memory limit) |
| Container Runtime | Docker or Podman (for Devfile execution) |
| Git LFS | Required to push/pull `*.tar.gz` artifacts |
| Network | Access to `micro.mamba.pm`, `conda-forge`, `defaults` channels |

## No Testing Framework

This repository has no automated tests, no CI/CD pipelines, and no linting configuration. When adding new scripts or configuration, validate manually inside the dev container.

## What AI Assistants Should Know

- **Do not add application source code** unless explicitly requested; this is an infrastructure/config project.
- **Do not modify pinned versions** in `environment.yml` without explicit instruction — reproducibility is the point.
- **Do not commit large files** (built environments, tarballs) as regular git objects; they belong in Git LFS.
- **`/projects/rm_env/`** is the runtime environment directory — it is gitignored and should never be committed.
- The `scripts/package_and_push.sh` script targets `origin main`; verify the remote before running.
- When editing `devfile.yaml`, conform to the [Devfile 2.2.0 specification](https://devfile.io/docs/2.2.0/devfile-schema).
