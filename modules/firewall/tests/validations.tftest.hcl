# Pins the four load-bearing validations on the firewall module's two
# CIDR inputs. Debt class #1 (declared-but-inert control): 0354a40
# removed the world-open default and added the `length > 0` +
# `!contains(_, "0.0.0.0/0")` validations as the posture guard; nothing
# in the suite enforced that posture before this file existed. A
# refactor that dropped either validation would silently re-open the
# world-open-SSH / world-open-vLLM mode that 0354a40 was written to
# close, and no `terraform test` run would turn red.
#
# This is the Terraform-native analogue of research-factory's
# approve_ordering_unit_test.go: an invariant enforced in config but
# invisible to the harness until a test pins it. Negative paths only —
# positive validation that a restricted CIDR passes is covered at the
# component layer where real provider credentials exist; here we mock
# the provider so validations run in isolation.

mock_provider "google" {}

variables {
  allowed_ssh_cidrs = ["203.0.113.4/32"]
  allowed_app_cidrs = ["203.0.113.4/32"]
}

# allowed_ssh_cidrs — the input the previous default of ["0.0.0.0/0"]
# left world-open on SSH for every apply. Two guards, two tests.

run "rejects_empty_ssh_cidrs" {
  command = plan

  variables {
    allowed_ssh_cidrs = []
  }

  expect_failures = [
    var.allowed_ssh_cidrs,
  ]
}

run "rejects_world_open_ssh_cidrs" {
  command = plan

  variables {
    allowed_ssh_cidrs = ["0.0.0.0/0"]
  }

  expect_failures = [
    var.allowed_ssh_cidrs,
  ]
}

# allowed_app_cidrs — gates the unauthenticated inference ports (vLLM
# 8080, Ollama 8081, PersonaPlex 8998). Same two guards.

run "rejects_empty_app_cidrs" {
  command = plan

  variables {
    allowed_app_cidrs = []
  }

  expect_failures = [
    var.allowed_app_cidrs,
  ]
}

run "rejects_world_open_app_cidrs" {
  command = plan

  variables {
    allowed_app_cidrs = ["0.0.0.0/0"]
  }

  expect_failures = [
    var.allowed_app_cidrs,
  ]
}

# Mixed-list guard — a list with one restricted entry AND 0.0.0.0/0
# must still be rejected. The `contains()` predicate catches this, but
# pinning it explicitly guards against a future refactor that replaces
# contains() with a stricter "entire list is 0.0.0.0/0" check.

run "rejects_world_open_in_mixed_ssh_list" {
  command = plan

  variables {
    allowed_ssh_cidrs = ["203.0.113.4/32", "0.0.0.0/0"]
  }

  expect_failures = [
    var.allowed_ssh_cidrs,
  ]
}
