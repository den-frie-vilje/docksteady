# Releasing docksteady

The release procedure, including the review gate that is not optional.

## 1. Review gate: three-persona README review

Before tagging, run three independent reviews of `README.md` against the
code as it stands at the release commit. Fresh reviewers each time, no
carried-over context beyond a list of what changed since the last round:

- **A user**: a competent non-programmer with exactly the problem the tool
  solves. Judges whether they can qualify themselves, install, set up,
  verify success, and recover, unaided; flags every unannounced permission
  prompt and every step with no visible outcome.
- **An Apple-support copywriter**: judges register (calm, second person,
  task-first, sentence-case headings, jargon gated and explained), heading
  quality, and whether detail grows top to bottom (inverted pyramid).
  House rules: British spelling, no em-dashes.
- **A sceptical developer**: verifies every claim in the README against the
  source, the installer, and the Homebrew formula, path and line for each
  mismatch; walks both install routes; checks the security and permissions
  account for completeness and honesty.

Reviewers report ranked findings and never edit. Integrate what survives
scrutiny; code findings are fixed in the same release, prose findings in the
README. The first two rounds (v0.3.0 to v0.3.2) caught thirty-six findings
including real bugs (config-wiping init, a sweep that could grab laptop
windows, triggers surviving uninstall), so the gate has earned its place.

## 2. Ship

1. Bump `VERSION` in `docksteady`; `python3 -m py_compile docksteady`;
   `bash -n install.sh uninstall.sh`.
2. Commit with a standalone message (what was decided and why, not just
   what changed), tag `vX.Y.Z`, push branch and tag, create the GitHub
   release with upgrade notes for existing users.
3. `curl -sL .../archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256`, then
   update `url` and `sha256` in
   `den-frie-vilje/homebrew-tap/Formula/docksteady.rb`; commit and push.
4. Dogfood: `brew update && brew upgrade docksteady`, then exercise what
   changed on a real desk before considering the release done. If the
   change touched the LaunchAgent or wake hook, rerun `docksteady init` and
   verify both regenerated correctly.
