# CHANGELOG.md

Release history for `homelab-roles`.
Documents notable changes across repository structure, roles, examples, and documentation.

## [v2.4.0]
### Added
- Added standalone `docker_adguard` with Compose-managed AdGuard Home, Traefik proxy-network integration, role-owned service/access identities, Vault-backed admin inputs, and backup-friendly `/srv/adguard` host paths.

### Changed
- Updated the example Docker layer to include AdGuard coverage, moved the example AdGuard lab to a non-default host DNS port, split host-published versus container-internal DNS listener ports for Traefik-backed downstream services, and changed AdGuard config handling to merge role-owned settings into the live config while preserving AdGuard-managed fields for idempotent reruns.

### Documentation
- Added Docker downstream-service guidance for Traefik-connected services and updated Docker docs/examples to cover the AdGuard role, Compose-label routing, and host-versus-container port modeling.

## [v2.3.0]
### Added
- Added managed Docker daemon JSON defaults (`/etc/docker/daemon.json`), `srv_*`/`access_*` Docker service conventions, `/srv/<service>/data` backup paths, and standalone `docker_traefik` with Compose-managed Traefik integration over the shared proxy network.

### Changed
- Added service user/group behavior for the Docker service roles, aligned engine and Traefik example vars with the new defaults, added a base-firewall managed-rule cleanup guard (`base_firewall_remove_stale_managed_rules: false`), and kept the Docker playbook flow ready to reapply firewall state after Docker service declarations.

### Documentation
- Updated Docker role docs and example docs for daemon JSON management, Traefik proxy-network behavior, and standardized external Vault workflow (`~/.config/ansible/vault.yml` + `~/.config/ansible/vault.pass`).

## [v2.2.0]
### Added
- Added the aggregate `docker` role with explicit include ordering and toggle-based expansion support for Docker-related child roles.
- Added the standalone `docker_engine` role with full assert/install/config/validate phases for Debian-family Docker engine package installation and daemon enablement.
- Added Docker example lab coverage through `examples/playbooks/docker.yml`, `examples/inventory/group_vars/all/docker.yml`, and `examples/inventory/group_vars/all/docker_engine.yml`.

### Changed
- Updated the example post-bootstrap flow so `examples/playbooks/site.yml` now runs `base`, `user`, then `docker`.
- Added Docker supplementary-group automation that targets both the bootstrap automation account (`bootstrap_user`) and the managed human admin account (`user_account_name`) when present.
- Kept direct Docker supplementary-group enforcement as the default behavior and made optional `user_groups` registration opt-in instead of default.

### Documentation
- Updated repository and example documentation to include the new Docker layer, aggregate role descriptions, and the expanded example phase commands.

## [v2.1.0]
### Added
- Implemented Vault-backed credentials for the bootstrap process, enabling secure handling of sensitive data during initial setup.
### Changed
- Updated bootstrap role to integrate Vault for credential management, improving automation reliability and security.

## [v2.0.1]
### Fixed
- Fixed the `user_vim` derive/assert/render path by removing mixed inline-expression syntax in task loops and replacing unsupported `loop` usage on a block with valid per-task loop placement.
- Fixed template-path validation behavior so local filesystem checks run on localhost without privilege prompts, removing module failures caused by interactive sudo.
- Fixed `.vimrc` rendering output so managed-file metadata comments are rendered in comments (not Vim commands), preventing `E488` errors when opening generated files.
- Fixed changelog-adjacent pre-commit failures by addressing YAML/Ansible line-length and mixed syntax issues introduced during the user_vim refactor.

### Changed
- Generalized and shortened role docs/readmes that previously hardcoded role orders and complete lists, reducing future documentation churn when adding new roles.

## [v2.0.0]
### Added
- Added the standalone `user_vim` role for managing per-user `.vimrc` files for one or more existing human admin users, including defaults, assert/install/config/validate phases, optional template overrides, and optional Vim package handling.
- Added the example `user_vim.yml` inventory file plus the aggregate `user_include_vim` toggle used to exercise the new role in the local lab.

### Changed
- Updated the aggregate `user` role so `user_vim` is an explicit opt-in follow-up role that runs after the optional `user_git` role, keeping editor configuration as a lightweight final user-environment layer.
- Hardened `user_vim` template rendering and validation so missing, unreadable, empty, or render-broken templates fail with clearer per-user role messages instead of less specific downstream template errors.
- Updated the example user stack so the human admin account now gets a managed `.vimrc` baseline alongside the existing optional user-environment roles.

