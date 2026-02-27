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

## Development
- See `_common/README.md` for the shared task flow pattern.
- Each role contains its own README with usage and variable documentation.
- Test roles using the provided playbooks in your consuming project.

## Contributing
PRs and issues are welcome! Please follow the established role/task structure and add tests for new features.

## License
MIT
