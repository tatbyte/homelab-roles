# roles/monitor_notify_now/README.md

Reference for the `monitor_notify_now` role.
Triggers the already-installed `monitor_notify` oneshot service immediately,
waits for the status file to refresh, prints a short summary, and fails when
the notification run result is not acceptable.
