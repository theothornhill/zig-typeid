(define-module
  #:use-module (guix git)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (guix modules)
  #:use-module (guix licenses)
  #:use-module (guix build-system)
  #:use-module (guix build-system zig)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages llvm-meta)
  #:use-module (gnu packages zig)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module ((guix licenses) #:prefix license:))


(define-public zig-typeid
  (let ((vcs-file? (or (git-predicate (string-append (current-source-directory) "/../.."))
                       (const #t))))
    (package
      (name "zig-typeid")
      (version "0.0.1-git")
      (source (local-file "../.." "zig-typeid" #:recursive? #t #:select? vcs-file?))
      (build-system zig-build-system)
      (arguments
       `(#:install-source? #f
         #:tests? #t))
      (inputs (list zig-0.13 zig-zls-0.13))
      (home-page "https://github.com/theothornhill/zig-typeid")
      (synopsis "Zig implementation the typeid spec")
      (description "Simple implementation over the typeid spec")
      (license license:bsd-2))))

zig-typeid
