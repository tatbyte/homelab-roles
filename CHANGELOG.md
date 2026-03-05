# Changelog

All notable changes to this project will be documented in this file.

## [v0.4.0]
### Added
- Added tests/README.md with documentation for new test files and structure.
- Created docs/01-test-lab.md for test lab setup documentation.

### Changed
- Renamed docs/01.md to docs/01-test-lab.md for clarity.

## [v0.3.2] - 2026-03-04
### Added
- Documentation for pre-commit installation, usage, and linting setup for all roles (`docs/00-pre-commit.mb`).
- Added troubleshooting/common failure guidance for local pre-commit environments (cache permissions, missing `ansible-lint`, hook bootstrap issues).

### Changed
- Updated `.pre-commit-config.yaml` for a roles-only repo:
  - Added `minimum_pre_commit_version` and default hook install types (`pre-commit`, `pre-push`).
  - Added `meta` self-check hooks (`check-hooks-apply`, `check-useless-excludes`).
  - Added safety hooks (`check-case-conflict`, `detect-private-key`).
  - Simplified ansible-lint trigger to YAML files only.
- Updated root `README.md` pre-commit section and quick start instructions for accuracy.

### Removed
- Removed root `ansible.cfg` (not required for this roles-only repository).

### Merged
- Merged PR #11: Enhance pre-commit setup, clean up ansible-lint configuration, and add documentation for installation and usage.

## [v0.3.1] - 2026-03-02
### Added
- `.pre-commit-config.yaml`: Added and refined pre-commit configuration for linting and hygiene (trailing whitespace, EOF, merge conflicts, YAML validation, yamllint, ansible-lint).
- Pre-commit now uses relaxed yamllint rules for Ansible YAML conventions.

### Changed
- Updated `base_bootstrap/tasks/config.yml`, `_common/vars/task_flow.yml`, and `monitoring/authorized_key/tasks/configure.yml` for ansible-lint compliance (canonical FQCNs, truthy values, YAML formatting).
- Cleaned up `.pre-commit-config.yaml` to remove broken requirements.yml hook and duplicate keys.

### Fixed
- All pre-commit hooks now pass successfully after configuration and code fixes.

## [v0.3.0] - 2026-03-02
### Added
- `base/meta/main.yml`: Declared `base_bootstrap` as a dependency for the `base` role, with tags for orchestration.
- `base/tasks/main.yml`: Placeholder for future base role tasks.
- `base_bootstrap/tasks/config.yml`: Now always ensures the admin user exists and is in the correct group, regardless of prior existence.

### Changed
- `_common/tasks/task_flow.yml`:
	- Improved path resolution for shared vars.
	- Pre-check for phase task files now runs on localhost without privilege escalation, ensuring correct detection and avoiding sudo errors.
	- Added `become_user` and `run_once` for robust local checks.
	- Fixed tag application logic for included phase tasks.
- `base_bootstrap/defaults/main.yml`: Added `bootstrap_sudo_group` default variable.
- `base_bootstrap/tasks/main.yml`: Updated to use the correct include path and streamlined variables for the task flow.
- `base_bootstrap/tasks/validate.yml`: Now dynamically checks group membership using the `bootstrap_sudo_group` variable.

## [v0.2.0]
### Added
- Introduced `_common` role directory with shared `tasks/task_flow.yml` orchestrator for consistent role execution flow (assert, install, configure, validate).
### Changed
- Added `base_bootstrap` role tag variable (`_role_tag: base_bootstrap`) to orchestrated task flow.

## [v0.1.0] - 2026-02-27
### Added
- Project-wide README at root with usage, features, and contribution guidelines
- `_common/README.md` explaining the shared task flow orchestrator
- Role: `monitoring/authorized_key` for inter-host SSH key management
- Test playbook for `monitoring/authorized_key` in `homelab/ansible/playbooks/tests/monitoring/00-authorized_key.yml`

### Changed
- All roles now use the shared `_common/tasks/task_flow.yml` orchestrator (assert → install → configure → validate)
- Improved variable validation and post-deployment checks in all roles
- Consistent task naming and file structure across roles

### Fixed
- Corrected shell index and variable references in `base/bootstrap` validation tasks

### Added
- Initial split of roles into dedicated repository
- Role: `base/bootstrap` for admin user and SSH key setup
- Shared `_common/tasks/task_flow.yml` orchestrator
