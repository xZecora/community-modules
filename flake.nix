{
  description = "community maintained modules for finix - experimental, niche, and fast-moving modules live here";

  outputs =
    { self }:
    {
      nixosModules = builtins.mapAttrs (dir: _: ./modules/${dir}) (builtins.readDir ./modules);
    };
}
