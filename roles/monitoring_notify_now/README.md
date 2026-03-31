# roles/monitoring_notify_now/README.md

Reference for the `monitoring_notify_now` role.
Triggers the already-installed `monitoring_notify` oneshot service immediately,
waits for the status file to refresh, prints a short summary, and fails when
the notification run result is not acceptable.

When the `_now` helper runs in its default direct-script test mode, it can also
include review-only Docker-tag notes in the same fleet-state ntfy message
format used by real warning sends, without promoting tag drift into the
recurring warning alert set.
