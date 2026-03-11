# CHANGELOG.md

Release history for `ansible-roles`.
Documents notable changes across repository structure, roles, examples, and documentation.

## [v0.18.0]
### Added
- Added the `base_logging` role for persistent local journald management on Debian-family hosts, including defaults, handlers, full phase tasks, template, role documentation, and example variables.

### Changed
- Added `base_logging` to the aggregate `base` role as an explicit opt-in follow-up role gated by `base_include_logging`.
- Updated repository, aggregate-role, and example documentation to describe the new optional logging role and its example variable file.

## [v0.17.0]
### Changed
- Reworked `base_firewall` to enforce an additive UFW baseline by default instead of resetting the firewall whenever the desired managed state changes.
- Split firewall rule inputs into `base_firewall_base_rules` and `base_firewall_additional_rules`, while keeping `base_firewall_rules` as the effective merged ruleset used by the role.
- Added the optional `base_firewall_purge_unmanaged_rules` path so exact rebuilds are explicit instead of automatic.
- Updated the example Ansible configuration to hide skipped-host output for quieter local role runs.

### Fixed
- Fixed `base_firewall` purge mode so an empty managed ruleset no longer fails on undefined purge-comparison facts and now converges cleanly.

### Documentation
- Updated repository, role, and example documentation to describe the additive `base_firewall` behavior, the split firewall rule variables, and the quieter example output defaults.

## [v0.16.0]
### Changed
- Moved aggregate `base` orchestration from meta dependencies to explicit `ansible.builtin.include_role` ordering, making `roles/base/tasks/main.yml` the single source of truth for the base stack.
- Aligned aggregate include-task tags with child role phase tags and role-specific tags so both broad runs such as `--tags validate` and narrow runs such as `--tags base_packages_validate` behave predictably.
- Added future aggregate include toggles for `base_logging`, `base_updates`, and `base_apparmor` alongside the existing firewall opt-in variable.
- Removed the ad hoc `Prepare` step from `base_locale` and kept its derived locale state inside the config and validate phases so the role cleanly follows the shared phase structure.
- Updated repository and role documentation to match the explicit aggregate-role ordering and tag behavior.

## [v0.15.0]
### Added
- Added the `base_firewall` role for Debian-family UFW management, including defaults, full phase tasks, role documentation, and example variables.
- Added `base_include_firewall` so the aggregate `base` role can opt into firewall enforcement without changing existing consumers by default.

### Changed
- Updated the aggregate `base` role to include `base_firewall` only when explicitly enabled.
- Added checksum-based convergent firewall reapply behavior so managed rule changes rebuild UFW state cleanly instead of leaving stale rules behind.
- Added an early safety check that refuses deny or reject incoming firewall policies unless the managed rules still allow SSH or Ansible access.
- Updated repository, role, and example documentation to describe `base_firewall` as an optional current follow-up role instead of a default dependency.

## [v0.14.0]
### Added
- Added the `base_sshd` role for Debian-family SSH daemon management, including defaults, handlers, templates, role documentation, example variables, and an integration test playbook.

### Changed
- Added `base_sshd` to the active aggregate `base` role order and updated the related repository and example documentation.
- Expanded the example lab to cover `base_sshd` variables and an optional integration run against merged `sshd_config.d` behavior.

### Fixed
- Reworked `base_sshd` validation to treat `AllowUsers` as effective merged SSH state rather than assuming the managed drop-in owns the full result.
- Improved `sshd -T` validation behavior for representative connection contexts, duplicate merged tokens, and environments where `ansible_host` is not an address.
- Updated the example integration flow so it still works when `/etc/ssh/sshd_config.d/` does not exist yet and now exercises both `Match User` and `Match Address` behavior.

## [v0.13.0]
### Added
- Added the `base_sudo` role for recurring sudo policy management, including defaults, full phase tasks, role documentation, and example variables.

### Changed
- Simplified `base_sudo` to always enforce the managed passwordless sudo drop-in for a stable homelab-oriented sudo path.
- Removed the old passwordless toggle and confirmation-variable flow from `base_sudo` so validation stays focused on package, user, and group inputs.
- Added `base_sudo` to the active aggregate `base` role order and updated the related repository and example documentation.

### Fixed
- Made `base_sudo` fail early when the managed user does not already exist instead of silently creating it.
- Restored `base_locale` to the top-level `base` role description so the documented aggregate role order matches the implementation.

