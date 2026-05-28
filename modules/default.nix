let
  programModules = builtins.mapAttrs (dir: _: ./programs/${dir}) (
    builtins.removeAttrs (builtins.readDir ./programs) [
      "README.md"

      # included by default
      "pipewire"
    ]
  );

  serviceModules = builtins.mapAttrs (dir: _: ./services/${dir}) (
    builtins.removeAttrs (builtins.readDir ./services) [
      "README.md"

      # included by default
    ]
  );
in
{
  default = {
    # Modules included by default go here. everything else is manually imported by the end user.
    imports = [ ./programs/pipewire ];
  };
}
// programModules
// serviceModules
