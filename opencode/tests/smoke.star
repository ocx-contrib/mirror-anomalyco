# tests/smoke.star — stable across upstream opencode releases.
# Branch on the typed platform constant; never a string compare.
OPENCODE = "opencode.exe" if ocx.target_platform.os == ocx.os.Windows else "opencode"

# Tier 1 + 2: liveness on the composed PATH + semver version shape.
# `opencode --version` prints a bare "X.Y.Z" — assert the shape, never the value.
r_version = ocx.run(OPENCODE, "--version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: functional behavior on hermetic input — deterministic, offline.
# `completion bash` generates a yargs completion script with a stable marker.
r_comp = ocx.run(OPENCODE, "completion", "bash")
expect.ok(r_comp)
expect.contains(r_comp.stdout, "opencode-completions")