## [v0.12.0]
### Added
- Added the `base_hostname` role for Debian-family hostname management, including defaults, tasks, role documentation, and example variables.

### Changed
- Added `base_hostname` to the active aggregate `base` role order and updated the related repository and example documentation.
- Documented the aggregate base stack as packages, locale, timezone, NTP, then hostname, followed by future planned roles.

### Fixed
- Tightened hostname validation to require real DNS-style labels instead of only rejecting obvious punctuation and whitespace problems.
- Split hostname validation between the managed `/etc/hostname` content and the current short hostname so FQDN inputs validate correctly.

### Documentation
- Clarified that `base_hostname` writes the full hostname or FQDN to `/etc/hostname` while validating the current short hostname against the first label.

## [v0.11.0]
### Added
- Added the `base_ntp` role for Debian-family time synchronization through `systemd-timesyncd`, including defaults, handlers, templates, role documentation, and example variables.

### Changed
- Added `base_ntp` to the active aggregate `base` role order and updated the related repository and example documentation.

## [v0.10.0]
### Added
- Added shared `base_locale` templates for `/etc/locale.gen` and `/etc/default/locale` plus a handler for locale regeneration.

### Changed
- Simplified `base_locale` to render locale files from templates and reuse the same rendering path during validation.
- Kept generated locale state as runtime-derived role state so inventory cannot override it independently of `base_locale_present`.

### Fixed
- Preserved the truly empty `/etc/locale.gen` case by excluding the template from the `end-of-file-fixer` pre-commit hook.

### Removed
- Removed the `localedef` fallback path so locale generation stays centered on `locale-gen`.

### Documentation
- Updated the `base_locale` documentation to reflect the template-based flow and removal of the `localedef` fallback.

## [v0.9.0]
### Added
- Added the `base_locale` role for Debian-family locale management, including defaults, full phase tasks, role documentation, and example variables.

### Changed
- Added `base_locale` to the aggregate `base` role and updated package, timezone, and locale tasks to use APT-based behavior consistently on Debian-family hosts.
- Tightened `base_locale` input validation and fully managed `/etc/locale.gen` plus `/etc/default/locale` as canonical role-owned state.
- Updated repository, role, and example documentation to state the Debian-family scope explicitly and describe the current locale-generation behavior.

### Fixed
- Resolved several `base_locale` validation and normalization issues, including register overwrite problems, malformed locale state handling, and lint-driven logic regressions.
- Brought locale tasks back into `yamllint` and `ansible-lint` compliance without changing the intended behavior.

### Documentation
- Documented 24-hour time configuration through `base_locale_lc_time` and clarified the supported locale-name formats.

## [v0.8.0]
### Added
- Added the `base_timezone` role for timezone management, including defaults, full phase tasks, role documentation, and example variables.
- Split example shared variables into role-scoped files in `examples/inventory/group_vars/all/`.

### Changed
- Added `base_timezone` to the aggregate `base` role and updated the related repository and example documentation.
- Replaced the single example `all.yml` file with a role-scoped `all/` directory for readability.
- Simplified timezone validation and kept timezone-data ownership inside the role instead of depending on `base_packages`.

### Fixed
- Resolved timezone validation warnings caused by Jinja delimiters inside assert conditions.
- Fixed standalone `base_timezone` runs by making the role install its own timezone package requirements.

### Documentation
- Added guidance for compact low-noise roles while preserving the shared phase structure and documented the split example variable layout.

## [v0.7.1]
### Changed
- Normalized tracked file headers across the repository to use a consistent path-first format with short purpose text.
- Replaced older header styles such as generic titles and `# file:` comments with one shared repository-wide pattern.

### Documentation
- Added `docs/03-file-consistency.md` to define the repository-wide header format, wording rules, and review checklist.
- Clarified intentionally empty role entrypoints by documenting their purpose directly in the affected task files.

## [v0.7.0]
### Added
- Added the standalone `bootstrap` role, a dedicated bootstrap playbook, and the related example inventory layout for initial provisioning.
- Added bootstrap defaults for the renamed role and support for optionally managing passwordless sudo for the automation account.

### Changed
- Removed bootstrap orchestration from the aggregate `base` role so bootstrap and recurring base configuration run as separate phases.
- Simplified the example flow to an explicit two-step sequence: run bootstrap first, then run `base` or `site`.
- Updated example inventory variables, password handling, and task tags to match the new standalone bootstrap model.

