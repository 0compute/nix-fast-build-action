# Nix Seed

Nix Seed provides
[fully-transparent](https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/minimal-bootstrap/stage0-posix/hex0.nix),
multi-system, offline, OCI build containers .

## Purity Ain't Free

Nix is not well suited to non-native ephemeral environments. CI runners must install
Nix, realize the closure, substitute from binary caches or build from source.

- Binary caches are on the public internet

For GitHub CI, [Cache Nix Action](https://github.com/nix-community/cache-nix-action) and
[Nix Magic Cache](https://github.com/DeterminateSystems/magic-nix-cache-action) reduce
the need to reach outside of GitHub's backbone, but are still largely network and CPU
bound.

## Containers

Layered OCI build containers with the flake inputs closure baked in. Unchanged layers
are reused across builds, which yields extreme cacheability without relaxing
hermeticity. A commit that changes app code without modifying inputs, which will be most
of them, starts its CI build near instantly because all of the other layers are already
cached. Publishing to GHCR keeps images close to GitHub-hosted runners, reducing pull
time and cold-start overhead.

### Seed

- **base**: libc, CA certs, readonly shell
- **toolchain**: nix, glibc, libstdc++, compilers, debug tools.
- **build/input layers**:
  - **packages**: foundational derivations at the bottom of the stack.
  - **apps**: depends on packages so comes next.
  - **checks**: verifies the above outputs.
  - **devShells**: developer tooling after the main outputs.
- **container**: container glue (entrypoint, env configuration).

### Run

- **base**: shared
- **lib**: app runtime dependencies
- **app**: app
- **container**: container glue (entrypoint, env configuration).

## Trusting Trust

> The code was clean, the build hermetic, but the compiler was pwned.

Even with hermetic and deterministic builds, attacks like Ken Thompson's
[Trusting Trust](https://dl.acm.org/doi/10.1145/358198.358210) remain a concern. A
rigged build environment that undetectably injects code during compilation is always a
possibility.

### Trust No Fucker

xxx by cryto sig

with n-of-m quorum build validation.

Each container records:

- commit: git commit hash
- system: target environment (in Nix this is `system` i.e. `x86_64-linux` or
  `aarch64-darwin`)
- narHash: represents the absolute derivation of the image
- layerHashes: identify each OCI layer
- builder identity: who performed the build

See [publish](./bin/publish) for full details.

TODO: The builder signs these facts and embeds the signatures as OCI attestation
artifacts. Downstream operators can fetch the attestation with the image metadata to
confirm each input while keeping the provenance layer tied to the cached layers.

Signed statements are also mirrored into [Rekor](https://rekor.dev/) so there is a
public, append-only log of every builder identity plus what it signed. Rekor validates
each attestation, issues a verifiable timestamp, and lets auditors fetch the proof chain
without pulling every image layer — this provides an extra layer of transparency and
tamper-evidence for the provenance facts.

immutable, tamper-resistant ledger The CI runner's signed attestation is pushed to Rekor

### 3. Transparency

Supply-side transparency leans on Sigstore (cosign) and Rekor; every build publishes
statements that tie {commit, system, narHash} to the attested image, keeping the ledger
of provenance public and replayable.

### 4. Immutable promotion

Immutable promotion means anchoring a Merkle root over all systems’ narHashes for a
commit, publishing that root into a public ledger keyed by the commit and the root, and
performing the publish step only after a quorum of Rekor attestations has verified each
member. The outcome is a single globally verifiable, tamper-evident record that anyone
can audit before trusting the build.

## GitHub Actions Integration

Nix Seed provides a [GitHub Action](./action.yml).

- Supports x86_64 and ARM64, Linux and Darwin targets.
- Setting `registry_token` triggers load, tag, and push in one publish step.
- Omit it to build only. Add extra tags via `tags`.
- Use `registry` to push somewhere other than ghcr.io (default: ghcr.io); the action
  logs into that registry automatically using the provided token.
- Use `tags: latest` only when publishing the manifest after all systems finish.
- `seed_attr` defaults to `.#seed`.

Publishing to GHCR keeps images close to GitHub-hosted runners, reducing pull time and
cold-start overhead for cache hits.

## License Compliance

Nix Seed is unimpeachable. Upstream license terms for non-redistributable SDKs are fully
respected, leaving zero surface area for litigation.

______________________________________________________________________

![XKCD Compiling](https://imgs.xkcd.com/comics/compiling.png "Not any more, fuckers. Get back to work!")
