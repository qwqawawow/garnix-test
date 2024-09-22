{
  description = "Garnix CI BUILD";

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #nixpkgs.url = "https://mirrors.ustc.edu.cn/nix-channels/nixos-23.11/nixexprs.tar.xz";
    #nixpkgs.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-23.11/nixexprs.tar.xz";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-github-actions,
    }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];
      # Helper to provide system-specific attributes
      forAllSystems =
        f: nixpkgs.lib.genAttrs allSystems (system: f { pkgs = import nixpkgs { inherit system; }; });
    in
    {
      packages = forAllSystems (
        { pkgs }:
        {
          ncmpcpp-clang = (pkgs.callPackage ./ncmpcpp.nix { stdenv = pkgs.clangStdenv; });
          ncmpcpp = (pkgs.callPackage ./ncmpcpp.nix { });
        }
      );

      githubActions = nix-github-actions.lib.mkGithubMatrix {
        checks = nixpkgs.lib.getAttrs [
          "x86_64-linux"
          "aarch64-darwin"
        ] self.packages;
      };
    };
}
