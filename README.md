# Nix Seed

Hermetic. Deterministic. Unimpeachable.

## Overview

Nix Seed provides multi-arch / multi-platform hermetic OCI containers for flake
build and run.

- **Build:** includes full flake input graph and Nix; does not require network
  access.
- **Run:** includes package and runtime inputs only.

## Layers and Extreme Cacheability

Nix Seed maps flake outputs to OCI layers with stable, input-hashed boundaries.
Unchanged layers are reused across builds, which yields extreme cacheability
without relaxing hermeticity.

Layer scopes are explicit:

- **Base:** minimal runtime environment.
- **Toolchain:** compilers and build tools; build-only.
- **Library:** shared language and numeric libraries.
- **Apps:** project code, scripts, and models.
- **Checks:** tests and validation outputs; build-only.
- **DevShells:** development tools; build-only.
- **Overlays:** version overrides and patches; build-only.

## License

Licensed under the MIT License. Copyright 2026 Zero Compute Ltd.

## Attestation

Planned: expand this section.

Containers (seeds) embed OCI attestations with this example payload:

```json
{
  "flakeHash": "sha256-flake-and-inputs",
  "layerHashes": {
    "base": "sha256",
    "toolchain": "sha256",
    "library": "sha256",
    "apps": "sha256",
    "checks": "sha256",
    "devShells": "sha256",
    "overlays": "sha256"
  },
  "seedDigest": "sha256",
  "signature": "gpg-or-slsa",
  "builtBy": "builder-identity",
  "timestamp": "ISO8601"
}
```

- `flakeHash`: inputs match the declared pinned flake.
- `layerHashes`: each split output layer is unmodified.
- `seedDigest`: final OCI image digest.
- `signature`: optional GPG or SLSA signature for authenticity.

Planned: add an SBOM.

## Trust No Fucker

"The code was clean, the build hermetic, but the compiler was pwned.

Just because you're paranoid doesn't mean they aren't out to fuck you."

**Apologies to Joseph Heller, *Catch-22* (1961)**

Even with hermetic, deterministic, and attested builds, attacks like Ken
Thompson's [Trusting Trust](https://dl.acm.org/doi/10.1145/358198.358210) remain
a concern. A rigged build environment can undetectably inject code during
compilation.

Assume that any build environment can and will be compromised.

### Transparency

Use Sigstore (cosign) to issue In-Toto statements. Every build records its
{commit, system, narHash} in a public ledger (Rekor).

### Immutable Promotion (EVM L2)

Promotion of a build is not a manual flag but a cryptographic event. A quorum
($n$ of $m$) of independent builders must agree on the narHash before the
mapping is anchored into a smart contract on an L2 blockchain.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TNFArtifactRegistry
 * @dev Anchors a mapping of commit+system to a narHash once quorum is reached.
 */
contract TNFArtifactRegistry {
  // commitHash + system (e.g., x86_64-linux) maps to narHash
  mapping(bytes32 => string) public promotedBuilds;

  // Authorization: Only the Watchdog/Multisig can anchor a promotion
  address public watchdog;

  event BuildPromoted(bytes32 indexed buildKey, string narHash);

  constructor(address _watchdog) {
    watchdog = _watchdog;
  }

  /**
   * @notice Records the narHash once the off-chain Watchdog verifies n-of-m
   * Rekor attestations.
   * @param _commit The git commit hash
   * @param _system The Nix system tuple
   * @param _narHash The resulting Nix Archive hash
   */
  function anchorPromotion(
    bytes32 _commit,
    string calldata _system,
    string calldata _narHash
  ) external {
    require(msg.sender == watchdog, "TNF: Unauthorized caller");

    bytes32 buildKey = keccak256(abi.encodePacked(_commit, _system));

    // Ensure immutability: once anchored, it cannot be "re-pwned"
    require(
      bytes(promotedBuilds[buildKey]).length == 0,
      "TNF: Build already anchored"
    );

    promotedBuilds[buildKey] = _narHash;
    emit BuildPromoted(buildKey, _narHash);
  }
}
```

Gas economics matter because every promotion writes to an L2 registry. Prefer
batching promotions under a Merkle root and reuse the cheapest finality window
(e.g., optimistic rollups). Estimate ~50k gas per `anchorPromotion` call, so at
0.5 gwei (~0.0000000005 ETH) the per-hash cost is under $0.03 on current
rollups; adjust the gas limit if the L2 gas price spikes to keep per-hash gas
cost predictable and low.

### Verification and Anchoring

- **Deploy Registry:** Deploy the `TNFArtifactRegistry` to an EVM L2.
- **Watchdog (Rust):** Implement the off-chain observer using `sigstore-rs` to
  poll Rekor and verify quorum.
- **License Audit:** Keep Watchdog build-time dependencies MIT to maintain a
  zero-litigation surface area.

### Endgame

Nixpkgs full-source bootstrap anchors the toolchain to a human-auditable stage0
hex seed. This is the endgame for supply chain security.

### Legal Compliance

Lawyers hit you twice as hard.

Nix Seed is legally unimpeachable. Upstream license terms for
non-redistributable SDKs are fully respected, leaving zero surface area for
litigation.

## GitHub Actions Integration

Nix Seed provides a [GitHub Action](https://docs.github.com/actions).

- Supports x86_64 and ARM64, Linux and Darwin targets.
- Setting `github_token` triggers load, tag, and push in one publish step.
- Omit it to build only. Add extra tags via `tags`.
- Use `registry` to push somewhere other than ghcr.io.
- Use `tag_latest: true` only when publishing the manifest after all systems
  finish.
- `seed_attr` defaults to `.#seed`.
- Seeds default to `substitutes = false`; set `substitutes = true` in
  `mkseed.nix` if you want to allow binary cache use inside the seed.

Publishing to GHCR keeps images close to GitHub-hosted runners, reducing pull
time and cold-start overhead for cache hits.

### Example: Build and Publish Seed

```yaml
---
name: build-seed
"on": [push]
jobs:
  seed:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: ./
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          seed_attr: .#seed
          registry: ghcr.io
          tags: latest
```

### Example: Build Project with Seed

```yaml
---
name: build-project
"on": [push]
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/your-org/nix-seed:latest
    steps:
      - uses: actions/checkout@v4
      - run: nix build .#app
```

### Comparison with Nix Community / GH Actions Caches

- **Hermetic build:** Nix Seed is ✅ fully isolated; standard caches ⚠ may fetch
  missing paths.
- **Reproducible:** Nix Seed ✅ pins inputs/tools; standard caches ⚠ vary by host
  and toolchain.
- **Incremental rebuilds:** Nix Seed ✅ only rebuilds changed layers; standard
  caches ⚠ rebuild more surface.
- **Layer reuse:** Nix Seed ✅ reuses base, toolchain, libs, apps, checks,
  devShells, overlays; standard caches ❌ are flat.
- **Cache keys:** Nix Seed ✅ uses flake input hash per layer; standard caches ⚠
  are ad hoc or per-derivation.
- **Network deps:** Nix Seed ❌ can run offline; standard caches ⚠ rely on remote
  caches and untar overhead.
- **Developer speed:** Nix Seed ✅ is near-instant when cached; standard caches ⚠
  are slower and more network-bound.

**Summary:** Nix Seed turns the pinned dependency graph into reusable OCI
layers, not single store paths. That yields faster builds without the setup tax
of repeatedly populating Nix caches in typical GitHub Actions flows.

![XKCD Compiling](https://imgs.xkcd.com/comics/compiling.png "Not any more, fuckers. Get back to work.")