### Documentation
- Updated repository, workflow, role, and example documentation to describe the new `user_vim` role, the expanded aggregate ordering, and the example managed Vim baseline.

## [v1.9.0]
### Added
- Added the standalone `user_ssh` role for managing per-user `.ssh` baselines for one or more existing human admin users, including `authorized_keys`, optional `~/.ssh/config`, optional `~/.ssh/known_hosts`, permission enforcement, and exact file validation.
- Added the example `user_ssh.yml` inventory file plus the aggregate `user_include_ssh` toggle used to exercise the new role in the local lab.

### Changed
- Updated the aggregate `user` role so `user_ssh` is an explicit opt-in follow-up role that runs after the optional `user_password` role and before the optional `user_zshell` role, keeping admin SSH access separate from shell and profile concerns.
- Updated the example user stack so the human admin account now gets a managed `.ssh` baseline before the optional zsh shell layer.
- Extended `user_ssh` with an explicit removed-user cleanup list so stale previously managed `authorized_keys`, `~/.ssh/config`, and `~/.ssh/known_hosts` files can be revoked safely after a user is removed from the active SSH policy.

### Documentation
- Updated repository, workflow, role, and example documentation to describe the new `user_ssh` role, the expanded aggregate ordering, and the example admin SSH-access baseline.

## [v1.8.0]
### Added
- Added the standalone `user_profile` role for managing per-user `.profile` files plus optional `.bash_profile` files for one or more existing human admin users, with inventory-driven environment variables, PATH additions, and login/session defaults.
- Added the example `user_profile.yml` inventory file plus the aggregate `user_include_profile` toggle used to exercise the new role in the local lab.

### Changed
- Updated the aggregate `user` role so `user_profile` is an explicit opt-in follow-up role that runs after the optional `user_zshell` role and before the optional `user_directories` role, matching the intended shell-versus-profile responsibility boundary for this repository.
- Updated the example `user_zshell` profile so interactive shell aliases stay in `.zshrc` while shared login/session exports and PATH defaults move into the new `user_profile` role.

### Documentation
- Updated repository, workflow, role, and example documentation to describe the new `user_profile` role, the expanded aggregate ordering, and the example split between interactive zsh behavior and login/session profile defaults.

## [v1.7.0]
### Added
- Added the standalone `user_git` role for managing per-user Git identity, aliases, and simple `section.option` settings through a managed `~/.gitconfig` file for one or more existing human admin users.
- Added the example `user_git.yml` inventory file plus the aggregate `user_include_git` toggle used to exercise the new role in the local lab.

### Changed
- Updated the aggregate `user` role so `user_git` is an explicit opt-in follow-up role that runs after the optional `user_directories` role, matching the intended user-environment ordering for this repository.
- Updated the example `user_zshell` profile so shell aliases stay shell-focused while Git-native aliases live under the new `user_git` role and managed `~/.gitconfig`.

### Documentation
- Updated repository, workflow, role, and example documentation to describe the new `user_git` role, the expanded aggregate ordering, and the example Git identity plus alias baseline.

## [v1.6.0]
### Added
- Added the standalone `user_directories` role for managing common home-directory workspace paths such as `.local/bin`, `scripts`, `.config`, and `projects` for one or more existing human admin users.
- Added the example `user_directories.yml` inventory file plus the aggregate `user_include_directories` toggle used to exercise the new role in the local lab.

### Changed
- Updated the aggregate `user` role so `user_directories` is an explicit opt-in follow-up role that runs after the optional `user_zshell` role, matching the current shell-layer ordering for this repository.

### Documentation
- Updated repository, workflow, role, and example documentation to describe the new `user_directories` role, the expanded aggregate ordering, and the example workspace-directory baseline.
- Aligned the new `user_directories` defaults and example inventory with the existing `user_zshell` PATH convention by using `.local/bin` instead of a top-level `bin` directory.

## [v1.5.0]
### Added
- Added the standalone `user_zshell` role for managing one human admin zsh login shell and a managed `.zshrc` file with inventory-driven aliases, environment variables, and PATH additions.
- Added the example `user_zshell.yml` inventory file plus the aggregate `user_include_zshell` toggle used to exercise the new zsh role in the local lab.

