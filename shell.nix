{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
	nativeBuildInputs = with pkgs.buildPackages; [
		bmake
		ldc
		ncurses
	];
	shellHook = "alias make=bmake";
}
