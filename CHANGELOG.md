# CHANGELOG.md

Release history for `ansible-roles`.
Documents notable changes across repository structure, roles, examples, and documentation.

## [v0.9.0]
### Added
- `roles/base_locale/`: New role for managing generated locales and system locale categories during the base phase on Debian-family hosts.
- `roles/base_locale/defaults/main.yml`: Added `base_locale_lang`, `base_locale_lc_all`, `base_locale_lc_time`, `base_locale_packages`, and `base_locale_present` defaults.
- `roles/base_locale/tasks/`: Added assert, install, config, and validate phase task files for Debian-family locale management.
- `roles/base_locale/README.md`: Added role documentation for locale management, `LC_TIME` usage, and direct usage.
- `examples/inventory/group_vars/all/base_locale.yml`: Added example locale variables for the Debian-family example lab.

### Changed
- `roles/base/meta/main.yml`: Added `base_locale` as a dependency of the `base` role with `base` and `base_locale` tags.
- `roles/base_packages/tasks/install.yml`: Switched package installation to `ansible.builtin.apt` with APT cache refresh.
- `roles/base_packages/tasks/config.yml`: Switched package removal to `ansible.builtin.apt`.
- `roles/base_packages/tasks/validate.yml`: Updated package validation to gather package facts with `manager: apt`.
- `roles/base_locale/tasks/install.yml`: Uses `ansible.builtin.apt` for locale package installation on Debian-family hosts.
- `roles/base_locale/tasks/assert.yml`: Tightened supported locale inputs to built-in locales plus Debian-style `ll_CC.CHARMAP` names.
- `roles/base_locale/tasks/config.yml`: Now fully manages `/etc/locale.gen`, runs `locale-gen` when the managed file changes, and keeps `localedef` only as a fallback for minimal/container environments.
- `roles/base_locale/tasks/validate.yml`: Now validates the full managed `/etc/locale.gen` content in addition to generated locale availability and configured locale categories.
- `roles/base_timezone/tasks/install.yml`: Uses `ansible.builtin.apt` for timezone package installation on Debian-family hosts.
- `README.md`: Added an explicit Debian-family support note and updated role descriptions to match current repository scope.
- `examples/README.md`: Documented the Debian-family scope of the example lab.
- `docs/01-examples.md`: Clarified that the example inventory and variables target Debian-family hosts.
- `docs/02-role-workflow.md`: Clarified that repository role implementations currently assume Debian-family behavior such as APT and Debian-family file locations.
- `roles/base/README.md`, `roles/bootstrap/README.md`, and `roles/base_timezone/README.md`: Updated wording to reflect Debian-family scope and current role behavior.

### Fixed
- `roles/base_locale/tasks/validate.yml`: Resolved register overwrite and invalid assert-option failures in locale validation.
- `roles/base_locale/tasks/config.yml` and `roles/base_locale/tasks/validate.yml`: Restored correct locale normalization logic after lint-driven refactoring so generated locale checks operate on real lists.
- `roles/base_locale/tasks/config.yml`: Replaced malformed or stale locale state by rewriting `/etc/locale.gen` to the requested canonical Debian entries during convergence.
- `roles/base_locale/tasks/`: Brought locale tasks into `yamllint` and `ansible-lint` compliance without changing intended behavior.

### Documentation
- Updated repository and role documentation to state that the repository currently targets Debian-family hosts such as Debian and Ubuntu.
- Documented 24-hour time configuration through `base_locale_lc_time` in the `base_locale` role README and example variables.
- Clarified in the `base_locale` role README that locale generation is driven by a fully managed `/etc/locale.gen` file and that supported locale names are built-ins plus `ll_CC.CHARMAP`.

## [v0.8.0]
### Added
- `roles/base_timezone/`: New role for enforcing the system timezone during the base phase.
- `roles/base_timezone/defaults/main.yml`: Added `base_timezone_packages` and `base_timezone_name` defaults for timezone management.
- `roles/base_timezone/tasks/`: Added assert, install, config, and validate phase task files for timezone management.
- `roles/base_timezone/README.md`: Added role documentation for timezone management and direct usage.
- `examples/inventory/group_vars/all/`: Split example shared variables into role-scoped files:
  - `bootstrap.yml`
  - `base_packages.yml`
  - `base_timezone.yml`

