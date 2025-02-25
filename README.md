# helm-wait-examples

 #<issue-number> the Helm wait logic will be refactored to use kstatus. To view the proposal in depth look here -

The `try-wait.sh` script goes through several examples and shows the differences between the legacy Helm 3 waiter and the new watcher. The following examples are highlighted

1. Basic waiting for a deployment - no difference
2. Waiting for custom resources - completely different the legacy watcher does not wait for CRs while the new watcher does.
3. Jobs
  - When just `--wait` is used the watcher waits for the jobs to be ready, but not complete. The legacy waiter ignores Jobs entirely
  - When `--wait-for-jobs` is used the behavior is the same between both
4. Waiting for hooks - no difference
5. Wait for uninstall