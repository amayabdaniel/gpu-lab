include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${get_repo_root()}/live/_components/model-bench"
}

inputs = {
  environment = "lab"
  network     = local.env.locals.network
  ssh_user    = local.env.locals.ssh_user
  ssh_pub_key = local.env.locals.ssh_pub_key

  # g2-standard-8: 1x L4, 32 vCPU, 128GB RAM — $1.50/hr
  # More RAM for running multiple models simultaneously
  machine_type = "g2-standard-8"
  gpu_type     = "nvidia-l4"
  disk_size_gb = 200
}
