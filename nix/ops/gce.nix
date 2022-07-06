let
credentials = {
  project = "pollparty-io";
  serviceAccount = "966718626886-compute@developer.gserviceaccount.com";
  accessKey = toString ../../secret/pollparty-io-61706721da84.json;
};
free-tier = credentials // {
  region = "us-east1-b";
  instanceType = "e2-micro";
  rootDiskSize = 30;
  scheduling.preemptible = false;
};
img = "gs://pollparty-imgs/nixos-image-21.11.335526.6c4b9f1a2fd-x86_64-linux.raw.tar.gz";
in
{
  main = {resources, ...}: {
    deployment.targetEnv = "gce";
    deployment.gce = free-tier;
    swapDevices = [ { device = "/swapfile"; size = 2048; } ];

    deployment.keys.vote = {
      text = builtins.readFile ../../secret/env;
    };

    deployment.keys.healthchecks-io = {
      text = builtins.readFile ../../secret/healthchecks-io;
      user = "healthchecks";
    };
  };

  resources.gceImages.bootstrap = credentials // {
    name = "pollparty-nixos";
    sourceUri = img;
  };
}
