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

output "id" {
  description = "The ID of the EventBridge target (event_bus_name/rule/target_id format)."
  value       = "${coalesce(aws_cloudwatch_event_target.target.event_bus_name, "default")}/${aws_cloudwatch_event_target.target.rule}/${aws_cloudwatch_event_target.target.target_id}"
}

output "rule" {
  description = "The name of the rule."
  value       = aws_cloudwatch_event_target.target.rule
}

output "target_id" {
  description = "The unique target assignment ID."
  value       = aws_cloudwatch_event_target.target.target_id
}

output "arn" {
  description = "The ARN of the target resource."
  value       = aws_cloudwatch_event_target.target.arn
}

output "event_bus_name" {
  description = "The name or ARN of the event bus."
  value       = aws_cloudwatch_event_target.target.event_bus_name
}
