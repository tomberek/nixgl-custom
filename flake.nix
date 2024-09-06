{
  inputs.nixgl.url = "github:nix-community/nixGL";
  inputs.nixgl.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";

  outputs = inputs: {
    packages = builtins.mapAttrs (
      system: base:
      let
        pkgs = import base.path {
          inherit system;
          config.allowUnfree = true;
        };
        set = (
          pkgs.callPackage (inputs.nixgl + "/nixGL.nix") {

            nvidiaHash = "sha256-0cwgejoFsefl2M6jdWZC+CKc58CqOXDjSi4saVPNKY0=";
            nvidiaVersion = "560.31.02";

            # Look at /proc/driver/nvidia/version to get version
            # NVRM version: NVIDIA UNIX x86_64 Kernel Module  560.31.02  Tue Jul 30 21:02:43 UTC 2024
            # GCC version:  gcc version 13.3.0 (GCC)
            #
            # Invalidate the hash by chaning one of the characters and copying
	    # TODO: Obtain hashes for all the versions and allow clients
	    # to specify the verison with client-side logic
          }
        );
      in
      if system == "x86_64-linux" || system == "aarch64-linux"
      then set // { default = set.nixGLCommon set.nixGLNvidia;}
      else {default = base.writeScriptBin "nixGL" "echo nixGL-custom not supported on darwin";}
    ) inputs.nixgl.inputs.nixpkgs.legacyPackages;
  };
}
