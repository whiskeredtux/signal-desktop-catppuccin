# Catppuccin mocha theme for [Signal](https://signal.org) on NixOS

> A dark theme for [Signal desktop](https://signal.org).

Inspired by [Catppuccin themes for Signal Desktop](https://github.com/CalfMoon/signal-desktop).

Based on [Dracula theme for Signal Desktop](https://github.com/dracula/signal-desktop).

![Screenshot](./screenshot.png)

## Install

Make sure to have signal-desktop installed, then add the following to your inputs section in flake.nix:
```
signal-desktop-catppuccin = {
  url = "github:whiskeredtux/signal-desktop-catppuccin";
  inputs.nixpkgs.follows = "nixpkgs";
};
```
In the outputs section, add a let block and an overlay like so:
```
  outputs = inputs@{ self, nixpkgs, ... }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    catppuccinOverlay = final: prev: {
      signal-desktop = prev.signal-desktop.overrideAttrs (old: {
        nativeBuildInputs =
          (old.nativeBuildInputs or [])
          ++ [ final.asar ];
        postInstall = (old.postInstall or "") + ''
          tmp="$(mktemp -d)"
          trap 'rm -rf "$tmp"' EXIT
          asar e \
            "$out/share/signal-desktop/app.asar" \
            "$tmp"
          cp \
            ${inputs.signal-desktop-catppuccin}/sample/themes.css \
            "$tmp/stylesheets/themes.css"
          {
            printf '%s\n' '@import "themes.css";'
            cat "$tmp/stylesheets/manifest.css"
          } > "$tmp/stylesheets/manifest.css.new"
          mv \
            "$tmp/stylesheets/manifest.css.new" \
            "$tmp/stylesheets/manifest.css"
          asar p \
            "$tmp" \
            "$tmp/app.asar"
          mv \
            "$tmp/app.asar" \
            "$out/share/signal-desktop/app.asar"
        '';
      });
    };
  in {
    nixosConfigurations = {
      <hostname> = nixpkgs.lib.nixosSystem {
        [ ... ]
        modules = [
          {
            nixpkgs.overlays = [ catppuccinOverlay ];
          }
        ];
      };
    };
  };
```
`nix flake update && sudo nixos-rebuild switch --flake .#<hostname>`
There you go :)

## License

[MIT License](./LICENSE)
