# error-log

[![CI Status](https://github.com/mbarbin/error-log/workflows/ci/badge.svg)](https://github.com/mbarbin/error-log/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/mbarbin/error-log/badge.svg?branch=main)](https://coveralls.io/github/mbarbin/error-log?branch=main)

:warning: This project is no longer being maintained or extended. I have migrated to a slightly different version of this where the error log mutates a global state instead. See [Err](https://github.com/mbarbin/pp-log/blob/main/lib/err/src/err.mli). The repository will be archived and made read-only.

`Error_log` is a library for programs that process user programs and report located errors and warnings (compilers, interpreters, etc.)

The canonical syntax for an error produced by this lib is:

```text
File "my-file", line 42, character 11-15:
Error: Some message that gives a general explanation of the issue.
Followed by more details, perhaps some sexps, etc.
((A sexp)(with more)(details)
  (such_as
   (extra_values)))
```

It is inspired by dune's user_messages and uses dune's error message rendering under the hood.

## Code Documentation

The code documentation of the latest release is built with `odoc` and published to `GitHub` pages [here](https://mbarbin.github.io/error-log).
