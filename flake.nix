{
  description = "mega-mount.yazi - A disk mount manager plugin for Yazi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        mega-mount-yazi = pkgs.stdenvNoCC.mkDerivation {
          pname = "mega-mount-yazi";
          version = "0.1.0";
          
          src = ./.;
          
          installPhase = ''
            runHook preInstall
            
            mkdir -p $out/share/yazi/plugins/mega-mount.yazi
            cp main.lua $out/share/yazi/plugins/mega-mount.yazi/
            
            runHook postInstall
          '';
          
          meta = with pkgs.lib; {
            description = "A disk mount manager plugin for Yazi";
            homepage = "https://github.com/guttermonk/mega-mount.yazi";
            license = licenses.mit;
            platforms = platforms.all;
          };
        };
      in
      {
        packages = {
          default = mega-mount-yazi;
          mega-mount-yazi = mega-mount-yazi;
        };
        
        overlays.default = final: prev: {
          yazi-plugins = (prev.yazi-plugins or {}) // {
            mega-mount = mega-mount-yazi;
          };
        };
      }
    ) // {
      overlays.default = final: prev: {
        yazi-plugins = (prev.yazi-plugins or {}) // {
          mega-mount = self.packages.${prev.system}.mega-mount-yazi;
        };
      };
    };
}