### Changed
- `roles/base/meta/main.yml`: Added `base_timezone` as a dependency of the `base` role with `base` and `base_timezone` tags.
- `roles/base/README.md`: Updated base role documentation to reflect the `base_timezone` dependency and inputs.
- `README.md`: Added `base_timezone` to the available roles list and aligned role descriptions.
- `examples/inventory/group_vars/`: Replaced the single `all.yml` file with a role-scoped `all/` directory for better readability.
- `roles/base_packages/tasks/validate.yml`: Consolidated package validation into one assertion for installed packages and one assertion for removed packages to reduce noisy per-item output.
- `roles/base_timezone/tasks/assert.yml`: Assert phase now validates timezone input only, leaving timezone-data verification to the install/validate flow.
- `roles/base_timezone/tasks/validate.yml`: Compact validate phase now checks zoneinfo presence and final timezone state with fewer tasks and avoids Jinja delimiters in assert conditions.

### Fixed
- Resolved `base_timezone` validation warning caused by Jinja templating delimiters inside `assert` conditions.
- Resolved `base_timezone` standalone failure path by making the role install its own timezone-data package instead of relying on `base_packages`.

### Documentation
- Updated `docs/02-role-workflow.md` with guidance for compact, low-noise roles that still keep the phase-based structure.
- Updated `examples/README.md` and `docs/01-examples.md` to document the split `group_vars/all/` directory layout.

## [v0.7.1]
### Changed
- Normalized file headers across tracked repository files to use a consistent path-first format followed by a short purpose description.
- Updated example files, role files, repository docs, and tracked dotfiles to use the same header style and wording for bootstrap-phase and base-phase concepts.
- Replaced older header variants such as generic titles, `# file:` comments, and `## File:` metadata blocks with the shared repository format.

### Documentation
- Expanded file-level explanations so each tracked document, playbook, config, defaults file, task file, and metadata file now states its repository path and purpose at the top.
- Clarified intentionally empty role entrypoints by documenting their purpose directly in:
  - `roles/monitoring/tasks/main.yml`
  - `roles/monitoring_authorized_key/tasks/install.yml`
- Added `docs/03-file-consistency.md` to define the repository-wide file header format, wording rules, and review checklist.

## [v0.7.0]
### Added
- `examples/playbooks/bootstrap.yml`: New bootstrap phase playbook to run initial provisioning with bootstrap inventory credentials.
- `examples/inventory/hosts.ini`: Added `[bootstrap:vars]` with dedicated bootstrap login/become variables used only by bootstrap phase.
- `roles/bootstrap/`: New standalone bootstrap role replacing the old `base_bootstrap` role path.
- `roles/bootstrap/defaults/main.yml`: Added `bootstrap_passwordless_sudo` (default `false`) and the new `bootstrap_*` defaults.
- `roles/bootstrap/tasks/config.yml`: Added task to optionally manage `/etc/sudoers.d/90-<user>` with `NOPASSWD` for the bootstrap-managed automation account.

### Changed
- `roles/base/meta/main.yml`: Removed the bootstrap dependency; `base` now only orchestrates recurring base roles such as `base_packages`.
- `roles/base/tasks/main.yml`: Kept as a placeholder task file while orchestration stays in meta dependencies.
- `examples/playbooks/bootstrap.yml`: Now runs the standalone `bootstrap` role with the `bootstrap` phase tag and prompts once for the bootstrap admin password, reusing it for both SSH login and sudo.
- `examples/playbooks/base.yml`: Simplified to run `base` only, with the `base` phase tag and no phase-switch variable.
- `examples/playbooks/site.yml`: Now imports only `base.yml`, leaving bootstrap as an explicit separate step instead of part of the default site flow.
- `examples/inventory/group_vars/all.yml`: Renamed bootstrap example variables from `base_bootstrap_*` to `bootstrap_*`.
- `examples/inventory/hosts.ini`: Removed example bootstrap password values so the inventory keeps only the bootstrap login user and relies on the playbook prompt for the shared password.
- `roles/bootstrap/tasks/config.yml`: User primary group assignment targets the ensured group by name.

### Fixed
- Corrected bootstrap connection precedence by using dedicated bootstrap variables from inventory in `examples/playbooks/bootstrap.yml` instead of relying on `remote_user` against `ansible_user` from `[all:vars]`.
- Resolved bootstrap failure path where `Group <gid> does not exist` by ensuring the primary group before user creation.
- Resolved example `Missing sudo password` follow-up by enabling optional passwordless sudo in bootstrap-managed account for the example flow.
- `roles/bootstrap/tasks/main.yml`: Phase tags are now `bootstrap`, `bootstrap_assert`, `bootstrap_config`, and `bootstrap_validate`.
- `examples/playbooks/bootstrap.yml`: Removed the duplicate SSH and sudo password prompts from the example bootstrap flow by using one shared prompted value.

