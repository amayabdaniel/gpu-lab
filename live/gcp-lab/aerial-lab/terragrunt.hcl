include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${get_repo_root()}/live/_components/model-bench"
  # Reuses model-bench component — same GPU instance setup,
  # just different inputs. Aerial tests run via SSH scripts after apply.
}

inputs = {
  environment = "lab"
  network     = local.env.locals.network
  ssh_user    = local.env.locals.ssh_user
  ssh_pub_key = local.env.locals.ssh_pub_key

  # g2-standard-8: needs more CPU/RAM for Aerial SDK build
  machine_type = "g2-standard-8"
  gpu_type     = "nvidia-l4"
  disk_size_gb = 200
}
