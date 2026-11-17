# Pins the two declared-but-inert input validations on the gpu-instance
# module: machine_type must match a GPU-capable family regex, and
# gpu_type must be one of the four listed accelerator SKUs. Sibling to
# modules/firewall/tests/validations.tftest.hcl (f907324, today) in the
# same debt class (declared-but-inert control, class 1) but with a
# different mutation shape: the firewall tests target `length > 0` and
# `!contains` predicates; here the targets are a `can(regex(...))`
# over a string and a `contains(allowlist, value)` enum check.
#
# Without these validations, `machine_type = "e2-standard-2"` would
# plan successfully against a non-GPU family (producing a $0 GPU
# workload that silently falls back to CPU-only inference), and
# `gpu_type = "nvidia-garbage"` would reach the google provider and
# error at apply-time rather than at plan-time — both fail-open
# relative to the invariant the validations encode.

mock_provider "google" {}

variables {
  name         = "gpu-lab-test"
  zone         = "us-central1-a"
  machine_type = "g2-standard-4"
  gpu_type     = "nvidia-l4"
  ssh_user     = "daniel"
  ssh_pub_key  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAItestkeytestkeytestkeytestkeytestkeytestk test@red-verify"
}

# machine_type — the regex `^(g2|a2|a3|n1)-` is the only thing that
# stops an operator from attaching 1x L4 to an e2 or t2d host, which
# would plan fine and apply fine but produce no accelerator.

run "rejects_non_gpu_machine_family_e2" {
  command = plan

  variables {
    machine_type = "e2-standard-2"
  }

  expect_failures = [
    var.machine_type,
  ]
}

run "rejects_non_gpu_machine_family_t2d" {
  command = plan

  variables {
    machine_type = "t2d-standard-4"
  }

  expect_failures = [
    var.machine_type,
  ]
}

run "rejects_empty_machine_type" {
  command = plan

  variables {
    machine_type = ""
  }

  expect_failures = [
    var.machine_type,
  ]
}

# gpu_type — the contains() allowlist pins the four accelerator SKUs
# the startup scripts and workload labels are written for. A typo
# like "nvidia-a100" (missing the -tesla- segment) or an unlisted
# future SKU would bypass the allowlist via this check.

run "rejects_unlisted_gpu_type" {
  command = plan

  variables {
    gpu_type = "nvidia-a100"
  }

  expect_failures = [
    var.gpu_type,
  ]
}

run "rejects_empty_gpu_type" {
  command = plan

  variables {
    gpu_type = ""
  }

  expect_failures = [
    var.gpu_type,
  ]
}

# Positive-path sanity: the allowlist's non-default member must plan.
# This catches a mutation that replaces the contains() allowlist with
# an equality check against the default "nvidia-l4" — which would
# pass all five negative tests above while silently rejecting the
# other three legitimate SKUs the allowlist exists to permit.

run "accepts_h100_gpu_type" {
  command = plan

  variables {
    gpu_type     = "nvidia-h100-80gb"
    machine_type = "a3-highgpu-8g"
  }
}

run "accepts_a100_gpu_type" {
  command = plan

  variables {
    gpu_type     = "nvidia-tesla-a100"
    machine_type = "a2-highgpu-1g"
  }
}
