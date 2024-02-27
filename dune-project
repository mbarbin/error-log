(lang dune 3.14)

(name error-log)

(generate_opam_files)

(license MIT)

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin")

(source
 (github mbarbin/error-log))

(documentation "https://mbarbin.github.io/error-log/")

(package
 (name error-log)
 (synopsis "Reporting located errors and warnings")
 (depends
  (ocaml
   (>= 5.1))
  (base
   (and
    (>= v0.16)
    (< v0.17)))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (core
   (and
    (>= v0.16)
    (< v0.17)))
  (core_unix
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (expect_test_helpers_core
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (loc
   (>= 0.0.2))
  (pp
   (>= 1.2.0))
  (pp-extended
   (>= 0.0.2))
  (ppx_compare
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_enumerate
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_expect
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (ppx_hash
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_here
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_js_style
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_let
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_conv
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_value
   (and
    (>= v0.16)
    (< v0.17)))
  (stdio
   (and
    (>= v0.16)
    (< v0.17)))
  (stdune
   (>= 3.14))))
