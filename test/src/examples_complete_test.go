package test

import (
  "io/ioutil"
	"math/rand"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"testing"
	"gopkg.in/yaml.v2"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

type EventRule struct {
  Name             string           `yaml:"name"`
  Description      string           `yaml:"description"`
  EventRulePattern EventRulePattern `yaml:"event_rule_pattern"`
}

type EventRulePattern struct {
  Detail            Detail   `yaml:"detail"`
}

type Detail struct {
  Service           string   `yaml:"service"`
  EventTypeCategory string   `yaml:"event_type_category"`
  EventTypeCodes    []string `yaml:"event_type_codes"`
}

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

  // We always include a random attribute so that parallel tests and AWS resources do not interfere with each
	// other
	randID := strconv.Itoa(rand.Intn(100000))
	attributes := []string{randID}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
		// We always include a random attribute so that parallel tests
		// and AWS resources do not interfere with each other
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Get terraform Outputs
	eventRuleNames := terraform.OutputList(t, terraformOptions, "event_rule_names")

	// Get YAML configs for Event Rules
	yamlConfigPaths , err := filepath.Glob(filepath.Join("../../catalog/event_rules", "*.yaml"))
	if err != nil {
	  t.Error(err)
	}

	yamlEventRules := []EventRule{}
  for _, yamlConfigPath := range yamlConfigPaths {
    yamlConfig := []EventRule{}
    yamlFile, err := ioutil.ReadFile(yamlConfigPath)
    if err != nil {
      t.Error(err)
    }

    err = yaml.Unmarshal(yamlFile, &yamlConfig)

    if err != nil {
      t.Error(err)
    }

    for _, yamlEventRule := range yamlConfig {
      yamlEventRules = append(yamlEventRules, yamlEventRule)
    }
  }

  // Reduce created Event Rule names to base names
  reducedEventRuleNames := []string{}
	for _, eventRuleName := range eventRuleNames {
    reducedEventRuleNames = append(reducedEventRuleNames, strings.SplitAfter(eventRuleName, randID + "-")[1])
	}
  sort.Strings(reducedEventRuleNames)

  // Reduce YAML Config Event Rule names
  yamlEventRuleNames := []string{}
	for _, yamlEventRule := range yamlEventRules {
    yamlEventRuleNames = append(yamlEventRuleNames, yamlEventRule.Name)
	}
	sort.Strings(yamlEventRuleNames)

	// Assert created Event Rule reduced to base names match base names from YAML configuration
	for index, reducedEventRuleName := range reducedEventRuleNames {
    assert.Equal(t, reducedEventRuleName, yamlEventRuleNames[index])
	}
}