### Changed
- Updated the aggregate `user` role so `user_zshell` is an explicit opt-in follow-up role that runs after optional `user_password`.
- Narrowed `user_account` so it now manages only a fallback baseline shell when direct shell ownership is enabled, while aggregate `user` disables that ownership automatically before `user_zshell` runs.
- Updated the example base package set to install `zsh` because the example human admin zsh layer now uses `/usr/bin/zsh`.
- Reworked the feature into the zsh-only `user_zshell` role with a single managed `.zshrc` template (`user_zshell_zshrc.j2`) and an optional `user_zshell_rc_template_name` override.
- Expanded the example `user_zshell` inventory profile with editor defaults, local `.local/bin` PATH integration, and extended zsh-oriented aliases matching the managed `.zshrc` experience.
- Made `user_zshell` tolerant of zsh binary location variance by resolving `/usr/bin/zsh` and `/bin/zsh` candidates when the configured `user_zshell_login_shell` path is unavailable, and using the first executable match.
- Centralized zsh-path resolution in the shared derive phase so full runs and narrow tagged runs use the same effective SSH login shell, and preserved the documented PATH-addition behavior that prepends existing directories in order.

### Fixed
- Hardened `user_zshell` template override handling by validating `user_zshell_rc_template_name` as a safe basename and documenting/rendering behavior so invalid values are rejected during assert rather than failing deep in template rendering.

### Documentation
- Updated repository, workflow, role, and example documentation to describe the new `user_zshell` role, the expanded aggregate ordering, the zsh-based example shell layer, and the split between baseline account creation and richer zsh management.

## [v1.4.0]
### Added
- Added the standalone `user_sudo` role for managing explicit sudoers policy for one existing human admin account with user-versus-group policy selection and optional passwordless sudo.
- Added the example `user_sudo.yml` inventory file plus the aggregate `user_include_sudo` toggle used to exercise the new role in the local lab.

### Changed
- Updated the aggregate `user` role so `user_sudo` is an explicit opt-in follow-up role that runs after optional `user_groups` and before optional `user_password`.
- Kept `base_sudo` focused on the automation-account baseline while `user_sudo` now owns the separate post-base sudoers drop-in for the human admin layer.
- Added an explicit one-run cleanup path so disabling aggregate `user_sudo` can remove a previously managed human-admin sudoers drop-in without re-enabling steady-state sudo management.

### Documentation
- Updated repository, workflow, role, and example documentation to describe the new `user_sudo` role, the new aggregate ordering, the cleanup toggle for stale human-admin sudoers drop-ins, and the `su`-based validation dependency used for passwordless-behavior checks.

## [v1.3.0]
### Added
- Added the standalone `user_groups` role for managing supplementary group membership for existing human admin accounts with per-user append-versus-explicit behavior.
- Added the example `user_groups.yml` inventory file plus the aggregate `user_include_groups` toggle used to exercise the new role in the local lab.

### Changed
- Updated the aggregate `user` role so `user_groups` is an explicit opt-in follow-up role that runs after `user_account` and before optional `user_password`.
- Added optional managed-group creation support to `user_groups` through `user_groups_manage_groups`, while keeping the safer default behavior that requires requested groups to already exist.
- Extended `user_groups` so it now aggregates `user_groups_base_memberships`, `user_groups_role_declared_memberships`, and `user_groups_additional_memberships` into the effective managed per-user group policy.

### Documentation
- Updated repository, workflow, role, example, and Vault documentation to describe the new `user_groups` role, its aggregate ordering, and the new example supplementary-group variable file.
- Added supplementary-group integration guidance for future roles in `docs/06-user-groups-role-integration.md`, including the registration pattern, merge behavior, ordering requirement, and inventory-versus-role split.

## [v1.2.0]
### Added
- Added the standalone `user_password` role for managing Vault-friendly hashed local password state and optional password locking for one existing human admin account.
- Added the example `user_password.yml` inventory file plus the documented demo SHA-512 password hash used for local testing.
- Added concise Vault guidance in `docs/05-vault.md`, including the recommended `~/.config/ansible/` path layout and the current secret-bearing role guidance.

### Changed
- Moved password-state ownership out of `user_account` and into `user_password` so hashed local passwords and password locking are managed in one dedicated secret-aware role.
- Updated the aggregate `user` role, example inventory, and documentation so `user_password` is an explicit opt-in follow-up role gated by `user_include_password`.
- Documented and aligned the example aggregate-toggle layout so `base_include_*` values now live in `examples/inventory/group_vars/all/base.yml`, matching the newer `user.yml` aggregate-toggle pattern.

