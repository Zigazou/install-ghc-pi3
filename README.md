install-ghc-pi3
===============

This shell script installs GHC 7.10.3 on a Raspberry Pi 3 (with Raspbian).

It tries to correct the following problem:

- installation of Jessie Backports (for which the public keys are not installed by default)
- setting default global parameters for ghc (ghc does not use valid architecture/CPU settings making it impossible to compile programs)

Requirements
------------

These are required:

- Raspbian 32 bits (armv7l architecture, it does not work for 64 bits OS)
- Internet connection
- root access

Running the script
------------------

On a Raspberry Pi 3 command line:

    sudo bash install-ghc-pi3.bash
