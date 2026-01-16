# Nix Usage Guide

This document provides information about using `tts-cli` with Nix and NixOS.

## Usage (As Flake)

### Adding as Flake Input

Add to your `flake.nix`:
```nix
{
  inputs.tts-cli.url = "github:MetehanYurtseven/tts-cli";
}
```

### Direct Usage in NixOS

Use directly in your system configuration:
```nix
{ inputs, pkgs, ... }:

{
  environment.systemPackages = [
    inputs.tts-cli.packages.${pkgs.system}.default
  ];
}
```

### As Overlay

Apply as an overlay to nixpkgs:
```nix
{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      tts-cli = inputs.tts-cli.packages.${prev.system}.default;
    })
  ];

  # Now use it like any other package
  environment.systemPackages = [
    pkgs.tts-cli
  ];
}
```

### In Home Manager

```nix
{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.tts-cli.packages.${pkgs.system}.default
  ];
}
```

## Advanced Example

### Wrapper Script with Toggle Functionality

This example creates a wrapper that can start and stop clipboard reading with the same command.
```nix
{ pkgs, ... }:
let
  read-clipboard = pkgs.writeShellScriptBin "read-clipboard" ''
    PIDFILE="$XDG_RUNTIME_DIR/read-clipboard.pid"
    if [ -f "$PIDFILE" ]; then
      kill $(cat "$PIDFILE") 2>/dev/null
      rm -f "$PIDFILE"
      exit 0
    fi
  
    export OPENAI_API_KEY=$(cat /run/secrets/openai_api_key)
    ${pkgs.wl-clipboard}/bin/wl-paste | ${pkgs.tts-cli}/bin/tts-cli -o /dev/stdout | ${pkgs.mpv}/bin/mpv - &
    MPV_PID=$!
    echo $MPV_PID > "$PIDFILE"
    wait $MPV_PID
    rm -f "$PIDFILE"
  '';
in
{
  home.packages = [
    pkgs.tts-cli
    pkgs.mpv
    read-clipboard
  ];
}
```

### Hyprland Integration

Bind the wrapper to a keyboard shortcut:
```nix
wayland.windowManager.hyprland.settings.bind = [
  "$mod, R, exec, ${read-clipboard}/bin/read-clipboard"
];
```
Press `$mod + R` once to start reading your clipboard, press again to stop.

Full example: [hyprland.nix](https://github.com/MetehanYurtseven/nixos/blob/main/hosts/desktop/hyprland.nix)

## Development

### Building

Clone the repository and build:
```bash
git clone https://github.com/MetehanYurtseven/tts-cli.git
cd tts-cli
nix build
```
The binary will be available at `result/bin/tts-cli`.

### Dev-Shell

Enter the development shell with all required dependencies:
```bash
nix develop
```
