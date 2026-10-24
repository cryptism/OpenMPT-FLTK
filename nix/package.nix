{ lib
, stdenv
, src
, version ? "unstable"
, cmake
, ninja
, gnumake
, rsync
, pkg-config
, python3
, wayland-scanner
, wrapGAppsHook3
, gtk3
, zlib
, alsa-lib
, libpulseaudio
, libx11
, libxext
, libxft
, libxinerama
, libxcursor
, libxrender
, libxfixes
, wayland
, wayland-protocols
, libxkbcommon
, libdecor
, pango
, cairo
, dbus
, libpng
, libjpeg
, libGL
, libGLU
}:

stdenv.mkDerivation {
  pname = "openmpt-fltk";
  inherit version src;

  nativeBuildInputs = [ cmake ninja gnumake rsync pkg-config python3 wayland-scanner wrapGAppsHook3 ];

  buildInputs = [
    zlib alsa-lib libpulseaudio
    libx11 libxext libxft libxinerama libxcursor libxrender libxfixes
    wayland wayland-protocols libxkbcommon libdecor
    # FLTK's native file chooser loads GTK 3 at run time; it aborts without its GSettings schemas,
    # which wrapGAppsHook3 puts on XDG_DATA_DIRS
    gtk3
    pango cairo dbus libpng libjpeg libGL libGLU
  ];

  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];

  # The build also compiles the openmpt/ submodule (libopenmpt) with its own Makefile.
  ninjaFlags = [ "OpenMPT" ];

  preConfigure = ''
    for dir in fltk openmpt; do
      if [ ! -e "$dir/CMakeLists.txt" ] && [ ! -e "$dir/Makefile" ]; then
        echo "the $dir/ submodule is empty: fetch this flake with ?submodules=1," >&2
        echo "e.g. nix build 'git+https://github.com/cryptism/OpenMPT-FLTK?ref=drude&submodules=1'" >&2
        exit 1
      fi
    done
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/OpenMPT $out/bin/OpenMPT
    install -Dm644 $src/LICENSE $out/share/licenses/openmpt-fltk/LICENSE
    runHook postInstall
  '';

  meta = {
    description = "A native FLTK port of the OpenMPT tracker";
    homepage = "https://github.com/not-magic/OpenMPT-FLTK";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "OpenMPT";
  };
}
