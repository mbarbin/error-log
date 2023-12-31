# error-log

[![CI Status](https://github.com/mbarbin/error-log/workflows/ci/badge.svg)](https://github.com/mbarbin/error-log/actions/workflows/ci.yml)
[![Deploy odoc Status](https://github.com/mbarbin/error-log/workflows/deploy-odoc/badge.svg)](https://github.com/mbarbin/error-log/actions/workflows/deploy-odoc.yml)

`Error_log` is a library for programs that process user programs and report
located errors and warnings (compilers, interpreters, etc.)

The canonical syntax for an error produced by this lib is:

```text
File "my-file", line 42, character 11-15:
Error: Some message that gives a general explanation of the issue.
Followed by more details, perhaps some sexps, etc.
((A sexp)(with more)(details)
  (such_as
   (extra_values)))
```

It is inspired by dune's user_messages and uses dune's error message rendering
under the hood.