### Documentation
- Updated docs and READMEs to match current example topology and execution flow:
  - `README.md`
  - `examples/README.md`
  - `docs/01-examples.md`
  - `roles/base/README.md`
  - `roles/bootstrap/README.md`
- Documented the example run order as an explicit two-step flow: run `examples/playbooks/bootstrap.yml` first, then run `examples/playbooks/site.yml` or `examples/playbooks/base.yml`.
- Updated example credential documentation to reflect that `examples/playbooks/bootstrap.yml` prompts once for the bootstrap password and reuses it for both SSH login and sudo.

### Removed
- `roles/base_bootstrap/`: Removed the old bootstrap role path after renaming it to the standalone `bootstrap` role.
- `base_run_bootstrap`: Removed the phase-switch variable from the example playbooks and bootstrap-related vars.

## [v0.6.0]
### Added
- `roles/base_packages/`: New role for managing common packages. Includes assert, install, config, and validate phase tasks.
- `roles/base/meta/main.yml`: Enabled base_packages role as a dependency of base.
- `examples/`: New directory for example lab files (inventory, group_vars, playbooks, ansible.cfg).
- `examples/README.md`: Documentation for example test lab usage and structure.
- `docs/01-examples.md`: Example lab documentation, replacing test lab setup.
- `docs/02-role-workflow.md`: Role workflow guide, including phase structure and note that not all phases are required.

### Changed
- Migrated test lab files from `tests/` to `examples/` for clarity and separation of tests vs examples.
- Removed `tests/inventory/group_vars/all.yml` (now in `examples/inventory/group_vars/all.yml`).
- Updated `roles/base_bootstrap/tasks/main.yml` to simplify tags and remove redundant prefixes.

## [v0.5.1]
### Changed
- `roles/base_bootstrap/tasks/main.yml`: Removed redundant `Base_bootstrap | ` prefix from imported task block names to avoid duplicated role name in Ansible output.
- `roles/base_bootstrap/tasks/validate.yml`: Consolidated `getent` lookups into a single looped task and merged all assertions into one task. Added authorized key presence check against the admin user's `authorized_keys` file.
- `roles/base_bootstrap/tasks/assert.yml`: Combined user/shell/uid/gid assertions into a single task for reduced output noise.
- `roles/base_bootstrap/tasks/config.yml`: No structural changes; aligned with updated task naming conventions.

## [v0.5.0]
### Refactored
- Refactored variable naming in all roles to use role-specific prefixes for ansible-lint compliance.
- Capitalized all task names for lint and readability.
- Fixed YAML syntax, indentation, and document start markers in all task files.
- Updated and added roles/monitoring_authorized_key/tasks/main.yml for new task structure and lint compliance.

### Changed
- Added granular phase-specific tags (`base_bootstrap_assert`, `base_bootstrap_config`, `base_bootstrap_validate`) to each imported task block in `roles/base_bootstrap/tasks/main.yml` for finer tag-based execution control.

### Fixed
- Corrected all `base_bootstrap` task variables in `assert.yml` from bare `bootstrap_*` / `user_shell` names to the proper `base_bootstrap_*` prefix.
- Prefixed all task names in `assert.yml`, `config.yml`, and `validate.yml` with their phase name (e.g. `assert |`, `config |`, `validate |`) for consistency.
- Fixed register variable collision in `validate.yml`: renamed `base_bootstrap_sudo_group` register to `base_bootstrap_sudo_group_check` to avoid shadowing the variable.
- Improved sudo group membership assertion in `validate.yml` to correctly parse the group members list (trim, reject empty, map).
- Updated `tests/inventory/group_vars/all.yml` to use `base_bootstrap_*` variable names and removed deprecated `base_bootstrap_enabled` and bare `bootstrap_*` variables.

## [v0.4.0]
### Added
- Added tests/README.md with documentation for new test files and structure.
- Created docs/01-test-lab.md for test lab setup documentation.

### Changed
- Renamed docs/01.md to docs/01-test-lab.md for clarity.

## [v0.3.2]
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

## [v0.3.1]
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
