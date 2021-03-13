{ pkgs ? import <nixpkgs> {} }:

let
  pursPkgs = import (
    pkgs.fetchFromGitHub {
      owner = "justinwoo";
      repo = "easy-purescript-nix";
      rev = "3b4039475c245243716b1e922455a9062c0531da";
      sha256 = "0fk2r02z86rirg5kggd0vvcgp8h07w7fhp03xng7wjrifljxwann";
    }
  ) {
    inherit pkgs;
  };

in
pkgs.mkShell {
  buildInputs = [ 
    pkgs.nodePackages.parcel-bundler
    pursPkgs.purs-0_13_8 
    pursPkgs.spago 
    pursPkgs.purty 
  ];
}
