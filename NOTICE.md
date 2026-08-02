# NOTICE

This repository packages and redistributes upstream software published by
[Anomaly Innovations](https://github.com/anomalyco). The Apache-2.0 license in
[`LICENSE`](LICENSE) covers the OCX pipeline files authored here. It does
**not** cover any upstream-derived asset — each package's redistributed bytes
carry their own license, recorded below.

Each package's logo is reproduced for catalog identification only, under
nominative fair use. The marks remain the property of their respective owners
and no endorsement is implied.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `opencode` | `ghcr.io/ocx-contrib/anomalyco/opencode` | `MIT` |

---

## `opencode`

Upstream: <https://github.com/anomalyco/opencode>
Published to `ghcr.io/ocx-contrib/anomalyco/opencode`.

| Component | SPDX | Holder |
|---|---|---|
| opencode (`opencode`) | **MIT** | Copyright (c) 2025 opencode |

Permissive; redistribution of the compiled binary is granted provided the
copyright notice and permission notice are retained. Upstream ships bare
archives with no bundled `LICENSE` file, so the notice is reproduced above and
the terms are those of
<https://github.com/anomalyco/opencode/blob/main/LICENSE>.

Each published binary is a single-file executable compiled with
[bun](https://bun.sh), which embeds the JavaScript runtime and opencode's
bundled npm dependency tree. Those dependencies are third-party works under
their own (permissive) licenses, enumerated in upstream's lockfile.

The opencode name is used for catalog identification under nominative fair use.

Upstream previously published from `sst/opencode`; the project moved to
`anomalyco/opencode` and this mirror tracks the current coordinate.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.
