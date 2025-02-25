# helm-wait-examples

PR [#13604](https://github.com/helm/helm/pull/13604) refactors the the Helm wait logic to use kstatus. Find the HIP with the proposed changes here - https://github.com/helm/community/blob/main/hips/hip-0022.md

The `try-wait.sh` script goes through several examples and shows the differences between the legacy Helm 3 waiter and the new watcher. To run it, you should clone the helm repository so that the root of this repo and the root of the Helm repo are in the same directory. Run `make` in the Helm repo with the branch in https://github.com/helm/helm/pull/13604 checked out.

 The following examples are highlighted:
1. Basic waiting for a deployment - no difference
2. Waiting for custom resources - completely different the legacy watcher does not wait for CRs while the new watcher does.
3. Jobs
  - When just `--wait` is used the watcher waits for the jobs to be ready, but not complete. The legacy waiter ignores Jobs entirely
  - When `--wait-for-jobs` is used there is no difference in behavior
4. Waiting for hooks - no difference
5. Wait for uninstall - waits for resources to be uninstalled