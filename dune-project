(lang dune 3.17)

(name electrum)

(generate_opam_files true)

(source
 (github LeEmperor/electrum))

(authors "Bohdan Purtell <bohdanpurtell@gmail.com>")

(maintainers "Bohdan Purtell <bohdanpurtell@gmail.com>")

(package
 (name electrum)
 (synopsis "Protocol emulator ASIC written in Hardcaml")
 (description
   "Synthesizable protocol emulator blocks written in Hardcaml. Installs the wrapped RTL\nand ISA libraries plus a transport-independent host API and integrated-core simulator\nbackend.")
 (depends
  (ocaml
   (>= 5.1))
  (dune
   (>= 3.17))
   ; Installed owner libraries and their alias-only compatibility surface.
  ; tooling and must not be forced on a consumer. isa/ needs core alone: it holds the
  ; instruction specification and no circuit.
  core
  hardcaml
  ppx_hardcaml
  ppx_jane
  ; Test frameworks: test/ only. hardcaml_event_driven_sim carries the time-resolved
  ; pad driver P2.2/P2.6 need; Cyclesim can only change an input on a cycle boundary.
  (hardcaml_step_testbench :with-test)
  (hardcaml_waveterm :with-test)
  (hardcaml_event_driven_sim :with-test)
  (ppx_expect :with-test)
  (base_quickcheck :with-test)
  (alcotest :with-test)
   ; Repo tooling: asic/verif/observable/emit/generate.exe. Never installed, but needed for a root
  ; `dune build`, so they ride with-test rather than being dropped.
  (core_unix :with-test)
  (jane_rope :with-test)
  (hardcaml_asic :with-test)
  (ppx_js_style :with-dev-setup)
  (ocamlformat :with-dev-setup)
  (ocaml-lsp-server :with-dev-setup)))
