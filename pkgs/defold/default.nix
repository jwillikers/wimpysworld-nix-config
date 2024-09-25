{
  copyDesktopItems,
  fetchurl,
  lib,
  makeDesktopItem,
  makeWrapper,
  stdenv,
  writeScript,
  freetype,
  git,
  jdk17,
  libGL,
  libX11,
  libXi,
  libXrender,
  libXtst,
  libXxf86vm,
  openal,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "defold";
  version = "1.9.3";

  src = fetchurl {
    url = "https://github.com/defold/defold/releases/download/${version}/Defold-x86_64-linux.tar.gz";
    hash = "sha256-JPPdiV4xP50i5Gq2QDqxpYjSrZ2ssGjft2w8vuQroKU=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    freetype
    git
    jdk17
    libGL
    libX11
    libXi
    libXrender
    libXtst
    libXxf86vm
    openal
    zlib
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    # Install Defold assets, but not the bundled JDK
    install -m 755 -D Defold $out/share/defold/Defold
    install -m 644 -D config $out/share/defold/config
    install -m 444 -D logo_blue.png $out/share/defold/logo_blue.png
    install -m 444 -D logo_blue.png \
        $out/share/icons/hicolor/512x512/apps/defold.png
    mkdir -p $out/share/defold/packages
    cp -a packages/*.jar $out/share/defold/packages/
    runHook postInstall
  '';

  # TODO:
  # - Add a launcher script so editor updates can be handled
  postFixup = ''
    # Devendor bundled JDK; it segfaults on NixOS
    ln -s ${jdk17} $out/share/defold/packages/${jdk17.name}
    sed -i 's|packages/jdk-17.0.5+8|packages/${jdk17.name}|' $out/share/defold/config
    # Wrap Defold:
    # - LD_LIBRARY_PATH so plugins in $HOME can load
    # - PATH so git is available for the editor
    mkdir -p $out/bin
    makeWrapper "$out/share/defold/Defold" "$out/bin/defold" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL libX11 libXtst libXxf86vm ]}" \
      --suffix PATH            : "${lib.makeBinPath [ git ]}"
  '';

  desktopItems = [(makeDesktopItem rec {
    name = "defold";
    desktopName = "Defold";
    keywords = [
      "Game"
      "Development"
    ];
    exec = "defold";
    terminal = false;
    type = "Application";
    icon = "defold";
    categories = [
      "Development"
      "IDE"
    ];
    startupNotify = true;
  })];

  passthru = {
    updateScript = writeScript "update-defold.sh" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p nix-update curl gnugrep

      version=$(curl -s https://api.github.com/repos/defold/defold/releases/latest | grep tag_name | grep -oP '(?<=": ")[^"]*')
      nix-update defold --version "$version"
    '';
  };

  meta = {
    description = "A completely free to use game engine for development of desktop, mobile and web games.";
    homepage = "https://www.defold.com";
    license = lib.licenses.free;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ flexiondotorg ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "defold";
  };
}