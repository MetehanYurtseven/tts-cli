{
  description = "Text-to-Speech CLI using OpenAI API";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.buildGoModule {
            pname = "tts-cli";
            version = self.shortRev or "dirty";
            src = ./.;

            vendorHash = "sha256-MRxf83fjVrIu7g2KU8S4BvWBkMfyE7y5g6NzEcEfpjk=";

            meta = with pkgs.lib; {
              description = "Text-to-Speech CLI using OpenAI API";
              homepage = "https://github.com/perbu/tts-cli";
              license = licenses.mit;
              platforms = platforms.unix;
              mainProgram = "tts-cli";
            };
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              go
              gopls
            ];

            shellHook = ''
              echo "tts-cli development environment"
              echo "Go version: $(go version)"
              echo ""
              echo "Don't forget to set OPENAI_API_KEY!"
            '';
          };
        }
      );
    };
}