### Fixed
- Corrected example bootstrap connection precedence and removed duplicate SSH and sudo password prompts by reusing one prompted value.
- Fixed bootstrap user-creation failures by ensuring the primary group exists before user creation.
- Fixed the example follow-up sudo path by enabling optional passwordless sudo for the bootstrap-managed automation account.

### Documentation
- Updated repository and role documentation to match the new example topology, credential flow, and execution order.

### Removed
- Removed the old `roles/base_bootstrap/` path and the `base_run_bootstrap` phase-switch variable.

## [v0.6.0]
### Added
- Added the `base_packages` role for common package management.
- Added the `examples/` directory and moved the example lab docs and files into a dedicated example-focused layout.
- Added `docs/02-role-workflow.md` to document the shared role lifecycle and note that not all phases are required in every role.

### Changed
- Migrated the old test lab layout from `tests/` to `examples/`.
- Simplified `base_bootstrap` task tags and naming while enabling `base_packages` through the aggregate `base` role.

## [v0.5.1]
### Changed
- Reduced `base_bootstrap` task output noise by simplifying imported task names and consolidating validation assertions.
- Added authorized-key validation against the admin user's `authorized_keys` file and aligned the task naming conventions across the role.

## [v0.5.0]
### Refactored
- Renamed role variables to use role-specific prefixes, capitalized task names, and cleaned up YAML formatting for lint compliance.
- Updated the `monitoring_authorized_key` task entrypoint to match the newer task structure.

### Changed
- Added granular phase-specific tags to `base_bootstrap` for finer targeted execution.

### Fixed
- Corrected several `base_bootstrap` variable names, register names, and sudo-group membership validation logic.
- Updated the example inventory variables to use the new `base_bootstrap_*` naming consistently.

## [v0.4.0]
### Added
- Added test lab documentation in `tests/README.md` and `docs/01-test-lab.md`.

### Changed
- Renamed `docs/01.md` to `docs/01-test-lab.md` for clarity.

## [v0.3.2]
### Added
- Added pre-commit setup and troubleshooting documentation in `docs/00-pre-commit.mb`.

### Changed
- Tightened `.pre-commit-config.yaml` for a roles-only repository with clearer hook defaults, self-checks, safety hooks, and a simpler `ansible-lint` trigger.
- Updated the root `README.md` pre-commit guidance to match the repository setup.

### Removed
- Removed the root `ansible.cfg`, which was not needed in the roles-only repository.

### Merged
- Merged PR #11 for the pre-commit and linting documentation cleanup.

## [v0.3.1]
### Added
- Added and refined `.pre-commit-config.yaml` for linting and repository hygiene.

### Changed
- Updated task files and supporting config for `ansible-lint` compliance and cleaned up the pre-commit configuration.

### Fixed
- Brought the full pre-commit hook set to a passing state.

## [v0.3.0] - 2026-03-02
### Added
- Added aggregate orchestration for `base_bootstrap` through `base/meta/main.yml`.
- Added a placeholder `base/tasks/main.yml` file and made bootstrap configuration always ensure the admin user exists and is grouped correctly.

### Changed
- Improved `_common/tasks/task_flow.yml` path resolution, local pre-check behavior, and tag application for included phase tasks.
- Added `bootstrap_sudo_group` defaults and updated `base_bootstrap` tasks to use the corrected include path and variables.
- Made `base_bootstrap` validation check group membership through the new `bootstrap_sudo_group` variable.

## [v0.2.0]
### Added
- Added the `_common` role directory with a shared `tasks/task_flow.yml` orchestrator for assert, install, configure, and validate.

### Changed
- Added the `base_bootstrap` role tag variable so the shared task flow could expose role-specific tags.

## [v0.1.0] - 2026-02-27
### Added
- Added the initial root `README.md`, the `_common` task-flow documentation, and the first split of roles into a dedicated repository.
- Added the early `monitoring/authorized_key` role and its test playbook.
- Added the early `base/bootstrap` role and the shared `_common/tasks/task_flow.yml` orchestrator.

### Changed
- Standardized the initial role flow around assert, install, configure, and validate with more consistent task naming and structure.

### Fixed
- Corrected shell index and variable references in the early bootstrap validation tasks.
