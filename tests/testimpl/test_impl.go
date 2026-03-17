package testimpl

import (
	"context"
	"os"
	"strings"
	"testing"

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
	resourceID := terraform.Output(t, terraformOptions, "id")
	idSegments := strings.Split(resourceID, "/")
	require.GreaterOrEqual(t, len(idSegments), 3, "id should contain event_bus_name/rule/target_id")
	expectedRule := idSegments[len(idSegments)-2]
	expectedTargetID := idSegments[len(idSegments)-1]
	expectedArn := terraform.Output(t, terraformOptions, "log_group_arn")
	eventBusName := terraform.Output(t, terraformOptions, "event_bus_name")
	if eventBusName == "" {
		eventBusName = "default"
	}

	assert.Equal(t, expectedRule, rule, "rule output should match expected rule name")
	assert.Equal(t, expectedTargetID, targetID, "target_id output should match expected target ID")
	assert.Equal(t, expectedArn, arn, "arn output should match expected target ARN")

	cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(getAWSRegion(t)))
	require.NoError(t, err)

	eventBridgeClient := cloudwatchevents.NewFromConfig(cfg)

	// Verify target exists via AWS API
	listInput := &cloudwatchevents.ListTargetsByRuleInput{
		Rule:         aws.String(rule),
		EventBusName: aws.String(eventBusName),
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
				EventBusName: aws.String(eventBusName),
			},
		},
	}
	putOutput, err := eventBridgeClient.PutEvents(context.Background(), putInput)
	require.NoError(t, err)
	require.Len(t, putOutput.Entries, 1, "PutEvents should return one entry")
	assert.Zero(t, putOutput.FailedEntryCount, "PutEvents should not report failed entries")
	assert.Equal(t, "", aws.ToString(putOutput.Entries[0].ErrorCode), "PutEvents should succeed without error")
}

func TestComposableCompleteReadOnly(t *testing.T, ctx types.TestContext) {
	terraformOptions := ctx.TerratestTerraformOptions()

	rule := terraform.Output(t, terraformOptions, "rule")
	targetID := terraform.Output(t, terraformOptions, "target_id")
	arn := terraform.Output(t, terraformOptions, "arn")
	resourceID := terraform.Output(t, terraformOptions, "id")
	idSegments := strings.Split(resourceID, "/")
	require.GreaterOrEqual(t, len(idSegments), 3, "id should contain event_bus_name/rule/target_id")
	expectedRule := idSegments[len(idSegments)-2]
	expectedTargetID := idSegments[len(idSegments)-1]
	expectedArn := terraform.Output(t, terraformOptions, "log_group_arn")
	eventBusName := terraform.Output(t, terraformOptions, "event_bus_name")
	if eventBusName == "" {
		eventBusName = "default"
	}

	assert.Equal(t, expectedRule, rule, "rule output should match expected rule name")
	assert.Equal(t, expectedTargetID, targetID, "target_id output should match expected target ID")
	assert.Equal(t, expectedArn, arn, "arn output should match expected target ARN")

	cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(getAWSRegion(t)))
	require.NoError(t, err)

	eventBridgeClient := cloudwatchevents.NewFromConfig(cfg)

	// Read-only: verify target exists and attributes match
	listInput := &cloudwatchevents.ListTargetsByRuleInput{
		Rule:         aws.String(rule),
		EventBusName: aws.String(eventBusName),
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
