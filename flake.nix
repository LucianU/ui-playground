{
  description = "Code with UI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, treefmt-nix }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages."${system}";
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs.elmPackages; [
              elm
            ];
          };
        }
      );

      formatter = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages."${system}";
        in
        treefmt-nix.lib.mkWrapper
          pkgs
          {
            projectRootFile = "flake.nix";
            programs.nixpkgs-fmt.enable = true;
            programs.elm-format.enable = true;
          }
      );
    };
}
