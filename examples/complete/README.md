# Complete Example - CloudWatch Event Target

This example creates an EventBridge (CloudWatch Events) rule, a CloudWatch Log Group encrypted with a customer-managed KMS key, the required resource policy, and an event target that sends matching events to the log group.

## Usage

```hcl
module "resource_names" {
  source   = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version  = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  cloud_resource_type     = each.value.name
  maximum_length          = each.value.max_length
  region                  = join("", split("-", data.aws_region.current.name))
  use_azure_region_abbr   = var.use_azure_region_abbr
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/events/${module.resource_names["log_group"].standard}"
  retention_in_days = 1
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

# ... log resource policy and event rule ...

module "event_target" {
  source = "../.."

  rule = aws_cloudwatch_event_rule.example.name
  arn  = aws_cloudwatch_log_group.example.arn

  target_id      = coalesce(var.target_id, module.resource_names["event_target"].standard)
  event_bus_name = var.event_bus_name
  role_arn       = var.role_arn
  force_destroy  = var.force_destroy

  input             = var.input
  input_path        = var.input_path
  input_transformer  = var.input_transformer

  appsync_target            = var.appsync_target
  batch_target              = var.batch_target
  dead_letter_config        = var.dead_letter_config
  ecs_target                = var.ecs_target
  http_target               = var.http_target
  kinesis_target            = var.kinesis_target
  redshift_target           = var.redshift_target
  retry_policy              = var.retry_policy
  run_command_targets       = var.run_command_targets
  sqs_target                = var.sqs_target
  sagemaker_pipeline_target  = var.sagemaker_pipeline_target
}
```

## Prerequisites

