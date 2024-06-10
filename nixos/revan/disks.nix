# nvme0n1 512GB: NixOS
# nvme1n1 1TB:   Home
_: {
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Force_MP600_204782310001285413F8";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              start = "0%";
              end = "1024MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountOptions = [ "defaults" "umask=0077" ];
                mountpoint = "/boot";
              };
            };
            root = {
              start = "1024MiB";
              end = "100%";
              content = {
                type = "filesystem";
                # Overwirte the existing filesystem
                extraArgs = [ "-f" ];
                format = "xfs";
                mountpoint = "/";
                mountOptions = [ "defaults" ];
              };
            };
          };
        };
      };
    };
  };
}
