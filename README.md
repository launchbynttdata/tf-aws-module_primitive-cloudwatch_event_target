# Terraform AWS Module - CloudWatch Event Target (EventBridge Target)

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This Terraform module wraps the [`aws_cloudwatch_event_target`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) resource to create an EventBridge (CloudWatch Events) target. EventBridge targets define where events matching a rule are sent—such as Lambda functions, SQS queues, Kinesis streams, ECS tasks, and more.

## Usage

```hcl
module "event_target" {
  source = "terraform.registry.launch.nttdata.com/module_primitive/cloudwatch_event_target/aws"
  version = "~> 1.0"

  rule = aws_cloudwatch_event_rule.example.name
  arn  = aws_cloudwatch_log_group.example.arn

  target_id = "my-target"
}
```

## Pre-Commit Hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines pre-commit hooks for Terraform, Go, and common linting. The `detect-secrets-hook` prevents new secrets from being introduced. See [pre-commit](https://pre-commit.com/) for installation. Install the commit-msg hook for commitlint:

```shell
pre-commit install --hook-type commit-msg
```

## Prerequisites

- [asdf](https://github.com/asdf-vm/asdf) or [mise](https://mise.jdx.dev/) for tool version management
- [make](https://www.gnu.org/software/make/)
- Run `make configure` to pull shared components

## Examples

See the [examples/complete](examples/complete) directory for a full working example that creates an EventBridge rule, CloudWatch Log Group, and event target.

## License

Apache 2.0 - see [LICENSE](LICENSE) for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arn"></a> [arn](#input\_arn) | The Amazon Resource Name (ARN) of the target. | `string` | n/a | yes |
| <a name="input_rule"></a> [rule](#input\_rule) | The name of the rule you want to add targets to. | `string` | n/a | yes |
| <a name="input_target_id"></a> [target\_id](#input\_target\_id) | The unique target assignment ID. If missing, will generate a random, unique id. | `string` | `null` | no |
| <a name="input_event_bus_name"></a> [event\_bus\_name](#input\_event\_bus\_name) | The name or ARN of the event bus to associate with the rule. If omitted, the default event bus is used. | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The ARN of the IAM role to be used for this target when the rule is triggered. Required if ecs\_target is used or target in arn is EC2 instance, Kinesis data stream, Step Functions state machine, or Event Bus in different account or region. | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Used to delete managed rules created by AWS. | `bool` | `false` | no |
| <a name="input_input"></a> [input](#input\_input) | Valid JSON text passed to the target. Conflicts with input\_path and input\_transformer. | `string` | `null` | no |
| <a name="input_input_path"></a> [input\_path](#input\_input\_path) | The value of the JSONPath that is used for extracting part of the matched event when passing it to the target. Conflicts with input and input\_transformer. | `string` | `null` | no |
| <a name="input_input_transformer"></a> [input\_transformer](#input\_input\_transformer) | Parameters used when providing a custom input to a target based on certain event data. Conflicts with input and input\_path. | <pre>object({<br/>    input_paths    = optional(map(string))<br/>    input_template = string<br/>  })</pre> | `null` | no |
| <a name="input_appsync_target"></a> [appsync\_target](#input\_appsync\_target) | Parameters used when using the rule to invoke an AppSync GraphQL API mutation. Maximum of 1 allowed. | <pre>object({<br/>    graphql_operation = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_batch_target"></a> [batch\_target](#input\_batch\_target) | Parameters used when using the rule to invoke an Amazon Batch Job. Maximum of 1 allowed. | <pre>object({<br/>    job_definition = string<br/>    job_name       = string<br/>    array_size     = optional(number)<br/>    job_attempts   = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_dead_letter_config"></a> [dead\_letter\_config](#input\_dead\_letter\_config) | Parameters used when providing a dead letter config. Maximum of 1 allowed. | <pre>object({<br/>    arn = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_ecs_target"></a> [ecs\_target](#input\_ecs\_target) | Parameters used when using the rule to invoke Amazon ECS Task. Maximum of 1 allowed. | <pre>object({<br/>    task_definition_arn = string<br/>    capacity_provider_strategy = optional(list(object({<br/>      capacity_provider = string<br/>      weight            = number<br/>      base              = optional(number)<br/>    })))<br/>    enable_ecs_managed_tags = optional(bool)<br/>    enable_execute_command  = optional(bool)<br/>    group                   = optional(string)<br/>    launch_type             = optional(string)<br/>    network_configuration = optional(object({<br/>      subnets          = list(string)<br/>      security_groups  = optional(list(string))<br/>      assign_public_ip = optional(bool)<br/>    }))<br/>    ordered_placement_strategy = optional(list(object({<br/>      type  = string<br/>      field = optional(string)<br/>    })))<br/>    placement_constraint = optional(list(object({<br/>      type       = string<br/>      expression = optional(string)<br/>    })))<br/>    platform_version = optional(string)<br/>    propagate_tags   = optional(string)<br/>    task_count       = optional(number)<br/>    tags             = optional(map(string))<br/>  })</pre> | `null` | no |
| <a name="input_http_target"></a> [http\_target](#input\_http\_target) | Parameters used when using the rule to invoke an API Gateway REST endpoint. Maximum of 1 allowed. | <pre>object({<br/>    header_parameters       = optional(map(string))<br/>    path_parameter_values   = optional(list(string))<br/>    query_string_parameters = optional(map(string))<br/>  })</pre> | `null` | no |
| <a name="input_kinesis_target"></a> [kinesis\_target](#input\_kinesis\_target) | Parameters used when using the rule to invoke an Amazon Kinesis Stream. Maximum of 1 allowed. | <pre>object({<br/>    partition_key_path = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_redshift_target"></a> [redshift\_target](#input\_redshift\_target) | Parameters used when using the rule to invoke an Amazon Redshift Statement. Maximum of 1 allowed. | <pre>object({<br/>    database            = string<br/>    db_user             = optional(string)<br/>    secrets_manager_arn = optional(string)<br/>    sql                 = optional(string)<br/>    statement_name      = optional(string)<br/>    with_event          = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_retry_policy"></a> [retry\_policy](#input\_retry\_policy) | Parameters used when providing retry policies. Maximum of 1 allowed. | <pre>object({<br/>    maximum_event_age_in_seconds = optional(number)<br/>    maximum_retry_attempts       = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_run_command_targets"></a> [run\_command\_targets](#input\_run\_command\_targets) | Parameters used when using the rule to invoke Amazon EC2 Run Command. Maximum of 5 allowed. | <pre>list(object({<br/>    key    = string<br/>    values = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_sqs_target"></a> [sqs\_target](#input\_sqs\_target) | Parameters used when using the rule to invoke an Amazon SQS Queue. Maximum of 1 allowed. | <pre>object({<br/>    message_group_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_sagemaker_pipeline_target"></a> [sagemaker\_pipeline\_target](#input\_sagemaker\_pipeline\_target) | Parameters used when using the rule to invoke an Amazon SageMaker AI Pipeline. Maximum of 1 allowed. | <pre>object({<br/>    pipeline_parameter_list = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })))<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the EventBridge target (event\_bus\_name/rule/target\_id format). |
| <a name="output_rule"></a> [rule](#output\_rule) | The name of the rule. |
| <a name="output_target_id"></a> [target\_id](#output\_target\_id) | The unique target assignment ID. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the target resource. |
| <a name="output_event_bus_name"></a> [event\_bus\_name](#output\_event\_bus\_name) | The name or ARN of the event bus. |
<!-- END_TF_DOCS -->
