{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  cargo-tauri,
  nodejs,
  npmHooks,
  fetchNpmDeps,
  pkg-config,
  jq,
  moreutils,
  wrapGAppsHook3,
  writeText,
  # Tauri/GTK deps
  openssl,
  webkitgtk_4_1,
  glib-networking,
  gtk3,
  libappindicator-gtk3,
  librsvg,
  # Project deps
  hidapi,
  libusb1,
  systemd,
  dbus,
  # Runtime deps for downloaded plugin binaries (generic Linux, via nix-ld)
  glib,
  libxkbcommon,
  # CLI tools needed by plugins at runtime
  pulseaudio,
  wireplumber,
  pipewire,
}:

let
  udevRules = writeText "40-streamdeck.rules" ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0060", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0063", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="006c", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="006d", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0080", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0084", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0086", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="008f", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0090", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00b3", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="009a", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00a5", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00b8", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00b9", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00ba", MODE="0660", TAG+="uaccess"

    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0060", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0063", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="006c", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="006d", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0080", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0084", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0086", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="008f", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0090", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00b3", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="009a", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00a5", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00b8", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00b9", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00ba", MODE="0660", TAG+="uaccess"
  '';
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "opendeck";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "nekename";
    repo = "OpenDeck";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BOqT+Kgt5JmJIDuTC76aXc3AxGF16uOFdmWPlBPpstk=";
    fetchSubmodules = true;
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    postPatch = "cp ${./package-lock.json} package-lock.json";
    hash = "sha256-kpx5i7lRrAhanmX092ud4i2KRmnN9BvHegN5VVpIclM=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = "src-tauri";
  cargoHash = "sha256-DTyeVoocYCj8fO3veUj2kMLp1r9mWViH7Zl8T3Vdqxw=";

  postPatch = ''
    # Add npm lock file (project uses deno, we use npm for nix build)
    cp ${./package-lock.json} package-lock.json

    # Replace deno build command with npx
    jq '.build.beforeBuildCommand = "npx vite build"' src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json

    # Disable updater artifacts
    jq '.bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json

    # Simplify build.rs to skip deno-based plugin building
    cat > src-tauri/build.rs << 'EOF'
    fn main() {
        // Create empty plugins dir so resource bundling doesn't fail
        let _ = std::fs::create_dir_all("target/plugins");
        built::write_built_file().expect("failed to acquire build-time information");
        tauri_build::build();
    }
    EOF
  '';

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
    cargo-tauri.hook
    jq
    moreutils
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    openssl
    webkitgtk_4_1
    glib-networking
    gtk3
    libappindicator-gtk3
    librsvg
    hidapi
    libusb1
    systemd
    dbus
  ];

  doCheck = false;

  preFixup = ''
    gappsWrapperArgs+=(
      # Dynamically loaded libraries (dlopen)
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libappindicator-gtk3
          hidapi
          libusb1
          systemd
        ]
      }"
      # Node.js for JS-based plugins, plus CLI tools plugins need
      --prefix PATH : "${
        lib.makeBinPath [
          nodejs
          pulseaudio
          wireplumber
          pipewire
        ]
      }"
      # nix-ld setup so downloaded plugin binaries (generic Linux) can run
      --set NIX_LD "${stdenv.cc.bintools.dynamicLinker}"
      --prefix NIX_LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          stdenv.cc.cc.lib
          glib
          systemd
          dbus
          openssl
          libxkbcommon
        ]
      }"
    )
  '';

  postInstall = ''
    # Install udev rules (not included in the deb bundle extraction)
    install -Dm644 ${udevRules} $out/lib/udev/rules.d/40-streamdeck.rules
  '';

  meta = {
    description = "Desktop application for Elgato Stream Deck with official SDK plugin support";
    homepage = "https://github.com/nekename/OpenDeck";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "opendeck";
  };
})
