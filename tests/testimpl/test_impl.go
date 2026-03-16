package testimpl

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/cloudwatchevents"
	eventbridgetypes "github.com/aws/aws-sdk-go-v2/service/cloudwatchevents/types"
	"github.com/aws/aws-sdk-go-v2/service/cloudwatchlogs"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	terraformOptions := ctx.TerratestTerraformOptions()

	rule := terraform.Output(t, terraformOptions, "rule")
	targetID := terraform.Output(t, terraformOptions, "target_id")
	arn := terraform.Output(t, terraformOptions, "arn")

	require.NotEmpty(t, rule, "rule output should be set")
	require.NotEmpty(t, targetID, "target_id output should be set")
	require.NotEmpty(t, arn, "arn output should be set")

	cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(getAWSRegion(t)))
	require.NoError(t, err)

	eventBridgeClient := cloudwatchevents.NewFromConfig(cfg)

	// Verify target exists via AWS API
	listInput := &cloudwatchevents.ListTargetsByRuleInput{
		Rule:         aws.String(rule),
		EventBusName: aws.String("default"),
	}
	listOutput, err := eventBridgeClient.ListTargetsByRule(context.Background(), listInput)
	require.NoError(t, err)
	require.NotEmpty(t, listOutput.Targets, "Target should exist for rule")

	var foundTarget *eventbridgetypes.Target
	for i := range listOutput.Targets {
		if listOutput.Targets[i].Id != nil && *listOutput.Targets[i].Id == targetID {
			foundTarget = &listOutput.Targets[i]
			break
		}
	}
	require.NotNil(t, foundTarget, "Target with expected target_id should exist")
	assert.Equal(t, arn, aws.ToString(foundTarget.Arn), "Target ARN should match Terraform output")

	// Verify CloudWatch log group has KMS encryption via AWS API
	logGroupName := terraform.Output(t, terraformOptions, "log_group_name")
	require.NotEmpty(t, logGroupName, "log_group_name output should be set")
	logsClient := cloudwatchlogs.NewFromConfig(cfg)
	describeLogGroupsOutput, err := logsClient.DescribeLogGroups(context.Background(), &cloudwatchlogs.DescribeLogGroupsInput{
		LogGroupNamePrefix: aws.String(logGroupName),
	})
	require.NoError(t, err)
	require.NotEmpty(t, describeLogGroupsOutput.LogGroups, "Log group should exist")
	logGroup := describeLogGroupsOutput.LogGroups[0]
	require.NotNil(t, logGroup.KmsKeyId, "Log group must have KMS encryption (customer-managed key)")
	assert.NotEmpty(t, aws.ToString(logGroup.KmsKeyId), "Log group KMS key ID must be set")

	// Write operation: PutEvents to trigger the target (sends event to CloudWatch Log Group)
	putInput := &cloudwatchevents.PutEventsInput{
		Entries: []eventbridgetypes.PutEventsRequestEntry{
			{
				Source:       aws.String("test"),
				DetailType:   aws.String("TestEvent"),
				Detail:       aws.String(`{"test":"event"}`),
				EventBusName: aws.String("default"),
			},
		},
	}
	putOutput, err := eventBridgeClient.PutEvents(context.Background(), putInput)
	require.NoError(t, err)
	require.NotEmpty(t, putOutput.Entries, "PutEvents should return entries")
	assert.Equal(t, "", aws.ToString(putOutput.Entries[0].ErrorCode), "PutEvents should succeed without error")

	// Allow event delivery
	time.Sleep(5 * time.Second)
}

func TestComposableCompleteReadOnly(t *testing.T, ctx types.TestContext) {
	terraformOptions := ctx.TerratestTerraformOptions()

	rule := terraform.Output(t, terraformOptions, "rule")
	targetID := terraform.Output(t, terraformOptions, "target_id")
	arn := terraform.Output(t, terraformOptions, "arn")

	require.NotEmpty(t, rule, "rule output should be set")
	require.NotEmpty(t, targetID, "target_id output should be set")
	require.NotEmpty(t, arn, "arn output should be set")

	cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(getAWSRegion(t)))
	require.NoError(t, err)

	eventBridgeClient := cloudwatchevents.NewFromConfig(cfg)

	// Read-only: verify target exists and attributes match
	listInput := &cloudwatchevents.ListTargetsByRuleInput{
		Rule:         aws.String(rule),
		EventBusName: aws.String("default"),
	}
	listOutput, err := eventBridgeClient.ListTargetsByRule(context.Background(), listInput)
	require.NoError(t, err)
	require.NotEmpty(t, listOutput.Targets, "Target should exist for rule")

	var foundTarget *eventbridgetypes.Target
	for i := range listOutput.Targets {
		if listOutput.Targets[i].Id != nil && *listOutput.Targets[i].Id == targetID {
			foundTarget = &listOutput.Targets[i]
			break
		}
	}
	require.NotNil(t, foundTarget, "Target with expected target_id should exist")
	assert.Equal(t, arn, aws.ToString(foundTarget.Arn), "Target ARN should match Terraform output")

	// Verify CloudWatch log group has KMS encryption via AWS API
	logGroupName := terraform.Output(t, terraformOptions, "log_group_name")
	require.NotEmpty(t, logGroupName, "log_group_name output should be set")
	logsClient := cloudwatchlogs.NewFromConfig(cfg)
	describeLogGroupsOutput, err := logsClient.DescribeLogGroups(context.Background(), &cloudwatchlogs.DescribeLogGroupsInput{
		LogGroupNamePrefix: aws.String(logGroupName),
	})
	require.NoError(t, err)
	require.NotEmpty(t, describeLogGroupsOutput.LogGroups, "Log group should exist")
	logGroup := describeLogGroupsOutput.LogGroups[0]
	require.NotNil(t, logGroup.KmsKeyId, "Log group must have KMS encryption (customer-managed key)")
	assert.NotEmpty(t, aws.ToString(logGroup.KmsKeyId), "Log group KMS key ID must be set")
}

func getAWSRegion(t *testing.T) string {
	region := "us-east-1"
	if r := os.Getenv("AWS_DEFAULT_REGION"); r != "" {
		region = r
	}
	if r := os.Getenv("AWS_REGION"); r != "" {
		region = r
	}
	return region
}