- Run `make configure` to pull required components including the resource naming module.
- AWS credentials configured for the target account/region.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_names_map | Map of resource types to naming config | map(object) | n/a | yes |
| logical_product_family | Logical product family for resource naming | string | n/a | yes |
| logical_product_service | Logical product service for resource naming | string | n/a | yes |
| class_env | Class environment for resource naming | string | n/a | yes |
| instance_env | Instance environment number | string | n/a | yes |
| instance_resource | Instance resource identifier | string | n/a | yes |
| use_azure_region_abbr | Use Azure region abbreviation in names | bool | false | no |
| tags | Map of tags | map(string) | {} | no |
| target_id | Unique target assignment ID | string | null | no |
| event_bus_name | Event bus name or ARN | string | null | no |
| role_arn | IAM role ARN for the target | string | null | no |
| force_destroy | Delete managed rules | bool | false | no |
| input | JSON input for target | string | null | no |
| input_path | JSONPath for event extraction | string | null | no |
| input_transformer | Input transformer config | object | null | no |
| appsync_target | AppSync target config | object | null | no |
| batch_target | Batch job target config | object | null | no |
| dead_letter_config | Dead letter config | object | null | no |
| ecs_target | ECS task target config | object | null | no |
| http_target | API Gateway target config | object | null | no |
| kinesis_target | Kinesis target config | object | null | no |
| redshift_target | Redshift target config | object | null | no |
| retry_policy | Retry policy config | object | null | no |
| run_command_targets | Run Command target config | list | [] | no |
| sqs_target | SQS target config | object | null | no |
| sagemaker_pipeline_target | SageMaker pipeline target config | object | null | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the EventBridge target |
| rule | The name of the rule |
| target_id | The unique target assignment ID |
| arn | The ARN of the target resource |
| event_bus_name | The name or ARN of the event bus |
| log_group_name | The name of the CloudWatch log group |

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_event_target"></a> [event\_target](#module\_event\_target) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_log_group.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_kms_key.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.example_log_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | Map of resource types to naming config for resource\_name module. | <pre>map(object({<br/>    name       = string<br/>    max_length = number<br/>  }))</pre> | n/a | yes |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family for resource naming. | `string` | n/a | yes |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service for resource naming. | `string` | n/a | yes |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Class environment for resource naming (e.g., dev, prod). | `string` | n/a | yes |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Instance environment number for resource naming. | `string` | n/a | yes |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Instance resource identifier for resource naming. | `string` | n/a | yes |
| <a name="input_use_azure_region_abbr"></a> [use\_azure\_region\_abbr](#input\_use\_azure\_region\_abbr) | Whether to use Azure region abbreviation in resource names. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to resources. | `map(string)` | `{}` | no |
| <a name="input_target_id"></a> [target\_id](#input\_target\_id) | The unique target assignment ID. | `string` | `null` | no |
| <a name="input_event_bus_name"></a> [event\_bus\_name](#input\_event\_bus\_name) | The name or ARN of the event bus. | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The ARN of the IAM role for the target. | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Used to delete managed rules created by AWS. | `bool` | `false` | no |
| <a name="input_input"></a> [input](#input\_input) | Valid JSON text passed to the target. | `string` | `null` | no |
| <a name="input_input_path"></a> [input\_path](#input\_input\_path) | JSONPath for extracting part of the matched event. | `string` | `null` | no |
| <a name="input_input_transformer"></a> [input\_transformer](#input\_input\_transformer) | Custom input transformer configuration. | <pre>object({<br/>    input_paths    = optional(map(string))<br/>    input_template = string<br/>  })</pre> | `null` | no |
| <a name="input_appsync_target"></a> [appsync\_target](#input\_appsync\_target) | AppSync GraphQL API mutation target configuration. | <pre>object({<br/>    graphql_operation = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_batch_target"></a> [batch\_target](#input\_batch\_target) | Amazon Batch Job target configuration. | <pre>object({<br/>    job_definition = string<br/>    job_name       = string<br/>    array_size     = optional(number)<br/>    job_attempts   = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_dead_letter_config"></a> [dead\_letter\_config](#input\_dead\_letter\_config) | Dead letter config. | <pre>object({<br/>    arn = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_ecs_target"></a> [ecs\_target](#input\_ecs\_target) | Amazon ECS Task target configuration. | <pre>object({<br/>    task_definition_arn = string<br/>    capacity_provider_strategy = optional(list(object({<br/>      capacity_provider = string<br/>      weight            = number<br/>      base              = optional(number)<br/>    })))<br/>    enable_ecs_managed_tags = optional(bool)<br/>    enable_execute_command  = optional(bool)<br/>    group                   = optional(string)<br/>    launch_type             = optional(string)<br/>    network_configuration = optional(object({<br/>      subnets          = list(string)<br/>      security_groups  = optional(list(string))<br/>      assign_public_ip = optional(bool)<br/>    }))<br/>    ordered_placement_strategy = optional(list(object({<br/>      type  = string<br/>      field = optional(string)<br/>    })))<br/>    placement_constraint = optional(list(object({<br/>      type       = string<br/>      expression = optional(string)<br/>    })))<br/>    platform_version = optional(string)<br/>    propagate_tags   = optional(string)<br/>    task_count       = optional(number)<br/>    tags             = optional(map(string))<br/>  })</pre> | `null` | no |
| <a name="input_http_target"></a> [http\_target](#input\_http\_target) | API Gateway REST endpoint target configuration. | <pre>object({<br/>    header_parameters       = optional(map(string))<br/>    path_parameter_values   = optional(list(string))<br/>    query_string_parameters = optional(map(string))<br/>  })</pre> | `null` | no |
| <a name="input_kinesis_target"></a> [kinesis\_target](#input\_kinesis\_target) | Amazon Kinesis Stream target configuration. | <pre>object({<br/>    partition_key_path = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_redshift_target"></a> [redshift\_target](#input\_redshift\_target) | Amazon Redshift Statement target configuration. | <pre>object({<br/>    database            = string<br/>    db_user             = optional(string)<br/>    secrets_manager_arn = optional(string)<br/>    sql                 = optional(string)<br/>    statement_name      = optional(string)<br/>    with_event          = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_retry_policy"></a> [retry\_policy](#input\_retry\_policy) | Retry policy configuration. | <pre>object({<br/>    maximum_event_age_in_seconds = optional(number)<br/>    maximum_retry_attempts       = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_run_command_targets"></a> [run\_command\_targets](#input\_run\_command\_targets) | Amazon EC2 Run Command target configuration. | <pre>list(object({<br/>    key    = string<br/>    values = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_sqs_target"></a> [sqs\_target](#input\_sqs\_target) | Amazon SQS Queue target configuration. | <pre>object({<br/>    message_group_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_sagemaker_pipeline_target"></a> [sagemaker\_pipeline\_target](#input\_sagemaker\_pipeline\_target) | Amazon SageMaker AI Pipeline target configuration. | <pre>object({<br/>    pipeline_parameter_list = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })))<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the EventBridge target. |
| <a name="output_rule"></a> [rule](#output\_rule) | The name of the rule. |
| <a name="output_target_id"></a> [target\_id](#output\_target\_id) | The unique target assignment ID. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the target resource. |
| <a name="output_event_bus_name"></a> [event\_bus\_name](#output\_event\_bus\_name) | The name or ARN of the event bus. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | The name of the CloudWatch log group (for test verification). |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | The ARN of the CloudWatch log group used as the event target. |
<!-- END_TF_DOCS -->
