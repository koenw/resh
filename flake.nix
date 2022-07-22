{
  description = "resh is a shell that only allows the execution of previously whitelisted commands.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
      forAllSystems  = nixpkgs.lib.genAttrs supportedSystems;
      overlays = [ (import rust-overlay) ];
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system overlays; });
    in
  {
    devShells = forAllSystems (system:
      let
        pkgs = nixpkgsFor.${system};
        rustPlatform = pkgs.makeRustPlatform {
          cargo = pkgs.rust-bin.stable.latest.default;
          rustc = pkgs.rust-bin.stable.latest.default;
        };
      in
      {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gcc
            rust-bin.stable.latest.default
          ];
          shellHook = ''
            echo "Welcome to the resh development shell."
            user_shell=$(getent passwd "$(whoami)" |cut -d: -f 7)
            exec "$user_shell"
          '';
        };
      }
    );
  };
}
