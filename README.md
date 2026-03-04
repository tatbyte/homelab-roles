# ansible-roles

Reusable Ansible roles for homelab, infrastructure, and server automation.

## Overview
This repository contains modular, production-ready Ansible roles designed for use in homelab and cloud environments. Roles are structured for easy reuse, testing, and integration with other projects via Ansible Galaxy or as a git submodule.

## Features
- Strict input validation and post-deployment checks
- Shared task flow orchestrator for consistency (`_common`)
- Roles for user/bootstrap, monitoring/authorized_key, and more
- Designed for idempotency and safe re-runs

## Usage
1. Add this repository to your `requirements.yml`:
   ```yaml
   - src: https://github.com/tatbyte/ansible-roles.git
     version: main
     name: base
   ```
2. Install roles:
   ```sh
   ansible-galaxy install -r requirements.yml -p roles/
   ```
3. Reference roles in your playbooks:
   ```yaml
   - hosts: all
     roles:
       - base/bootstrap
       - monitoring/authorized_key
   ```

## Linting and Pre-commit
This repository uses [pre-commit](https://pre-commit.com/) to enforce code quality and linting for YAML and Ansible files.

- See [docs/00-pre-commit.mb](docs/00-pre-commit.mb) for setup, installation, and usage instructions.
- The `.pre-commit-config.yaml` applies repository-wide, so future roles/files are checked automatically.
- Hooks include formatting/safety checks, YAML validation, yamllint, and ansible-lint.
- Git hooks are installed for both commit and push (`pre-commit` + `pre-push`).

### Quick Start
1. Install pre-commit (recommended via pipx):
   ```sh
   pip install pipx
   pipx install pre-commit
   pipx install ansible-lint
   pre-commit install
   ```
2. Run all hooks manually:
   ```sh
   pre-commit run --all-files
   ```

## Development
- See `_common/README.md` for the shared task flow pattern.
- Each role contains its own README with usage and variable documentation.
- Test roles using the provided playbooks in your consuming project.

## Contributing
PRs and issues are welcome! Please follow the established role/task structure and add tests for new features.

## License
MIT
