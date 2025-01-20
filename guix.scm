(use-modules (guix git)
             (guix gexp)
             (guix git-download)
             (guix utils)
             (guix download)
             (guix packages)
             (guix modules)
             (guix licenses)
             (guix build-system)
             (guix build-system zig)
             (guix build-system copy)
             (gnu packages)
             (gnu packages llvm)
             (gnu packages llvm-meta)
             (gnu packages zig)
             (gnu packages base)
             (gnu packages compression)
             ((guix licenses) #:prefix license:))

(define vcs-file?
  ;; Return true if the given file is under version control.
  (or (git-predicate (current-source-directory))
      (const #t)))

(package
 (name "zig-typeid")
 (version "0.0.1")
 (source (local-file "." "zig-typeid" #:recursive? #t #:select? vcs-file?))
 (build-system zig-build-system)
 (arguments
  `(#:install-source? #f
    #:tests? #t))
 (home-page "https://ziglang.org/")
 (synopsis "General-purpose programming language and toolchain")
 (description "Zig is a general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software.")
 (license license:bsd-2))
