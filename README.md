# Nix Seed

## Mission

Nix Seed provides near-instant, cryptographically attestable CI builds.

This is Endgame for supply chain security.

![XKCD Compiling](https://imgs.xkcd.com/comics/compiling.png "Not any more, fuckers. Get back to work.")

### Problem: Purity Ain't Free

The purity Nix guarantees carries a tax: every derivation must be fetched separately,
materialized, and verified before it can be trusted. Missing inputs force CI runs to
substitute from binary caches or rebuild from source, which delays the job, fragments
caches across branches, and burns network/CPU. The more dependencies a project has, the
more often CI stalls on the download/unpack/verify loop instead of the actual build.

For GitHub CI, [Cache Nix Action](https://github.com/nix-community/cache-nix-action) and
[Nix Magic Cache](https://github.com/DeterminateSystems/magic-nix-cache-action) reduce
the need to reach outside of GitHub's backbone, but are still largely network and CPU
bound.

<!-- TODO: real numbers -->

Time-to-build with no input changes: 60s

### Solution: Seed Containers

Nix Seed provides layered OCI build containers with the input graph baked in. Flake
outputs are mapped to OCI layers with stable, input-hashed boundaries. Unchanged layers
are reused across builds, which yields extreme cacheability without relaxing
hermeticity. Publishing to GHCR keeps images close to GitHub-hosted runners, reducing
pull time and cold-start overhead.

<!-- TODO: real numbers -->

Time-to-build with no input changes: 5s

### Problem: Trusting Trust

"The code was clean, the build hermetic, but the compiler was pwned.

Just because you're paranoid doesn't mean they aren't out to fuck you."

**Apologies to Joseph Heller, *Catch-22* (1961)**

Even with hermetic and deterministic builds, attacks like Ken Thompson's
[Trusting Trust](https://dl.acm.org/doi/10.1145/358198.358210) remain a concern. A
rigged build environment that undetectably injects code during compilation is always a
possibility.

### Solution: Trust No Fucker

Nixpkgs uses full-source bootstrap which anchors the toolchain to a [human-auditable stage0 hex
seed](https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/minimal-bootstrap/stage0-posix/hex0.nix).

Each container records the layer hashes, narHash, builder identity, and flake hash as
part of its build, so emitting attestations simply signs and releases those facts. The
provenance layer thus rides along with the cached layers.

Supply-side transparency leans on Sigstore (cosign) and Rekor; every build publishes
statements that tie {commit, system, narHash} to the attested image, keeping the ledger
of provenance public and replayable.

For the truly paranoid: Immutable promotion is anchoring a Merkle root over all systems’
narHashes for a commit into a public ledger keyed by commit plus the root, and only
doing so once a quorum of Rekor attestations has verified the members; the result is a
single globally verifiable, tamper-evident record anyone can audit before trusting the
build.

## GitHub Actions Integration

Nix Seed provides a [GitHub Action](./action.yml).

- Supports x86_64 and ARM64, Linux and Darwin targets.
- Setting `github_token` triggers load, tag, and push in one publish step.
- Omit it to build only. Add extra tags via `tags`.
- Use `registry` to push somewhere other than ghcr.io (default: ghcr.io); the action
  logs into that registry automatically using the provided token.
- Use `tag_latest: true` only when publishing the manifest after all systems finish.
- `seed_attr` defaults to `.#seed`.

Publishing to GHCR keeps images close to GitHub-hosted runners, reducing pull time and
cold-start overhead for cache hits.

### Examples

#### Build and Publish Seed

Workflow file `.github/workflows/build-seed.yaml`:

```yaml
name: Build Seed
on:
  push:
    paths: &paths
      - flake.lock
      - flake.nix
      - .github/workflows/build-seed.yaml
  pull_request:
    paths: *paths
jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - name: Checkout
        uses: actions/checkout@v6
      - name: Build seed
        uses: 0compute/nix-seed
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          tag_latest: true
```

### Build Project with Seed

Workflow file: `.github/workflows/build.yaml`.

```yaml
---
name: Build
on:
  push:
    # MUST: match paths in build-seed.yaml
    paths-ignore: &paths-ignore
      - flake.lock
      - flake.nix
      - .github/workflows/build-seed.yaml
  pull_request:
    paths-ignore: *paths-ignore
  workflow_run:
    workflows:
      - Build Seed
    types:
      - completed
jobs:
  build:
    runs-on: ubuntu-latest
    container: ghcr.io/${{ github.repository }}:latest
    steps:
      - uses: actions/checkout@v6
      - run: nix build
```

## Compliance

Nix Seed is legally unimpeachable. Upstream license terms for non-redistributable SDKs
are fully respected, leaving zero surface area for litigation.
