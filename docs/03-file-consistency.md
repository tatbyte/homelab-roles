# docs/03-file-consistency.md

Reference for the repository file-header consistency rules.
Defines the standard path-first header format, the purpose text expected at the top of files, and examples for each file type used in this repository.

## Purpose

This repository uses a consistent file header pattern so each file explains itself immediately.

The goals are:

- make the repository path visible at the top of the file
- explain the file purpose in plain language
- keep docs, playbooks, defaults, tasks, metadata, templates, and config files consistent
- reduce ambiguity when files are opened directly in an editor tab

## Standard Format

Use the repository path first, then add one or two short explanation lines.

For Markdown files:

```md
# docs/03-file-consistency.md

Reference for the repository file-header consistency rules.
Defines the standard path-first header format, the purpose text expected at the top of files, and examples for each file type used in this repository.
```

For YAML files:

```yaml
---
# roles/bootstrap/tasks/main.yml
# Task entrypoint for the `bootstrap` role.
# Imports the assert, config, and validate phase files in order.
```

For INI and CFG files:

```ini
# examples/ansible.cfg
# Example Ansible configuration for the local lab.
# Points Ansible at the example inventory and the repository roles directory.
```

For Jinja templates:

```jinja
{# roles/base_locale/templates/default_locale.j2 #}
{# Template for the managed `/etc/default/locale` file in the `base_locale` role. #}
```

Avoid a blank line after Jinja header comments when template output is whitespace-sensitive.
This helps prevent accidental leading newlines in managed files such as `/etc/locale.gen`.

For ignore or dotfiles:

```text
# .gitignore
# Ignore local artifacts, caches, editor settings, and generated files for this repository.
```

## Rules

- Start with the repository path, not a generic title.
- Keep the explanation short and concrete.
- Describe what the file is for, not the entire subsystem.
- Use the same role and phase terms used elsewhere in the repo.
- Keep wording factual and implementation-specific.
- Preserve existing document markers such as `---` in YAML files.

## Wording Guidelines

Prefer these patterns:

- `Reference for ...`
- `Guide for ...`
- `Task entrypoint for ...`
- `Handlers for ...`
- `Default variables for ...`
- `Assert phase tasks for ...`
- `Config phase tasks for ...`
- `Validate phase tasks for ...`
- `Role metadata for ...`
- `Template for ...`

Prefer these shared concepts:

- `bootstrap phase`
- `base phase`
- `automation account`
- `example lab`
- `repository-wide`

Avoid:

- generic titles like `# Changelog` or `# Role Workflow Guide`
- prefixes like `# file:` or `## File:`
- vague text like `main file` or `configuration stuff`

## Empty Files

If a tracked file is intentionally empty from an execution perspective, add a header that explains why.

Example:

```yaml
---
# roles/monitoring/tasks/main.yml
# Task entrypoint for the `monitoring` role.
# Intentionally empty because this aggregate role currently delegates work through meta dependencies.
```

## Scope

Apply this format to:

- repository Markdown documentation
- playbooks
- inventory and config files
- role defaults
- role handlers
- role task files
- role metadata files
- role templates
- tracked dotfiles that benefit from a top-level explanation

## Review Checklist

When adding or editing a file, check:

1. Does the file start with its repository path?
2. Does the file explain its purpose in one or two short lines?
3. Does the wording match the rest of the repository?
4. Does the header avoid older variants like `# file:` or generic titles?
5. If the file is intentionally empty, does the header explain that?
