{
  description = "dracula theme for signal";

  inputs = {
  };

  outputs =
    { self, nixpkgs }:
    {

      overlays = f: p: {
        signal-desktop =
          let
            style = ./sample/themes.css;
            name = "signal-desktop-dracula";
            version = p.signal-desktop.version;
            src = p.signal-desktop.src;
            asarSource = "share/signal-desktop/app.asar";
            styleSource = "stylesheets/manifest.css";
          in
          p.stdenv.mkDerivation (f: {
            inherit name version src;
            nativeBuildInputs = with p; [
              makeWrapper
              asar
            ];
            installPhase = ''
              	           mkdir -p $out/share
                           cp -r ${p.signal-desktop}/share/* $out/share/

                           asar e $out/${asarSource} $out/share/temp
                           cat ${style} >> $out/share/temp/${styleSource}
                           asar p $out/share/temp $out/app_custom.asar

              		   mkdir -p $out/bin
                           makeWrapper '${p.lib.getExe p.electron_41}' "$out/bin/signal-desktop" \
                        	--add-flags "$out/app_custom.asar" \
                                --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
                                --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
                            	'';
            desktopItems = [
              (p.makeDesktopItem {
                name = "signal";
                desktopName = "Signal";
                exec = "signal-desktop %U";
                type = "Application";
                terminal = false;
                icon = "signal-desktop";
                comment = "Private messaging from your desktop";
                startupWMClass = "signal";
                mimeTypes = [
                  "x-scheme-handler/sgnl"
                  "x-scheme-handler/signalcaptcha"
                ];
                categories = [
                  "Network"
                  "InstantMessaging"
                  "Chat"
                ];
              })
            ];

          });
      };

    };
}
