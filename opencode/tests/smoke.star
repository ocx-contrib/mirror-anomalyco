# tests/smoke.star — stable across upstream opencode releases.
# Branch on the typed platform constant; never a string compare.
OPENCODE = "opencode.exe" if ocx.target_platform.os == ocx.os.Windows else "opencode"

# Tier 1 + 2: liveness on the composed PATH + semver version shape.
# `opencode --version` prints a bare "X.Y.Z" — assert the shape, never the value.
r_version = ocx.run(OPENCODE, "--version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: functional behavior on hermetic input — deterministic, offline.
# 2.x dropped `completion`; `--help` works across majors (1.x prints it to
# stderr, 2.x to stdout) and lists the stable `run` subcommand.
r_help = ocx.run(OPENCODE, "--help")
expect.ok(r_help)
expect.matches(r_help.stdout + r_help.stderr, r"\brun\b")
