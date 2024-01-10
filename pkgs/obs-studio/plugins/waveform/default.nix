{ stdenv
, lib
, fetchFromGitHub
, cmake
, obs-studio
, pkg-config
, fftwFloat
}:

stdenv.mkDerivation rec {
  pname = "waveform";
  version = "1.8.0-beta1";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "phandasm";
    repo = "waveform";
    rev = "v${version}";
    sha256 = "sha256-K0vD6jbl4FT3bcw/Axciy7cp3dQzK6gYmFKbm+6QvKc=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  postInstall = ''
    mkdir -p $out/lib $out/share/obs/obs-plugins/${pname}/
    mv $out/${pname}/bin/64bit $out/lib/obs-plugins
    mv $out/${pname}/data/* $out/share/obs/obs-plugins/${pname}/
    rm -rf $out/${pname}
  '';

  buildInputs = [
    obs-studio
    fftwFloat
  ];

  meta = {
    description = "Audio spectral analysis plugin for OBS";
    homepage = "https://github.com/phandasm/waveform";
    maintainers = with lib.maintainers; [ flexiondotorg matthewcroughan ];
    license = lib.licenses.gpl3;
    platforms = ["x86_64-linux"];
  };
}
