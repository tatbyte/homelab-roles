# CHANGELOG.md

Release history for `ansible-roles`.
Documents notable changes across repository structure, roles, examples, and documentation.

## [v0.15.0]
### Added
- `roles/base_firewall/`: New role for enforcing a UFW baseline during the base phase.
- `roles/base_firewall/defaults/main.yml`: Added `base_firewall_packages`, `base_firewall_enabled`, `base_firewall_logging`, `base_firewall_default_incoming_policy`, `base_firewall_default_outgoing_policy`, `base_firewall_state_checksum_path`, and `base_firewall_rules` defaults.
- `roles/base_firewall/tasks/`: Added assert, install, config, and validate phase task files for Debian-family UFW management.
- `roles/base_firewall/README.md`: Added role documentation for firewall management and direct usage.
- `examples/inventory/group_vars/all/base_firewall.yml`: Added example firewall variables for the Debian-family example lab.
- `roles/base/defaults/main.yml`: Added `base_include_firewall` so the aggregate base role can opt in to firewall management without changing existing hosts by default.

### Changed
- `roles/base/tasks/main.yml`: Optionally includes `base_firewall` only when `base_include_firewall` is true, so existing aggregate base runs do not start enforcing a firewall unexpectedly.
- `roles/base/meta/main.yml` and `roles/base/README.md`: Restored the aggregate base dependency order to the existing always-on roles and documented `base_firewall` as an explicit opt-in follow-up role.
- `roles/base_firewall/tasks/assert.yml`: Added a safety check that refuses to enable a deny-or-reject incoming firewall policy unless the managed rules still allow SSH or Ansible access on the management port.
- `roles/base_firewall/tasks/config.yml` and `roles/base_firewall/tasks/validate.yml`: Added checksum-based convergent reapply behavior so managed rule or comment changes reset and rebuild the stored UFW state instead of leaving stale rules behind.
- `README.md`: Added `base_firewall` to the available roles list and clarified that the aggregate `base` role includes it only as an explicit opt-in follow-up.
- `examples/README.md`, `docs/01-examples.md`, and `examples/inventory/group_vars/all/base_firewall.yml`: Updated the example documentation and variables to include the new firewall role file plus the aggregate opt-in variable.
- `docs/02-role-workflow.md`: Updated the documented aggregate base-role order so `base_firewall` is described as an optional current follow-up instead of a default dependency.

## [v0.14.0]
### Added
- `roles/base_sshd/`: New role for enforcing an SSH daemon baseline during the base phase.
- `roles/base_sshd/defaults/main.yml`: Added `base_sshd_packages`, `base_sshd_service_name`, `base_sshd_port`, `base_sshd_permit_root_login`, `base_sshd_password_authentication`, `base_sshd_pubkey_authentication`, and `base_sshd_allow_users` defaults.
- `roles/base_sshd/tasks/`: Added assert, install, config, and validate phase task files for Debian-family SSH daemon management.
- `roles/base_sshd/handlers/main.yml`: Added a handler that restarts the managed SSH service after drop-in changes.
- `roles/base_sshd/templates/sshd_base.conf.j2`: Added a template for the managed `/etc/ssh/sshd_config.d/90-base-sshd.conf` drop-in.
- `roles/base_sshd/README.md`: Added role documentation for SSH daemon management and direct usage.
- `examples/inventory/group_vars/all/base_sshd.yml`: Added example SSH daemon variables for the Debian-family example lab.
- `examples/playbooks/test_base_sshd.yml`: Added an example integration test playbook that temporarily creates extra SSH daemon fragments to exercise merged `AllowUsers` and `Match User` behavior around `base_sshd`.

### Changed
- `roles/base/meta/main.yml`: Added `base_sshd` as a dependency of the `base` role with `base` and `base_sshd` tags.
- `roles/base/README.md`: Updated base role documentation to reflect the `base_sshd` dependency, inputs, and active dependency order.
- `README.md`: Added `base_sshd` to the available roles list and aligned the `base` role description.
- `examples/README.md`, `docs/01-examples.md`, and `README.md`: Updated the example documentation to include the new `base_sshd.yml` role-scoped variables file and the optional `base_sshd` integration test playbook.
- `docs/02-role-workflow.md`: Updated the documented aggregate base-role order so `base_sshd` is part of the active sequence and removed it from the future placeholder order.

