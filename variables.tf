// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

# -----------------------------------------------------------------------------
# Required
# -----------------------------------------------------------------------------

variable "arn" {
  description = "The Amazon Resource Name (ARN) of the target."
  type        = string
}

variable "rule" {
  description = "The name of the rule you want to add targets to."
  type        = string
}

# -----------------------------------------------------------------------------
# Optional - Basic
# -----------------------------------------------------------------------------

variable "target_id" {
  description = "The unique target assignment ID. If missing, will generate a random, unique id."
  type        = string
  default     = null
}

variable "event_bus_name" {
  description = "The name or ARN of the event bus to associate with the rule. If omitted, the default event bus is used."
  type        = string
  default     = null
}

variable "role_arn" {
  description = "The ARN of the IAM role to be used for this target when the rule is triggered. Required if ecs_target is used or target in arn is EC2 instance, Kinesis data stream, Step Functions state machine, or Event Bus in different account or region."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Used to delete managed rules created by AWS."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Optional - Input (mutually exclusive: input, input_path, input_transformer)
# -----------------------------------------------------------------------------

variable "input" {
  description = "Valid JSON text passed to the target. Conflicts with input_path and input_transformer."
  type        = string
  default     = null
}

variable "input_path" {
  description = "The value of the JSONPath that is used for extracting part of the matched event when passing it to the target. Conflicts with input and input_transformer."
  type        = string
  default     = null
}

variable "input_transformer" {
  description = "Parameters used when providing a custom input to a target based on certain event data. Conflicts with input and input_path."
  type = object({
    input_paths    = optional(map(string))
    input_template = string
  })
  default = null
}

# -----------------------------------------------------------------------------
# Optional - Target-specific blocks
# -----------------------------------------------------------------------------

variable "appsync_target" {
  description = "Parameters used when using the rule to invoke an AppSync GraphQL API mutation. Maximum of 1 allowed."
  type = object({
    graphql_operation = optional(string)
  })
  default = null
}

variable "batch_target" {
  description = "Parameters used when using the rule to invoke an Amazon Batch Job. Maximum of 1 allowed."
  type = object({
    job_definition = string
    job_name       = string
    array_size     = optional(number)
    job_attempts   = optional(number)
  })
  default = null

}

variable "dead_letter_config" {
  description = "Parameters used when providing a dead letter config. Maximum of 1 allowed."
  type = object({
    arn = optional(string)
  })
  default = null
}

variable "ecs_target" {
  description = "Parameters used when using the rule to invoke Amazon ECS Task. Maximum of 1 allowed."
  type = object({
    task_definition_arn = string
    capacity_provider_strategy = optional(list(object({
      capacity_provider = string
      weight            = number
      base              = optional(number)
    })))
    enable_ecs_managed_tags = optional(bool)
    enable_execute_command  = optional(bool)
    group                   = optional(string)
    launch_type             = optional(string)
    network_configuration = optional(object({
      subnets          = list(string)
      security_groups  = optional(list(string))
      assign_public_ip = optional(bool)
    }))
    ordered_placement_strategy = optional(list(object({
      type  = string
      field = optional(string)
    })))
    placement_constraint = optional(list(object({
      type       = string
      expression = optional(string)
    })))
    platform_version = optional(string)
    propagate_tags   = optional(string)
    task_count       = optional(number)
    tags             = optional(map(string))
  })
  default = null
}

variable "http_target" {
  description = "Parameters used when using the rule to invoke an API Gateway REST endpoint. Maximum of 1 allowed."
  type = object({
    header_parameters       = optional(map(string))
    path_parameter_values   = optional(list(string))
    query_string_parameters = optional(map(string))
  })
  default = null
}

variable "kinesis_target" {
  description = "Parameters used when using the rule to invoke an Amazon Kinesis Stream. Maximum of 1 allowed."
  type = object({
    partition_key_path = optional(string)
  })
  default = null
}

variable "redshift_target" {
  description = "Parameters used when using the rule to invoke an Amazon Redshift Statement. Maximum of 1 allowed."
  type = object({
    database            = string
    db_user             = optional(string)
    secrets_manager_arn = optional(string)
    sql                 = optional(string)
    statement_name      = optional(string)
    with_event          = optional(bool)
  })
  default = null
}

variable "retry_policy" {
  description = "Parameters used when providing retry policies. Maximum of 1 allowed."
  type = object({
    maximum_event_age_in_seconds = optional(number)
    maximum_retry_attempts       = optional(number)
  })
  default = null
}

variable "run_command_targets" {
  description = "Parameters used when using the rule to invoke Amazon EC2 Run Command. Maximum of 5 allowed."
  type = list(object({
    key    = string
    values = list(string)
  }))
  default = []

  validation {
    condition     = length(var.run_command_targets) <= 5
    error_message = "run_command_targets allows a maximum of 5 blocks."
  }
}

variable "sqs_target" {
  description = "Parameters used when using the rule to invoke an Amazon SQS Queue. Maximum of 1 allowed."
  type = object({
    message_group_id = optional(string)
  })
  default = null
}

variable "sagemaker_pipeline_target" {
  description = "Parameters used when using the rule to invoke an Amazon SageMaker AI Pipeline. Maximum of 1 allowed."
  type = object({
    pipeline_parameter_list = optional(list(object({
      name  = string
      value = string
    })))
  })
  default = null
}
