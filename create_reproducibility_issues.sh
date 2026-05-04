#!/usr/bin/env bash
# Run this script from any machine with `gh` authenticated and access to ClawBio/ClawBio.
# Usage: bash create_reproducibility_issues.sh
set -euo pipefail

REPO="ClawBio/ClawBio"
LABEL="enhancement"

gh auth status >/dev/null

create_issue() {
  local title="$1"
  local body="$2"
  echo "Creating: $title"
  gh issue create \
    --repo "$REPO" \
    --title "$title" \
    --label "$LABEL" \
    --body "$body"
}

# ── Issue 1 ────────────────────────────────────────────────────────────────────
create_issue "Add REPLAY.md to reproducibility bundles" "$(cat <<'EOF'
## Summary

Add a human-readable \`REPLAY.md\` file to ClawBio reproducibility bundles.

ClawBio already has a strong reproducibility foundation through \`commands.sh\`, \`environment.yml\`, and \`checksums.sha256\`. A \`REPLAY.md\` file would make that system easier to use by giving users clear replay instructions directly inside each generated bundle.

## Context

The current reproducibility bundle is already machine-readable and executable. This issue proposes adding a user-facing guide next to the existing files so that reviewers, collaborators, and new users can understand the replay process without reading the source code.

## Proposed improvement

Generate:

\`\`\`
<output_dir>/reproducibility/REPLAY.md
\`\`\`

The file could explain:

- what the bundle contains
- how to recreate the environment
- how to run \`commands.sh\`
- how to verify outputs with \`checksums.sha256\`
- what \`CLAWBIO_ROOT\` and \`OUTPUT_DIR\` mean

## Acceptance criteria

- \`REPLAY.md\` is generated for skills using the shared reproducibility helpers
- The instructions are consistent across skills
- The file explains replay steps in plain language
- The file references the existing bundle files instead of duplicating implementation details

## Why this helps

This improves the user experience around an already existing reproducibility system and makes ClawBio easier to review, teach, and share.
EOF
)"

# ── Issue 2 ────────────────────────────────────────────────────────────────────
create_issue "Allow configurable Python interpreter in reproducibility replay scripts" "$(cat <<'EOF'
## Summary

Allow generated replay scripts to use a configurable Python interpreter.

## Context

ClawBio reproducibility scripts currently reconstruct the command needed to re-run a skill. Making the Python executable configurable would improve portability across local machines, conda environments, virtualenvs, CI runners, and future deployment setups.

## Proposed improvement

Support an environment variable such as:

\`\`\`
CLAWBIO_PYTHON
\`\`\`

with a safe default, for example:

\`\`\`bash
${CLAWBIO_PYTHON:-python3}
\`\`\`

This would allow users to run replay scripts with the Python executable that matches their environment.

## Acceptance criteria

- Replay scripts work without requiring extra configuration
- Users can override the Python executable through an environment variable
- Existing workflows continue to work
- The behavior is documented in the reproducibility workflow

## Why this helps

This makes replay scripts more flexible across operating systems and environments while preserving the current simple workflow.
EOF
)"

# ── Issue 3 ────────────────────────────────────────────────────────────────────
create_issue "Add lightweight validation for CLAWBIO_ROOT in replay scripts" "$(cat <<'EOF'
## Summary

Add a small validation step for \`CLAWBIO_ROOT\` in generated replay scripts.

## Context

Replay scripts rely on locating the ClawBio repository so they can execute the relevant skill code. A lightweight validation step would make the replay experience clearer when the repository path is missing or incorrect.

## Proposed improvement

Before executing the replay command, validate that \`CLAWBIO_ROOT\` points to an existing directory.

Example behavior:

\`\`\`bash
if [ ! -d "$CLAWBIO_ROOT" ]; then
    echo "Invalid CLAWBIO_ROOT: $CLAWBIO_ROOT"
    exit 1
fi
\`\`\`

## Acceptance criteria

- Invalid repository paths produce a clear message
- Valid paths continue to work exactly as before
- The check is added consistently to generated replay scripts

## Why this helps

This improves usability by failing early with a helpful message instead of letting the command fail later in a less obvious way.
EOF
)"

# ── Issue 4 ────────────────────────────────────────────────────────────────────
create_issue "Improve handling of external input paths in reproducibility bundles" "$(cat <<'EOF'
## Summary

Improve how reproducibility bundles communicate external input requirements.

## Context

Some skills may depend on input files that live outside the ClawBio repository and outside the output directory. These paths are valid, but users replaying an analysis need to know which external files must be available.

## Proposed improvement

Add clearer handling for external inputs in generated reproducibility artifacts.

Possible approaches:

- add comments in \`commands.sh\` when external paths are used
- list required external inputs in a future \`REPLAY.md\`
- optionally emit a small manifest of external input paths
- document how users should relocate or provide these files during replay

## Acceptance criteria

- External input paths are clearly visible to users
- Replay behavior remains flexible
- Existing workflows are not restricted
- Users receive enough context to reproduce analyses on another machine

## Why this helps

This improves transparency for real-world workflows where input data often lives outside the project repository.
EOF
)"

# ── Issue 5 ────────────────────────────────────────────────────────────────────
create_issue "Extend ReproPath resolution for more path scenarios" "$(cat <<'EOF'
## Summary

Extend \`ReproPath\` resolution so more paths can be rendered relative to known reproducibility anchors.

## Context

The shared reproducibility API already introduces \`ReproPath\` and path anchors such as repository-root and output-directory contexts. This issue proposes expanding that logic so generated replay scripts can avoid absolute paths in more cases.

## Proposed improvement

Improve path normalization and detection for cases such as:

- equivalent paths with different normalization
- symlinked paths
- nested output subdirectories
- paths that can be safely represented relative to \`CLAWBIO_ROOT\`
- paths that can be safely represented relative to \`OUTPUT_DIR\`

## Acceptance criteria

- More generated paths use reproducibility variables instead of absolute paths
- Existing valid commands remain unchanged
- The behavior is covered by tests
- The logic remains simple enough to maintain

## Why this helps

This continues the current move toward cleaner, more portable reproducibility bundles.
EOF
)"

# ── Issue 6 ────────────────────────────────────────────────────────────────────
create_issue "Add optional diagnostics for reproducibility path resolution" "$(cat <<'EOF'
## Summary

Add optional diagnostics that explain how paths are resolved in reproducibility bundles.

## Context

The reproducibility system now has structured path handling through \`ReproPath\`. For complex workflows, it would be helpful to understand when a path was rendered relative to the repository, relative to the output directory, or left as an external path.

## Proposed improvement

Add optional diagnostics such as:

- comments in \`commands.sh\`
- debug logs during bundle generation
- a small path-resolution summary in future replay documentation

The diagnostics should be informative but not noisy.

## Acceptance criteria

- Users can see when fallback path behavior is used
- Normal replay scripts remain readable
- Diagnostics do not break existing workflows
- Tests cover at least one fallback case

## Why this helps

This makes reproducibility behavior easier to understand and debug, especially for workflows with external data.
EOF
)"

# ── Issue 7 ────────────────────────────────────────────────────────────────────
create_issue "Continue rollout of shared reproducibility API across remaining skills" "$(cat <<'EOF'
## Summary

Continue migrating skills toward the shared reproducibility API.

## Context

ClawBio already treats reproducibility bundles as a core part of skill outputs. The shared helpers in \`clawbio/common/reproducibility.py\` provide a cleaner and more consistent way to generate these artifacts.

## Proposed improvement

Audit remaining skills and migrate legacy or custom reproducibility logic toward the shared helpers where appropriate:

- \`ReproPath\`
- \`ReproCommand\`
- \`write_portable_commands_sh\`
- \`write_environment_yml\`
- \`write_checksums\`

## Acceptance criteria

- Remaining skills are reviewed for reproducibility consistency
- Skills that still use custom bundle logic are either migrated or documented
- Bundle structure remains consistent across the project
- Tests confirm that migrated skills still generate expected artifacts

## Why this helps

This reduces duplicated logic and keeps reproducibility behavior consistent across the ClawBio skill library.
EOF
)"

# ── Issue 8 ────────────────────────────────────────────────────────────────────
create_issue "Wire conda-lock into reproducibility workflows and documentation" "$(cat <<'EOF'
## Summary

Integrate optional \`conda-lock\` usage more directly into reproducibility workflows and documentation.

## Context

The reproducibility helpers already include support for writing a conda lock file through \`write_conda_lock\`. The next step is to make this capability easier to discover and use.

## Proposed improvement

Add optional workflow support and documentation for locked environments.

Possible additions:

- document when to use \`environment.yml\` vs \`conda-lock.yml\`
- add replay instructions for locked environments
- integrate lockfile generation into selected skills or CI workflows where appropriate
- provide a fallback path when \`conda-lock\` is not installed

## Acceptance criteria

- Users can understand how to use lockfiles for stricter reproducibility
- Existing \`environment.yml\` workflows continue to work
- Lockfile usage is optional
- Documentation includes a minimal example

## Why this helps

This improves long-term environment reproducibility while keeping the current workflow lightweight.
EOF
)"

# ── Issue 9 ────────────────────────────────────────────────────────────────────
create_issue "Add automated replay validation to CI" "$(cat <<'EOF'
## Summary

Add CI coverage that validates reproducibility bundles through an actual replay workflow.

## Context

ClawBio already emphasizes reproducible outputs. CI replay validation would help ensure that generated bundles remain functional as skills and shared helpers evolve.

## Proposed improvement

For a representative subset of skills, CI could:

1. run the skill
2. generate the reproducibility bundle
3. execute \`reproducibility/commands.sh\`
4. verify outputs with \`checksums.sha256\`

## Acceptance criteria

- At least one representative skill is validated through replay in CI
- The workflow can be expanded incrementally
- Failures clearly identify whether the issue is generation, replay, or checksum verification
- Runtime remains reasonable for CI

## Why this helps

This gives maintainers long-term confidence that reproducibility bundles continue to work after future changes.
EOF
)"

# ── Issue 10 ───────────────────────────────────────────────────────────────────
create_issue "Expand cross-platform reproducibility validation" "$(cat <<'EOF'
## Summary

Expand reproducibility validation across operating systems.

## Context

ClawBio is designed to be local-first and reproducible. Since users may run skills on Linux, macOS, or Windows, cross-platform validation would help catch portability differences early.

## Proposed improvement

Add a CI matrix for selected reproducibility checks across:

- Linux
- macOS
- Windows, where feasible

The first version can focus on lightweight demo-mode skills to keep runtime manageable.

## Acceptance criteria

- At least one reproducibility workflow is tested on more than one OS
- Platform-specific failures are easy to identify
- The matrix can be expanded over time
- Existing CI remains practical in runtime and cost

## Why this helps

This strengthens ClawBio's portability story and supports a wider range of users.
EOF
)"

# ── Issue 11 ───────────────────────────────────────────────────────────────────
create_issue "Document the reproducibility workflow for users" "$(cat <<'EOF'
## Summary

Add user-facing documentation for ClawBio reproducibility bundles.

## Context

The repository already positions reproducibility as a core part of ClawBio. A dedicated documentation page would make the workflow easier for users, reviewers, and contributors to understand.

## Proposed improvement

Create documentation that explains:

- what a reproducibility bundle contains
- what \`commands.sh\` does
- how to recreate the environment from \`environment.yml\`
- how to verify outputs with \`checksums.sha256\`
- how to handle external input files
- how to troubleshoot common replay setup issues

## Acceptance criteria

- Documentation is added to the repo
- It includes at least one concrete replay example
- It uses the current bundle structure
- It is written for users who may not know the internals of ClawBio

## Why this helps

Good documentation makes the reproducibility system easier to adopt and easier to review.
EOF
)"

# ── Issue 12 ───────────────────────────────────────────────────────────────────
create_issue "Add example reproducibility workflows" "$(cat <<'EOF'
## Summary

Add one or more real-world examples showing the full reproducibility workflow.

## Context

ClawBio already generates reproducibility artifacts. A concrete example would help users understand the complete flow from running a skill to replaying and verifying the result.

## Proposed improvement

Add an example that shows:

1. running a demo skill
2. inspecting the generated reproducibility bundle
3. recreating the environment
4. running \`commands.sh\`
5. verifying outputs with \`checksums.sha256\`

The example should use a lightweight skill so that users can try it quickly.

## Acceptance criteria

- At least one complete example is documented
- The example uses the current bundle structure
- The workflow is easy to follow
- The example can be used for onboarding or demos

## Why this helps

Examples turn the reproducibility system from an implementation detail into something users can immediately understand and trust.
EOF
)"

echo ""
echo "✓ All 12 issues created in $REPO"
