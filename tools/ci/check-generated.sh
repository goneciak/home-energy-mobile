#!/usr/bin/env bash
# Fails when generated code is out of date (plan §17.2: "build_runner
# aktualny"). Run it right after `flutter gen-l10n` and `build_runner build`
# in both members, on a clean checkout:
#
#   * `git diff --exit-code`: a committed generated file (*.g.dart,
#     *.freezed.dart, app/lib/l10n/app_localizations*.dart) differs from what
#     the generators produce now;
#   * untracked files: the generators produced a file that is not committed.
#
# This only works because the generated files ARE committed (they are not
# gitignored, see .gitignore). Stop committing them and this check must go.
#
# Usage: tools/ci/check-generated.sh   (from anywhere inside the repo)
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
status=0

if ! git diff --exit-code --stat; then
  echo '::error::Generated code is out of date. Run `flutter gen-l10n` and `dart run build_runner build -d` in app/ and packages/gi_core_api/, then commit the result.'
  git diff --name-only | sed 's/^/  changed: /'
  status=1
fi

untracked="$(git ls-files --others --exclude-standard)"
if [[ -n "$untracked" ]]; then
  echo '::error::The generators produced files that are not committed (or the checkout was not clean):'
  sed 's/^/  untracked: /' <<<"$untracked"
  status=1
fi

if [[ $status -eq 0 ]]; then
  echo 'Generated code is up to date.'
fi
exit $status
