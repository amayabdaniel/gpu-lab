include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${get_repo_root()}/live/_components/personaplex"
}

inputs = {
  environment = "lab"
  network     = local.env.locals.network
  ssh_user    = local.env.locals.ssh_user
  ssh_pub_key = local.env.locals.ssh_pub_key
  hf_token    = get_env("HF_TOKEN", "")

  # g2-standard-4: 1x L4, 16 vCPU, 64GB RAM — $0.80/hr
  machine_type = "g2-standard-4"
  gpu_type     = "nvidia-l4"
  disk_size_gb = 100
}
