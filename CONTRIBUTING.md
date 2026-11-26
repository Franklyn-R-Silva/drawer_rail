# Contributing to drawer_rail

Thanks for stopping by. drawer_rail has one maintainer, so every bug report,
question and pull request helps, and none of them has to be perfect: a
two-line issue with a screenshot is enough to start.

- **Something broke, or you want a feature?**
  [Open an issue](https://github.com/Franklyn-R-Silva/drawer_rail/issues/new/choose).
  Only "what happened" is required.
- **A question, or not sure it is a bug?** Ask in
  [Discussions](https://github.com/Franklyn-R-Silva/drawer_rail/discussions/categories/q-a).
- **Want to write code or docs?** Pick an issue labelled
  [`good first issue`](https://github.com/Franklyn-R-Silva/drawer_rail/labels/good%20first%20issue)
  or [`help wanted`](https://github.com/Franklyn-R-Silva/drawer_rail/labels/help%20wanted),
  and leave a comment saying you are on it so nobody duplicates the work. An
  idea of your own is welcome too; for a large change, open an issue first so
  we can agree on the shape before you spend the time.

Please be kind ([Code of Conduct](CODE_OF_CONDUCT.md)), and report security
problems [privately](SECURITY.md), not in an issue.

## Your first contribution in 5 minutes

You need Git and **Flutter 3.32 or newer** — the oldest version
`pubspec.yaml` supports, and CI checks it. Any current stable works.

```sh
# Fork the repository on GitHub, then:
git clone https://github.com/<your-user>/drawer_rail.git
cd drawer_rail
flutter pub get          # also resolves example/

# The whole suite: widget tests, no device or emulator needed
flutter test

# The example app — the same one as the live demo. Hover needs a pointer,
# so a browser or desktop shows everything; a phone shows the touch side.
cd example
flutter run -d chrome
cd ..

git checkout -b fix/short-description
```

Make the change, add a test next to similar ones (see [Tests](#tests)), push
the branch and open a pull request. That's it: CI runs every other check.

### Before you push

These three catch nearly everything CI does (the full list is in
[What CI checks](#what-ci-checks)):

```sh
dart format .                  # auto-format
flutter analyze --fatal-infos  # static analysis; infos fail the build
flutter test                   # the whole suite
```

### After you open the pull request

- **First PR here?** GitHub holds the CI run until the maintainer approves it.
  That is GitHub's default for forks, not a judgement on your change.
- **CI goes red and you don't know why?** Say so in the PR. Help is part of the
  review.
- **No version bump, no changelog entry needed.** Both are written when a
  release is cut, and you are credited there.
- **A visual change?** A before/after screenshot or GIF in the PR description
  makes the review much faster.
- With *Allow edits by maintainers* checked, small fixups (a doc line, a test
  name) can be pushed onto your branch instead of going back and forth.
- Draft PRs are welcome when you want feedback early.

## Changing the code

### Where things live

```
lib/
  drawer_rail.dart              # Public library: exports everything in src/
  src/
    drawer_rail.dart            # The DrawerRail widget: panel, rail, search, hover, flyouts
    drawer_rail_controller.dart # DrawerRailController: collapsed, selection, groups, hover state
    drawer_rail_theme.dart      # DrawerRailTheme and its resolved form
    drawer_rail_labels.dart     # DrawerRailLabels: every user-facing string
    drawer_model.dart           # DrawerSection, DrawerLink, DrawerGroup, DrawerBadge
    animated_press_card.dart    # The press/hover card behind every item
test/
  drawer_rail_test.dart         # The suite, one `group` per class (see below)
example/
  lib/main.dart                 # The demo app, deployed as the live demo
  test/widget_test.dart         # Its smoke test
```

### Tests

Everything is in `test/drawer_rail_test.dart`, grouped by what it covers:
`DrawerBadge`, `DrawerRailLabels`, `DrawerRailController` (and its hover
groups), `DrawerRailTheme`, and `DrawerRail widget` for anything you can only
see by pumping the widget. Add yours to the matching group; a bug fix gets a
test that fails without the fix.

### Guidelines

- Keep the package **dependency-free** at runtime (Flutter SDK only).
- All **public** members need `///` documentation comments, in **English**
  (`public_member_api_docs` is on, and pub.dev scores dartdoc coverage).
- A new user-facing string goes in `DrawerRailLabels` (with `copyWith`, `==`
  and `hashCode`), never hard-coded in a widget.
- A new theme field goes in `DrawerRailTheme`, its `copyWith` and its resolved
  form, plus a row in the README table that says what visibly changes.
- Match the existing style; `analysis_options.yaml` is the source of truth.

### Commit messages

This project uses **Conventional Commits**: they keep the history readable and
make the next version bump obvious at a glance. Don't let it block you; a
title can be fixed before merge.

| Prefix | When to use | Version effect |
|---|---|---|
| `feat: ...` | New feature | minor bump |
| `fix: ...` | Bug fix | patch bump |
| `feat!: ...` | Breaking change | major bump |
| `docs: ...` | Documentation only | no bump |
| `test: ...` | Adding/fixing tests | no bump |
| `refactor: ...` | Refactor without behavior change | no bump |
| `chore: ...` / `ci: ...` | Maintenance, CI, tooling | no bump |

### What CI checks

Every PR runs these, and a PR is merged only when they are green:

| Check | What it runs |
|---|---|
| `check` | format, `flutter analyze --fatal-infos`, `flutter pub publish --dry-run` |
| `test (stable)` | the suite and the example's smoke test on stable Flutter |
| `test (beta)` | the same on the next Flutter |
| `min Flutter (3.32.0)` | analyze and the suite on the oldest Flutter `pubspec.yaml` claims |
| `pana` | pub.dev's scorer; fails on any pub point below the maximum (160/160) |
| `build demo` | builds the example for the web, as the live demo is built |
| `dependency review` | fails if the PR adds a package or action with a known vulnerability |
| `CodeQL` | GitHub's code scanning of the workflows; Dart is not a CodeQL language |

Actions in `.github/workflows/` are pinned to a full commit SHA with the version
as a trailing comment (`uses: owner/action@<sha> # vX.Y.Z`); Dependabot keeps
both up to date. A tag can be moved to point at other code; a SHA cannot.

## For maintainers

### Release process

1. In one commit, set `version:` in `pubspec.yaml`, add a section at the top of
   `CHANGELOG.md` crediting outside contributors, and update the
   `drawer_rail: ^x.y.z` line in the README.
2. Merge it, then push the tag:

   ```sh
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

   The `Release` workflow re-runs analyze and the tests, refuses a tag that
   does not match `pubspec.yaml`, publishes to pub.dev (automated publishing
   through the `pub.dev` environment, no secret involved), and then creates
   the GitHub Release from the changelog section plus GitHub's generated
   notes, grouped by PR label (`.github/release.yml`). Label PRs as they
   merge and the notes sort themselves.
3. Do not run `flutter pub publish` by hand: the tag does it, and a version
   already on pub.dev makes the workflow fail.

### Dependency updates

Dependabot opens PRs monthly for the GitHub Actions and for the pub dev
dependencies (package and example), each ecosystem grouped. Updates wait seven
days after a release, so a hijacked one is usually pulled before it reaches a
PR. They go through the same checks as anything else.

## License

By contributing, you agree that your contributions will be licensed under the
project's [MIT License](LICENSE).