### Documentation
- Updated repository, workflow, role, and example documentation to describe the new `user_password` role, the Vault usage pattern, and the aggregate-versus-child variable split used by the example lab.
- Documented that the local example lab enables `user_password` with a demo SHA-512 hash for the plaintext test password `password` so local account-login testing is straightforward.

## [v1.1.0]
### Added
- Added the aggregate `user` role for the post-base human-admin user layer, including explicit aggregate ordering, metadata, documentation, and example playbook wiring.
- Added the standalone `user_account` role for creating, adopting, and validating one human admin account with explicit primary-group, home-directory, and baseline shell management.
- Added example inventory files for the new user layer, including `user.yml` and `user_account.yml`, plus a dedicated `examples/playbooks/user.yml` entrypoint.

### Changed
- Updated the example `site.yml` flow so the full post-bootstrap stack now runs `base` and then `user`.
- Shifted the bootstrap-role default automation UID/GID to `1100` and kept the new human-admin `user_account` role defaults at `1050` to preserve a clearer ID separation between automation and human accounts.
- Updated the example SSH allow-list so the example human admin account created by the user layer is permitted by the managed `base_sshd` policy.
- Hardened `user_account` input validation and final-state validation so missing users or groups fail cleanly instead of crashing through unsafe fact lookups, and so unmanaged primary groups are asserted explicitly before config runs.
- Added explicit `user_account_move_home` handling so adopting an existing user now fails early on unexpected home-directory changes unless the move is intentionally allowed.

### Documentation
- Updated repository, workflow, role, and example documentation to describe the new `user` aggregate role, the `user_account` role, the expanded example lab flow, and the bootstrap-versus-user UID/GID defaults.

## [v1.0.0]
### Changed
- Declared the recurring Debian-family `base` stack complete at `v1.0.0`, covering the aggregate base workflow plus the current optional follow-up roles for firewall, fail2ban, logging, updates, AppArmor, auditd, upgrade, and needrestart.
- Extended `base_firewall` so it now aggregates `base_firewall_base_rules`, `base_firewall_role_declared_rules`, and `base_firewall_additional_rules` into the effective managed ruleset.
- Added additive stale-rule cleanup in `base_firewall` for role-owned UFW rules whose comments use the managed prefix, so ports can close automatically when future app or service roles stop declaring them.
- Added stricter `base_firewall` validation for the managed comment prefix and role-declared firewall rules so future service-role integrations fail early when they do not follow the shared convention.

### Documentation
- Updated repository, aggregate-role, role, and example documentation to describe the `v1.0.0` base-role milestone and the current complete base stack.
- Added firewall integration guidance for future application or service roles in `docs/04-firewall-role-integration.md`, including the managed comment convention, registration pattern, ordering requirement, and stale-rule cleanup flow.
- Updated the example firewall variable file so automatic role-declared rule aggregation is shown explicitly in the example lab configuration.

## [v0.27.0]
### Added
- Added the `base_needrestart` role for Debian-family restart-check reporting, including defaults, full phase tasks, role documentation, and example variables.

### Changed
- Added `base_needrestart` to the aggregate `base` role as an explicit opt-in follow-up role gated by `base_include_needrestart`.
- Exposed `base_upgrade_upgrade_changed`, `base_upgrade_autoremove_changed`, and `base_upgrade_changed` so downstream roles can consume package-maintenance change state directly.
- Kept the example lab's `base_upgrade` role enabled by default so the example base run continues to exercise immediate package maintenance before `base_needrestart` reports follow-up state.
- Tightened the example lab's `base_needrestart` variables so pending restart or reboot follow-up now fails the example run explicitly instead of only reporting it.

### Documentation
- Updated repository, aggregate-role, and example documentation to describe the new optional `needrestart` role, its example variable file, and the restart-check follow-up it exposes after package maintenance.
- Clarified that the example lab intentionally uses strict `base_needrestart` failure flags after `base_upgrade`, and documented how to switch the example run back to report-only behavior when desired.
- Documented that `base_needrestart` now skips its batch check automatically only when the same run's `base_upgrade` role reports no package-maintenance changes and no reboot-required follow-up.

## [v0.26.0]
### Changed
- Added the GitGuardian `ggshield` secret-scanning hook to `.pre-commit-config.yaml` so staged changes are scanned for leaked credentials during the `pre-commit` stage.
- Added the companion GitGuardian `ggshield-push` hook so outgoing commits are also scanned during the `pre-push` stage.

