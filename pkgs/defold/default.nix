# default.nix
{ addDriverRunpath,
  buildFHSEnv,
  copyDesktopItems,
  fetchurl,
  lib,
  makeDesktopItem,
  makeWrapper,
  stdenv,
  writeScript,
  cairo,
  fontconfig,
  freetype,
  gdk-pixbuf,
  git,
  glib,
  gnused,
  gobject-introspection,
  gtk3,
  jdk17,
  libGL,
  libGLU,
  libX11,
  libXcursor,
  libXext,
  libXi,
  libXrandr,
  libXrender,
  libXtst,
  libXxf86vm,
  openal,
  pango,
  zlib,
  uiScale ? "1.0",
}:
let
  inherit (lib) optionalAttrs;
  pname = "defold";
  version = "1.9.3";

  defold = stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/defold/defold/releases/download/${version}/Defold-x86_64-linux.tar.gz";
      hash = "sha256-C/cUUe8BnedAkDtwvLE8lM3NQ7T6G2TMDjXw8salfhI=";
    };

    dontBuild = true;
    dontConfigure = true;
    dontStrip = true;

    nativeBuildInputs = [
      addDriverRunpath
      copyDesktopItems
      gnused
      (jdk17.override {
        enableJavaFX = true;
      })
      makeWrapper
    ];

    installPhase = ''
      runHook preInstall
      # Install Defold assets, but not the bundled JDK
      install -m 755 -D Defold $out/share/defold/Defold
      install -m 644 -D config $out/share/defold/config
      install -m 444 -D logo_blue.png $out/share/defold/logo_blue.png
      install -m 444 -D logo_blue.png \
          $out/share/icons/hicolor/512x512/apps/defold.png
      mkdir -p $out/share/defold/packages
      cp -a packages/defold-*.jar $out/share/defold/packages/
      runHook postInstall
    '';

    postFixup = ''
      # Devendor bundled JDK; it segfaults on NixOS
      JDK_VER=$(sed -n 's/.*\/\(jdk-[^/]*\).*/\1/p' $out/share/defold/config)
      ln -s ${jdk17} $out/share/defold/packages/${jdk17.name}
      sed -i "s|packages/$JDK_VER|packages/${jdk17.name}|" $out/share/defold/config
      # Disable editor updates; Nix will handle updates
      sed -i 's/\(channel = \).*/\1/' $out/share/defold/config
      # Scale the UI
      sed -i "s|^linux =|linux = -Dglass.gtk.uiScale=${uiScale}|" $out/share/defold/config
      addDriverRunpath $out/share/defold/Defold
      makeWrapper "$out/share/defold/Defold" "$out/bin/Defold"
    '';

    desktopItems = [
      (makeDesktopItem rec {
        name = "defold-editor";
        desktopName = "Defold";
        keywords = [
          "Game"
          "Development"
        ];
        exec = "Defold";
        terminal = false;
        type = "Application";
        icon = "defold";
        categories = [
          "Development"
          "IDE"
        ];
        startupNotify = true;
      })
    ];
  };
in
buildFHSEnv {
  name = pname;
  targetPkgs = pkgs: [
    cairo
    defold
    fontconfig
    freetype
    gdk-pixbuf
    git
    glib
    gobject-introspection
    gtk3
    libGL
    libGLU
    libX11
    libXcursor
    libXext
    libXi
    libXrandr
    libXrender
    libXtst
    libXxf86vm
    openal
    pango
    zlib
  ];
  runScript = "Defold";
  passthru = {
    updateScript = writeScript "update.sh" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq nix-update
      version=$(curl -s https://d.defold.com/editor-alpha/info.json | jq -r .version)
      nix-update defold --version "$version"
    '';
  };

  meta = {
    description = "The game engine for high-performance cross-platform games";
    homepage = "https://www.defold.com";
    license = lib.licenses.free;
    longDescription = ''
      Defold is a completely free to use game engine for development of desktop, mobile, console and web games.
    '';
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ flexiondotorg ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "defold";
  };
}
