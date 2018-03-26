with import <nixpkgs> {};
let
in stdenv.mkDerivation rec {
  name = "faustbind";
  buildInputs = [
    jack2Full
    pkgs.gcc7
    llvm_5
    libffi
    libvisual
    gmp
    alsaLib
    pkgconfig
    boehmgc
    rtmidi
    faust2

    glib

  ];


  shellHook = ''
export PATH=$PATH:/home/jmsb/exps/langs/lisp/common/compilec/c-mera

'';
}
#
