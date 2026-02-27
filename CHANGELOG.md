# Changelog

All notable changes to this project will be documented in this file.

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