### Fixed
- `roles/base_sshd/tasks/validate.yml`, `roles/base_sshd/README.md`, and `examples/inventory/group_vars/all/base_sshd.yml`: Validation and documentation now treat `AllowUsers` as effective SSH daemon state instead of implying that an empty `base_sshd_allow_users` list clears constraints defined elsewhere.
- `roles/base_sshd/tasks/validate.yml`: Normalized `sshd -T` `AllowUsers` parsing so validation compares the full effective user list instead of only the first reported entry.
- `roles/base_sshd/tasks/validate.yml`: Relaxed `AllowUsers` validation so the role confirms its required users are present after OpenSSH merges config sources instead of requiring this drop-in to own the complete effective list.
- `roles/base_sshd/tasks/validate.yml`: Runs `sshd -T` with a representative `-C` connection context and ignores duplicated `allowusers` tokens in merged output so validation behaves better on hosts with `Match` rules or accumulated `AllowUsers` entries.
- `roles/base_sshd/tasks/validate.yml`: Validates `AllowUsers` per required user context with `sshd -T -C` and checks the reported values without discarding the literal `allowusers` string as a special-case token.
- `roles/base_sshd/tasks/validate.yml` and `examples/playbooks/test_base_sshd.yml`: Use an IP-only fallback for `sshd -T -C addr=` so validation does not depend on `ansible_host` being an address.
- `examples/playbooks/test_base_sshd.yml`: Applies `base_sshd` before writing temporary SSH fixture fragments so the integration test still works when `/etc/ssh/sshd_config.d/` does not exist yet.
- `roles/base_sshd/tasks/validate.yml`: Validates baseline SSH daemon settings with `sshd -T` without a connection-specific context so external `Match` rules do not cause false failures in the role's general setting checks.
- `examples/playbooks/test_base_sshd.yml`, `examples/README.md`, and `docs/01-examples.md`: Expanded the `base_sshd` integration coverage to exercise a temporary `Match Address` fixture in addition to merged `AllowUsers` and `Match User`.

## [v0.13.0]
### Added
- `roles/base_sudo/`: New role for enforcing recurring sudo policy during the base phase.
- `roles/base_sudo/defaults/main.yml`: Added `base_sudo_packages`, `base_sudo_user`, and `base_sudo_group` defaults.
- `roles/base_sudo/tasks/`: Added assert, install, config, and validate phase task files for Debian-family sudo management.
- `roles/base_sudo/README.md`: Added role documentation for sudo management and direct usage.
- `examples/inventory/group_vars/all/base_sudo.yml`: Added example sudo variables for the Debian-family example lab.

### Changed
- `roles/base_sudo/tasks/config.yml` and `roles/base_sudo/tasks/validate.yml`: Simplified the role to always enforce the managed passwordless sudo drop-in so the base phase keeps a stable, homelab-friendly sudo path.
- `roles/base_sudo/tasks/assert.yml`: Removed the passwordless-toggle and confirmation-variable handling so validation stays focused on package, user, and group inputs.
- `roles/base_sudo/README.md`, `examples/inventory/group_vars/all/base_sudo.yml`, and `README.md`: Updated the documentation to reflect the always-managed passwordless sudo behavior.
- `roles/base/meta/main.yml`: Added `base_sudo` as a dependency of the `base` role with `base` and `base_sudo` tags.
- `roles/base/README.md`: Updated base role documentation to reflect the `base_sudo` dependency, inputs, and active dependency order.
- `examples/README.md` and `docs/01-examples.md`: Updated the example documentation to include the new `base_sudo.yml` role-scoped variables file.
- `docs/02-role-workflow.md`: Updated the documented aggregate base-role order so `base_sudo` is part of the active sequence and removed it from the future placeholder order.

### Fixed
- `roles/base_sudo/tasks/assert.yml` and `roles/base_sudo/tasks/config.yml`: Fail early when `base_sudo_user` does not already exist so the role enforces sudo policy for an existing account instead of silently creating one.
- `README.md`: Restored `base_locale` to the aggregate `base` role description so the top-level dependency summary matches the implemented role order.

## [v0.12.0]
### Added
- `roles/base_hostname/`: New role for enforcing the system hostname during the base phase.
- `roles/base_hostname/defaults/main.yml`: Added `base_hostname_name` defaults for hostname management.
- `roles/base_hostname/tasks/`: Added assert, config, and validate phase task files for Debian-family hostname management.
- `roles/base_hostname/README.md`: Added role documentation for hostname management and direct usage.
- `examples/inventory/group_vars/all/base_hostname.yml`: Added example hostname variables for the Debian-family example lab.

