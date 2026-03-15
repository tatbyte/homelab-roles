# roles/user_zshell/README.md

Reference for the `user_zshell` role.
Explains how the role manages one human admin zsh login shell and managed
`.zshrc` file after the base phase on Debian-family hosts in this repository.

## Features
- Validates that the target human admin account already exists before zsh management starts
- Enforces one existing human admin account to use `zsh` as its login shell
- Manages one `.zshrc` file for the selected human admin account
- Renders the managed `.zshrc` file from a Jinja2 template (`user_zshell_zshrc.j2`)
- Accepts either `/usr/bin/zsh` or `/bin/zsh` as the effective binary; if the configured login shell path is unavailable, the role checks both canonical locations automatically
- Sets the account login shell in passwd, so SSH logins for the managed user use zsh
- Supports inventory-driven aliases, environment variables, and PATH additions in the managed `.zshrc`
- Verifies the resulting passwd shell entry and managed `.zshrc` content after configuration

## Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `user_zshell_user` | `{{ user_account_name | default('admin') }}` | yes | Existing human admin username whose zsh policy is managed |
| `user_zshell_group` | `{{ user_account_primary_group | default(user_zshell_user) }}` | yes | Group owner for the managed `.zshrc` file |
| `user_zshell_home` | `{{ user_account_home | default('/home/' ~ user_zshell_user) }}` | yes | Home directory for the managed `.zshrc` file |
| `user_zshell_login_shell` | `/usr/bin/zsh` | yes | Zsh login shell path to enforce |
| `user_zshell_rc_template_name` | `` | no | Optional template override name in `roles/user_zshell/templates/` |
| `user_zshell_aliases` | `{}` | no | Mapping of alias names to shell commands written into the managed `.zshrc` |
| `user_zshell_environment` | `{}` | no | Mapping of environment variable names to string values exported from the managed `.zshrc` |
| `user_zshell_path_additions` | `[]` | no | Ordered list of absolute PATH entries prepended when the directories exist |

## Usage

Use `user_zshell` after `base` has already installed the host package baseline and after `user_account` has already ensured the target human admin account and home directory exist.
This role does not install zsh itself, so the requested `user_zshell_login_shell` path must already exist on the host.
In the example lab, `zsh` is installed through `base_packages` and then selected here with `/usr/bin/zsh`.

Direct usage:

```yaml
- hosts: all
  become: true
  roles:
    - role: user_account
    - role: user_zshell
      vars:
        user_zshell_user: alice
        user_zshell_login_shell: /usr/bin/zsh
        user_zshell_aliases:
          ll: ls -alF
        user_zshell_environment:
          EDITOR: vim
```

Example aggregate-role usage:

```yaml
- hosts: all
  become: true
  vars:
    user_include_zshell: true
    user_zshell_login_shell: /usr/bin/zsh
  roles:
    - role: user
```

When `user_include_zshell: true`, the aggregate `user` role disables direct shell ownership in `user_account` first so `user_zshell` becomes the single owner of the zsh login shell and `.zshrc` file.
The managed zsh policy file path is always `.zshrc`.
Because the role updates the passwd login shell to zsh, interactive SSH sessions for the managed user land in zsh and use the managed `.zshrc`.

## Dependencies
None

## Author
tatbyte

## License
MIT
