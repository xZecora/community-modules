let
  programModules = builtins.mapAttrs (dir: _: ./programs/${dir}) (
    builtins.removeAttrs (builtins.readDir ./programs) [
      "README.md"

      # default modules
      "pipewire"
    ]
  );

  serviceModules = builtins.mapAttrs (dir: _: ./services/${dir}) (
    builtins.removeAttrs (builtins.readDir ./services) [
      "README.md"

      # included by default
      "amnezia-vpn"
    ]
  );

in
{
  default = {
    # Modules included by default go here
    imports = [
      ./programs/pipewire
      ./services/amnezia-vpn
    ];
  };
}
// programModules
// serviceModules
