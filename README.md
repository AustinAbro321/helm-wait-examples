# helm-wait-examples

 #<issue-number> the Helm wait logic will be refactored to use kstatus. To view the proposal in depth look here -

The `try-wait.sh` script goes through several examples and shows the differences between the legacy Helm 3 waiter and the new watcher. The following examples are highlighted

1. Basic waiting for a deployment - no difference
2. Waiting for custom resources - completely different the legacy watcher does not wait for CRs while the new watcher does.
3. Waiting for jobs - slightly different, the watcher waits for the jobs to be ready, but not complete even when the `--wait-for-jobs` flag is not used.
4. Waiting for hooks - no difference