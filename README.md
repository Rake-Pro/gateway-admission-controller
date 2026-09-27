# gateway-admission-controller (Rake-Pro fork)

In-house fork of [angelnu/gateway-admision-controller](https://github.com/angelnu/gateway-admision-controller)
by angelnu, licensed Apache-2.0 (see [LICENSE](LICENSE)). Full upstream history is kept; upstream is
the `upstream` git remote. All credit for the webhook design and code goes to the upstream project.

*Fork changes (modified files, per Apache-2.0 section 4(b))*

| Area | Change |
|---|---|
| Go / modules | Go 1.27.1, all modules bumped (k8s.io/* v0.37.1, client-go aligned, x/net, x/text, x/sys), `go mod tidy`, `vendor/` committed |
| Tests | `internal/mutation/gatewayPodMutator_test.go` filters empty and `.` search domains like the mutator does (test failed on hosts whose resolv.conf has `search .`) |
| Image | `ghcr.io/rake-pro/gateway-admission-controller`, alpine 3.24.2 + `apk upgrade`, non-root uid 65532, builds from `vendor/` |
| CI | Rake-Pro fleet workflows: CI build + govulncheck, release on main push / v* tag, Trivy CRITICAL gate, weekly Trivy rescan, Dependabot (gomod, docker, actions) |
| Upstream CI | upstream workflows and Renovate config moved to `.github/upstream-disabled/` (not run) |
| Webhook behavior | unchanged |

*Branches and versions*

- `dev` = default branch, `main` = release branch (promotion PR dev -> main, merge commit only)
- semver tags `vX.Y.Z` only; the fork line starts at `v4.0.0`, above upstream's last tag `v3.12.0`
- never push upstream tags to origin (`remote.upstream.tagOpt --no-tags` is set locally)

---

# gateway admision controller

Originally based on the [k8s-at-home container template](https://github.com/k8s-at-home/template-container-image)
and the [example for Kubewebhook](https://github.com/slok/k8s-webhook-example/), this
[admision webhook](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/)
changes the default gateway and, optionally, the DNS of processed pods. It does so by adding an
init container and a sidecar. The sidecar is used in case the IP of the gateway changes.

This is useful in order to send traffic to a VPN forwarder, traffic scanner, etc instead of using the
default cluster egress.

The [.github](.github) folder will get PRs from this template so you can apply the latest workflows.

## Prereqs

You need to create the following secrets:
- GHCR_USERNAME            # Needed to upload container to the Github Container Registry
- GHCR_TOKEN               # Needed to upload container to the Github Container Registry

## How to build

1. Build and test local
    ```bash
    make
    ```
2. Build the container
    ```bash
    make docker-build
    ```

Check the [Makefile] for other build targets

## How to run

It is expected to be used from within a Helm chart but the binary might also
be run directly:

1. Run
    ```bash
    make run
    ```
2. Connect to <host IP>:8080

For more options you might run `make help`

