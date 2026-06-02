{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.turnstiled;

  package = pkgs.callPackage ./package.nix { };
in
{
  options.services.turnstiled = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable [turnstilel](${pkgs.turnstile.meta.homepage}).
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = package;
      description = ''
        The package to use for `turnstile`.
      '';
    };

		configFile = lib.mkOption {
			type = lib.types.path;
			default = "/etc/turnstiled.conf";
			description = "Configuration file location for tunrstiled";
		};

		systemBootDir = lib.mkOption {
			type = lib.types.path;
			default = "/usr/lib/dinit.d/user/boot.d";
			description = "Location of boot services used for all users";
		};
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package pkgs.dinit ];

		finit.tmpfiles.rules = [
			"d ${cfg.systemBootDir} 0777"
		];

		environment.etc = {
			"turnstile/turnstiled.conf".text = ''
debug = yes
backend = dinit
debug_stderr = yes
linger = no
rundir_path = /run/user/%u
manage_rundir = no
export_dbus_address = yes
login_timeout = 0
root_session = no
			'';

			"turnstile/backend/dinit.conf".text = ''
boot_dir="$HOME/.config/dinit.d/boot.d"
system_boot_dir="${cfg.systemBootDir}"
services_dir1="$HOME/.config/dinit.d"
services_dir2="/etc/dinit.d/user"
services_dir3="/usr/local/lib/dinit.d/user"
services_dir4="/usr/lib/dinit.d/user"
			'';

			"pam.d/turnstiled".text = ''auth		sufficient	pam_rootok.so
session		optional	pam_keyinit.so force revoke
session		optional	pam_umask.so usergroups umask=022
-session	optional	pam_elogind.so
session		required  pam_env.so conffile=/etc/security/pam_env.conf readenv=1 # env (order 10100)
session		required	${cfg.package}/pam/pam_turnstile.so turnstiled
session		required	pam_limits.so
'';
		};

		security.pam.services = lib.mkMerge [ 
			{
				login.text = "session optional ${cfg.package}/pam/pam_turnstile.so";
			}
		];

    finit.services.turnstiled = {
      description = "turnstiled, a user-service manager manager";
      command = "${cfg.package}/bin/turnstiled";
      conditions = "service/syslogd/ready";
      log = false;
			path = [ cfg.package pkgs.dinit ];
    };
  };
}
