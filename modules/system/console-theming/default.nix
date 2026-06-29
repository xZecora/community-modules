{ lib, config, ... }:
let
  cfg = config.hardware.console;

  makeColor = i: lib.concatMapStringsSep "," (x: "0x" + lib.substring (2 * i) 2 x);
in
{
  options = {
    hardware.console = {

      colors = lib.mkOption {
        type = with lib.types; listOf (strMatching "[[:xdigit:]]{6}");
        default = [ ];
        example = [
          "002b36"
          "dc322f"
          "859900"
          "b58900"
          "268bd2"
          "d33682"
          "2aa198"
          "eee8d5"
          "002b36"
          "cb4b16"
          "586e75"
          "657b83"
          "839496"
          "6c71c4"
          "93a1a1"
          "fdf6e3"
        ];
        description = ''
          The 16 colors palette used by the virtual consoles.
          Leave empty to use the default colors.
          Colors must be in hexadecimal format and listed in
          order from color 0 to color 15.
        '';
      };
    };
  };

  config = lib.mkIf (cfg.colors != [ ]) {
    boot.kernelParams = [
      "vt.default_red=${makeColor 0 cfg.colors}"
      "vt.default_grn=${makeColor 1 cfg.colors}"
      "vt.default_blu=${makeColor 2 cfg.colors}"
    ];
  };
}
