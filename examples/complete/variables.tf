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

# Resource naming
variable "resource_names_map" {
  description = "Map of resource types to naming config for resource_name module."
  type = map(object({
    name       = string
    max_length = number
  }))
}

variable "logical_product_family" {
  description = "Logical product family for resource naming."
  type        = string
}

variable "logical_product_service" {
  description = "Logical product service for resource naming."
  type        = string
}

variable "class_env" {
  description = "Class environment for resource naming (e.g., dev, prod)."
  type        = string
}

variable "instance_env" {
  description = "Instance environment number for resource naming."
  type        = string
}

variable "instance_resource" {
  description = "Instance resource identifier for resource naming."
  type        = string
}

variable "use_azure_region_abbr" {
  description = "Whether to use Azure region abbreviation in resource names."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

# Event target module - optional parameters (arn and rule come from created resources)
variable "target_id" {
  description = "The unique target assignment ID."
  type        = string
  default     = null
}

variable "event_bus_name" {
  description = "The name or ARN of the event bus."
  type        = string
  default     = null
}

variable "role_arn" {
  description = "The ARN of the IAM role for the target."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Used to delete managed rules created by AWS."
  type        = bool
  default     = false
}

variable "input" {
  description = "Valid JSON text passed to the target."
  type        = string
  default     = null
}

variable "input_path" {
  description = "JSONPath for extracting part of the matched event."
  type        = string
  default     = null
}

variable "input_transformer" {
  description = "Custom input transformer configuration."
  type = object({
    input_paths    = optional(map(string))
    input_template = string
  })
  default = null
}

variable "appsync_target" {
  description = "AppSync GraphQL API mutation target configuration."
  type = object({
    graphql_operation = optional(string)
  })
  default = null
}

variable "batch_target" {
  description = "Amazon Batch Job target configuration."
  type = object({
    job_definition = string
    job_name       = string
    array_size     = optional(number)
    job_attempts   = optional(number)
  })
  default = null
}

variable "dead_letter_config" {
  description = "Dead letter config."
  type = object({
    arn = optional(string)
  })
  default = null
}

variable "ecs_target" {
  description = "Amazon ECS Task target configuration."
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
  description = "API Gateway REST endpoint target configuration."
  type = object({
    header_parameters       = optional(map(string))
    path_parameter_values   = optional(list(string))
    query_string_parameters = optional(map(string))
  })
  default = null
}

variable "kinesis_target" {
  description = "Amazon Kinesis Stream target configuration."
  type = object({
    partition_key_path = optional(string)
  })
  default = null
}

variable "redshift_target" {
  description = "Amazon Redshift Statement target configuration."
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
  description = "Retry policy configuration."
  type = object({
    maximum_event_age_in_seconds = optional(number)
    maximum_retry_attempts       = optional(number)
  })
  default = null
}

variable "run_command_targets" {
  description = "Amazon EC2 Run Command target configuration."
  type = list(object({
    key    = string
    values = list(string)
  }))
  default = []
}

variable "sqs_target" {
  description = "Amazon SQS Queue target configuration."
  type = object({
    message_group_id = optional(string)
  })
  default = null
}

variable "sagemaker_pipeline_target" {
  description = "Amazon SageMaker AI Pipeline target configuration."
  type = object({
    pipeline_parameter_list = optional(list(object({
      name  = string
      value = string
    })))
  })
  default = null
}