### Changed
- `roles/base/meta/main.yml`: Added `base_hostname` as a dependency of the `base` role with `base` and `base_hostname` tags.
- `roles/base/README.md`: Updated base role documentation to reflect the `base_hostname` dependency and inputs.
- `README.md`: Added `base_hostname` to the available roles list and aligned the `base` role description.
- `examples/README.md` and `docs/01-examples.md`: Updated the example documentation to include the new `base_hostname.yml` role-scoped variables file.
- `roles/base/meta/main.yml`, `roles/base/README.md`, and `docs/02-role-workflow.md`: Documented and aligned the aggregate base-role execution order as packages, locale, timezone, NTP, then hostname, followed by the planned future base roles.

### Fixed
- `roles/base_hostname/tasks/assert.yml`: Tightened hostname validation to require real DNS-style hostname labels instead of only rejecting whitespace and edge punctuation.
- `roles/base_hostname/tasks/validate.yml`: Validates the managed `/etc/hostname` value separately from the current short hostname so FQDN inputs such as `lab.example.internal` align with hosts that report `lab`.

### Documentation
- `roles/base_hostname/README.md` and `examples/inventory/group_vars/all/base_hostname.yml`: Clarified that the role writes the full hostname or FQDN to `/etc/hostname` while validating the current short hostname against the first label.

## [v0.11.0]
### Added
- `roles/base_ntp/`: New role for configuring time synchronization through `systemd-timesyncd` during the base phase.
- `roles/base_ntp/defaults/main.yml`: Added `base_ntp_packages`, `base_ntp_service_name`, `base_ntp_servers`, and `base_ntp_fallback_servers` defaults.
- `roles/base_ntp/tasks/`: Added assert, install, config, and validate phase task files for Debian-family NTP management, including managed timesyncd configuration and service-state validation.
- `roles/base_ntp/handlers/main.yml`: Added a handler that restarts the managed NTP service after configuration changes.
- `roles/base_ntp/templates/timesyncd.conf.j2`: Added a template for the managed `/etc/systemd/timesyncd.conf` file.
- `roles/base_ntp/README.md`: Added role documentation for NTP configuration and direct usage.
- `examples/inventory/group_vars/all/base_ntp.yml`: Added example NTP variables for the Debian-family example lab.

### Changed
- `roles/base/meta/main.yml`: Added `base_ntp` as a dependency of the `base` role with `base` and `base_ntp` tags.
- `roles/base/README.md`: Updated base role documentation to reflect the `base_ntp` dependency and inputs.
- `README.md`: Added `base_ntp` to the available roles list and aligned the `base` role description.
- `examples/README.md` and `docs/01-examples.md`: Updated the example documentation to include the new `base_ntp.yml` role-scoped variables file.

## [v0.10.0]
### Added
- `roles/base_locale/handlers/main.yml`: Added a locale regeneration handler for managed `/etc/locale.gen` changes.
- `roles/base_locale/templates/`: Added `locale.gen.j2` and `default_locale.j2` so locale files are rendered from shared templates instead of inline task content.

### Changed
- `roles/base_locale/tasks/main.yml`: Derives `base_locale_generated_locales` once at runtime so generated locale state stays internal to the role.
- `roles/base_locale/tasks/config.yml`: Simplified the config flow to render `/etc/locale.gen` and `/etc/default/locale` from templates, notify a handler for `locale-gen`, and flush that handler before validation-relevant follow-up work.
- `roles/base_locale/tasks/validate.yml`: Reused the same templates for managed file assertions so config and validate stay aligned with one rendering path.

### Fixed
- `.pre-commit-config.yaml`: Excluded `roles/base_locale/templates/locale.gen.j2` from `end-of-file-fixer` so the empty `/etc/locale.gen` case keeps rendering as a truly empty file.
- `roles/base_locale/defaults/main.yml` and `roles/base_locale/tasks/main.yml`: Moved `base_locale_generated_locales` back to runtime-derived role state so inventory cannot override the generated locale list independently of `base_locale_present`.

### Removed
- `roles/base_locale/tasks/config.yml`: Removed the `localedef` fallback path to keep locale generation behavior minimal and centered on `locale-gen`.

### Documentation
- `roles/base_locale/README.md`: Updated locale generation wording to reflect the template-based flow and removal of the `localedef` fallback.

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
