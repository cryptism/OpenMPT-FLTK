{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ cmake ninja gnumake rsync pkg-config gcc python3 wayland-scanner ];
  buildInputs = with pkgs; [
    zlib alsa-lib libpulseaudio
    xorg.libX11 xorg.libXext xorg.libXft xorg.libXinerama xorg.libXcursor xorg.libXrender xorg.libXfixes
    wayland wayland-protocols libxkbcommon libdecor
    pango cairo dbus libpng libjpeg libGL libGLU
  ];
}
