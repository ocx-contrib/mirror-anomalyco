# mirror-anomalyco

OCX mirror for [Anomaly Innovations](https://github.com/anomalyco) releases. One
repository, one spec directory per package.

| Package | Spec | Publishes to | Announced as | Upstream SPDX |
|---|---|---|---|---|
| [opencode](https://github.com/anomalyco/opencode) | [`opencode/mirror.yml`](opencode/mirror.yml) | `ghcr.io/ocx-contrib/anomalyco/opencode` | `ocx.sh/anomalyco/opencode` | `MIT` |

Each upstream release is discovered, re-bundled, smoke-tested per
`(version, platform)` and only then pushed with cascade tags, after which the
result is announced into the OCX index.

> This repository previously published the same upstream to the flat coordinate
> `ocx.sh/opencode`, as `mirror-opencode`. `anomalyco/opencode` is the grouped
> successor. Upstream itself moved from `sst/opencode` to `anomalyco/opencode`;
> the spec reads the release feed from the current owner.

## Layout

```
mirror-base.yml         repo-wide policy every spec inherits via `extends:`
opencode/
├── mirror.yml          the spec — never at the repo root
├── metadata.json       bundle interface
├── CATALOG.md          → ocx package describe
├── logo.svg / logo.png describe assets, 512px PNG
└── tests/smoke.star    Starlark smoke test
```

`LICENSE` and `NOTICE.md` are shared at the root. Logos are **not** — each
package carries its own, because a repo-root `logo.*` sits in no workflow's
`paths:` filter, so replacing it would publish nothing until some unrelated
edit happened to fire.

⚠️ `extends:` is a **shallow** merge of top-level keys. A spec that restates
`platforms:` to change one runner drops every `containers:` entry with it, and
nothing reds — the legs simply stop existing, and every `os.features` claim
goes back to being asserted rather than verified. Restate a block in full or
not at all.

## Platforms

`opencode` publishes five platform entries: both Linux arches as
`+libc.glibc`, `darwin/arm64`, and both Windows arches. Two upstream Linux
flavours are deliberately absent, and both omissions are load-bearing.

**No `+libc.musl`.** Upstream ships `opencode-linux-{x64,arm64}-musl.tar.gz`
and this mirror does not carry them. opencode is bun-compiled, and bun's musl
build is *dynamically* linked against the C++ runtime as well as musl —
`DT_NEEDED` lists `libstdc++.so.6` and `libgcc_s.so.1`, neither of which ships
in bare Alpine, so the artifact exits 127 there. The fix is one
`apk add libstdc++`, and the spec has nowhere to put it: a `containers[]` entry
accepts only `image`/`id`/`shell`, and the renderer execs `ocx` as the
container entrypoint, so there is no shell and no persistent container to
install into. Pointing the leg at a musl image that *already* carries the C++
runtime (e.g. `node:22-alpine3.20`, verified working) is rejected at spec load,
because `infer_libc_from_image` classifies by image basename and treats only
`alpine*` as musl. With no leg that can prove the claim, publishing the flavour
would ship an unverified `os.features` — so it stays out until `ocx-mirror`
grows `containers[].libc` or a package-install hook. **On musl today:**
`apk add libstdc++` and take upstream's tarball directly, or run the glibc
build under `gcompat`.

**No `darwin/amd64`.** `opencode-darwin-x64.zip` is published upstream and is
not mirrored. bun-compiled binaries `SIGILL` (exit 132) under Rosetta 2 —
reproduced across the plain build, the `-baseline` build and
`BUN_JSC_useJIT=0`, so it is a native-startup illegal instruction, not a
JIT/AVX2 path selectable by asset or env — and GitHub has retired native Intel
macOS runners, so the slice cannot be CI-validated at all. The Intel build runs
fine on real Intel Macs; it just cannot be tested here.

`-baseline` variants (pre-AVX2 rebuilds, x64 only) and the
`opencode-desktop-*` Electron GUI installers are out of scope. The anchored
`^…$` patterns are what keep all of these out; the measurement behind each
decision is recorded above the `assets:` block in `opencode/mirror.yml`.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `opencode/mirror.yml` | hand | yes — see below |
| `opencode/{metadata.json,CATALOG.md,logo.*}` | hand | — |
| `opencode/tests/smoke.star` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

```bash
ocx-mirror package pipeline generate ci --spec opencode/mirror.yml
```

**Name every spec.** `--spec` *appends* rather than replaces, so a command
naming a subset silently stops rendering the rest while staying green — and the
drift guard reds on a generated workflow the current spec set no longer
produces.

`verify-generated.yml` exits 65 on drift. If a generated workflow is wrong, the
spec or the renderer template is wrong — fix it there and regenerate.

Run `direnv allow` once to put the pinned toolchain on `PATH`, and invoke
`ocx-mirror` directly — never `ocx run -- ocx-mirror`, which pins
`OCX_BINARY_PIN` to the bootstrap `ocx` and false-reds the nested push.

## The binaries claim

Every opencode archive is a flat single executable at its root
(`strip_components: 0`), so the bundle's only PATH entry is a bare
`${installPath}` — the executable *is* the content root. `bin_scan` only looks
*below* an `${installPath}/<dir>` entry, so `auto`/`verify` is rejected at spec
load with exit 65. `mirror-base.yml` therefore sets `bin_scan: off` and
`opencode/metadata.json` hand-lists `binaries: ["opencode"]` — the blessed
shape for this asset type.

The bundle also pins `OPENCODE_DISABLE_AUTOUPDATE=true`: opencode self-updates
in place by default, which would silently replace the mirrored bytes a consumer
pinned by digest.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index pull request from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; each
package's redistribution license is recorded in [`NOTICE.md`](NOTICE.md).
