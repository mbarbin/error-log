## 0.0.9 (unreleased)

### Added

### Changed

- Upgrade to recent versions of `err0` and `loc0`.
- Reduce dependencies - remove `core` and `stdio`.
- Split test package.
- Use `Expect_test_helpers_base`.

### Deprecated

### Fixed

### Removed

## 0.0.8 (2024-08-22)

### Added

- Added compatibility with `commandlang` & direct style error handling.

### Changed

- Configure tests into a separate package.

## 0.0.7 (2024-07-26)

### Added

- Added dependabot config for automatically upgrading action files.
- Added `Error_log.am_running_test` to know when we're running `Error_log.For_test.report`.

### Changed

- Upgrade `ppxlib` to `0.33` - activate unused items warnings.
- Upgrade `ocaml` to `5.2`.
- Upgrade `dune` to `3.16`.
- Upgrade base & co to `0.17`.

## 0.0.6 (2024-03-13)

### Changed

- Uses `expect-test-helpers` (reduce core dependencies)
- Run `ppx_js_style` as a linter & make it a `dev` dependency.
- Upgrade GitHub workflows `actions/checkout` to v4.
- In CI, specify build target `@all`, and add `@lint`.
- List ppxs instead of `ppx_jane`.

## 0.0.5 (2024-02-14)

### Changed

- Upgrade dune to `3.14`.
- Build the doc with sherlodoc available to enable the doc search bar.

## 0.0.4 (2024-02-14)

### Added

- New tests to increase code coverage. Document workarounds currently employed to reach 100% coverage.

### Changed

- Improved and clarified api to recover from exceptions (breaking change).

### Removed

- Replaced `Error_log.try_with` by `Error_log.protect` and `Error_log.E`.

## 0.0.3 (2024-02-09)

### Added

- Setup `bisect_ppx` for test coverage.

### Changed

- Internal changes related to the release process.
- Upgrade dune and internal dependencies.

## 0.0.2 (2024-01-18)

### Changed

- Internal changes related to build and release process.

## 0.0.1 (2023-11-12)

Initial release.
