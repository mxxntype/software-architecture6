{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ ];
        pkgs = import nixpkgs { inherit system overlays; };
        inherit (pkgs) stdenv lib;

        buildInputs = with pkgs; [ openssl postgresql_17.lib ];
        nativeBuildInputs = with pkgs; [
          docker-compose-language-service
          mongosh
          neo4j
          pkg-config
          postgresql_17
          redis
          sqlx-cli
        ];

        envVars = { };

      in {
        devShells = let
          shellOverrides = if stdenv.isLinux then {
            stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.clangStdenv;
          } else
            { };
        in {
          default = pkgs.mkShell.override shellOverrides (envVars // {
            inherit buildInputs nativeBuildInputs;
            shellHook = ''
              # This hellish thing is needed to correctly *append* to the
              # system's $LD_LIBRARY_PATH instead of overwriting it (which
              # may cause external software to break).
              export LD_LIBRARY_PATH="''${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}${
                lib.makeLibraryPath buildInputs
              }"
            '';
          });
        };

        formatter = pkgs.nixfmt-classic;
      });
}
