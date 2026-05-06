#!/usr/bin/env hy

(require hyrule.argmove [as-> doto])

(import argparse)
(import base64)
(import hashlib)
(import sys)

(defclass Formatter [argparse.RawTextHelpFormatter argparse.ArgumentDefaultsHelpFormatter])

(defn main []
  (setv
   parser
   (doto (argparse.ArgumentParser
          :description "Generate SRI hash of stdin, and then print the result to stdout\nSee https://www.w3.org/TR/SRI/#integrity-metadata"
          :formatter_class Formatter)
     (.add_argument "alg" :help "Hash algorithm to use" :choices ["sha256" "sha384" "sha512"])))
  (setv args (parser.parse_args))
  (setv alg args.alg)
  (as-> alg it
    (hashlib.file_digest sys.stdin.buffer it)
    (.digest it)
    (base64.b64encode it)
    (.decode it)
    (print (.format "{}-{}" alg it))))

(when (= __name__ "__main__")
  (main))
