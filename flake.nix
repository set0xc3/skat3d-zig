{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        # pkgs.renderdoc
        # pkgs.gpu-viewer

        # pkgs.vulkan-extension-layer
        # pkgs.vulkan-validation-layers
        # pkgs.vulkan-utility-libraries
        # pkgs.vulkan-headers
        # pkgs.vulkan-loader
        # pkgs.vulkan-tools
        # pkgs.vulkan-tools-lunarg
        # pkgs.glslang # Khronos reference front-end for GLSL and ESSL
        # pkgs.shaderc

        pkgs.glfw
        pkgs.libGL
        pkgs.xorg.libX11
      ];

      shellHook = ''
        exec $SHELL
      '';
    };
  };
}
