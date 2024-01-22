(lang dune 3.13)

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
  (core
   (and
    (>= v0.16)
    (< v0.17)))
  (expect_test_helpers_core
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (loc
   (>= 0.0.1))
  (pp
   (>= 1.2.0))
  (pp-extended
   (>= 0.0.1))
  (ppx_jane
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_js_style
   (and
    (>= v0.16)
    (< v0.17)))
  (stdio
   (and
    (>= v0.16)
    (< v0.17)))
  (stdune
   (>= 3.13))))
