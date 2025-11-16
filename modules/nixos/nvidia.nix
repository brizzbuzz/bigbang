{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.host.gpu.nvidia.enable {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      # Enable modesetting for Wayland compatibility
      modesetting.enable = true;

      # Disable power management to avoid cache misses
      powerManagement.enable = false;
      powerManagement.finegrained = false;

      # Use proprietary driver for better cache availability
      open = false;

      # Enable nvidia-settings GUI
      nvidiaSettings = true;

      # Use stable driver instead of production for better cache hits
      # The stable driver is more likely to have cached builds
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Ensure NVIDIA libraries are available in the system path
    # This helps with CUDA applications and reduces rebuild needs
    environment.systemPackages = with pkgs; [
      # Core NVIDIA packages that are commonly cached
      nvidia-vaapi-driver
      nvtopPackages.nvidia
    ];

    # Add NVIDIA-specific environment variables for better compatibility
    environment.sessionVariables = {
      # Enable NVIDIA VAAPI driver
      NVD_BACKEND = "direct";
      # Ensure proper CUDA library paths
      CUDA_CACHE_PATH = "$HOME/.cache/cuda";
    };

    # Configure OpenGL settings for NVIDIA
    hardware.opengl = {
      enable = true;

      # Use stable Mesa packages for better cache availability
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    # Optimize for server workloads (since ganymede is a server)
    boot.kernelParams = [
      # Enable NVIDIA persistence mode for server workloads
      "nvidia.NVreg_EnablePCIeGen3=1"
      # Reduce NVIDIA driver verbosity to improve boot times
      "nvidia.NVreg_RegistryDwords=EnableBrightnessControl=0"
    ];
  };
}