### Documentation
- Updated the repository README and pre-commit reference to document `ggshield` installation, the required authentication prerequisite, troubleshooting, and the expanded secret-scanning coverage across both commit and push hooks.

## [v0.25.0]
### Added
- Added the `base_fail2ban` role for Debian-family intrusion-prevention baseline management, including defaults, handlers, full phase tasks, template, role documentation, and example variables.

### Changed
- Added `base_fail2ban` to the aggregate `base` role as an explicit opt-in follow-up role gated by `base_include_fail2ban`.

### Documentation
- Updated repository, aggregate-role, and example documentation to describe the new optional Fail2ban role and its example variable file.

## [v0.24.0]
### Added
- Added the `base_auditd` role for Debian-family Linux audit baseline management, including defaults, handlers, full phase tasks, template, role documentation, and example variables.

### Changed
- Added `base_auditd` to the aggregate `base` role as an explicit opt-in follow-up role gated by `base_include_auditd`.
- Reworked `base_auditd` configuration handling so audit daemon changes use a compatible `auditctl --signal HUP` reconfigure path instead of unsupported generic service reload or restart behavior.
- Expanded the `base_auditd` managed log-directory and `auditd.conf` baseline so Debian-family hosts converge more reliably during service startup.
- Added visible managed-file ownership comments to comment-friendly rendered config templates such as `base_auditd`, `base_dns`, `base_logging`, `base_locale`, `base_ntp`, and `base_sshd`.
- Updated `base_hosts` to insert a blank line before the managed `/etc/hosts` block for friendlier readability.

### Documentation
- Updated repository, aggregate-role, and example documentation to describe the new optional audit role, its example variable file, and the current `homelab-roles` repository naming.
- Added repository guidance for when rendered templates should include visible managed-file comments and when they should not.

## [v0.23.0]
### Added
- Added the `base_dns` role for Debian-family DNS resolver management through `systemd-resolved`, including defaults, handlers, full phase tasks, template, role documentation, and example variables.

### Changed
- Added `base_dns` to the aggregate `base` role as an explicit opt-in resolver baseline gated by `base_include_dns`.

### Documentation
- Updated repository, aggregate-role, and example documentation to describe the new optional DNS role and its example variable file.

## [v0.22.0]
### Added
- Added the `base_hosts` role for inventory-driven `/etc/hosts` management on Debian-family hosts, including defaults, compact phase tasks, template, role documentation, and example variables.

### Changed
- Added `base_hosts` to the aggregate `base` role as an explicit opt-in identity-and-resolution step gated by `base_include_hosts`.
- Extended `base_hosts` to support optional manual host mappings in addition to inventory-driven entries.

### Documentation
- Updated repository, aggregate-role, and example documentation to describe the new optional hosts role and its example variable file.

## [v0.21.0]
### Added
- Added the `base_upgrade` role for explicit Debian-family package upgrades, including defaults, full phase tasks, role documentation, and example variables.

### Changed
- Added `base_upgrade` to the aggregate `base` role as an explicit opt-in follow-up role gated by `base_include_upgrade`.

### Documentation
- Updated repository, aggregate-role, and example documentation to describe the new optional upgrade role, its example variable file, and the `serial: 1` example base-playbook behavior for safer reboot-capable runs.

## [v0.20.0]
### Added
- Added the `base_apparmor` role for Debian-family AppArmor baseline management, including defaults, full phase tasks, role documentation, and example variables.

### Changed
- Added `base_apparmor` to the aggregate `base` role as an explicit opt-in follow-up role gated by `base_include_apparmor`.

### Documentation
- Updated repository, aggregate-role, and example documentation to describe the new optional AppArmor role and its example variable file.

## [v0.19.0]
### Added
- Added the `base_updates` role for minimal unattended-upgrades management on Debian-family hosts, including defaults, full phase tasks, templates, role documentation, and example variables.
- Added an example `monitoring_authorized_key.yml` inventory file so the example lab now shows the public variables for every current role with defaults.

### Changed
- Added `base_updates` to the aggregate `base` role as an explicit opt-in follow-up role gated by `base_include_updates`.
- Updated repository, aggregate-role, and example documentation to describe the new optional updates role and its example variable file.
- Aligned `monitoring_authorized_key` with the shared phase naming and its canonical `monitoring_authorized_key_*` variable names.

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
