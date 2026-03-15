# =============================================================================
# root.hcl — Shared Terragrunt configuration for all GPU lab deployments
#
# Generates:
#   - GCS backend with unique key per workload
#   - Google provider with project, region, and labels
# =============================================================================

locals {
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  project_id = local.env_config.locals.project_id
  region     = local.env_config.locals.region
  zone       = local.env_config.locals.zone

  relative_path = path_relative_to_include()
  state_prefix  = "gpu-lab/${local.relative_path}"
}

# -----------------------------------------------------------------------------
# Remote State — GCS
# -----------------------------------------------------------------------------
remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket   = "gpu-lab-tfstate-${local.project_id}"
    prefix   = local.state_prefix
    project  = local.project_id
    location = local.region
  }
}

# -----------------------------------------------------------------------------
# Provider — Generated into each workload directory
# -----------------------------------------------------------------------------
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.5.0"
      required_providers {
        google = {
          source  = "hashicorp/google"
          version = "~> 5.0"
        }
      }
    }

    provider "google" {
      project = "${local.project_id}"
      region  = "${local.region}"
      zone    = "${local.zone}"
    }
  EOF
}

# -----------------------------------------------------------------------------
# Common inputs — injected into every workload
# -----------------------------------------------------------------------------
inputs = {
  project_id = local.project_id
  region     = local.region
  zone       = local.zone
}
