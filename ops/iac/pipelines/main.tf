# Main Terraform Configuration for CodePipeline Infrastructure
# This file instantiates three separate pipelines: web, api, and infrastructure

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration - to be uncommented after S3 bucket is created
  # backend "s3" {
  #   bucket         = "apprentice-terraform-state"
  #   key            = "pipelines/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "apprentice-terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
      ManagedBy   = "Terraform"
    }
  }
}

# Data source to get AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get AWS region
data "aws_region" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.current.name

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}

# Web Pipeline
module "web_pipeline" {
  source = "../modules/codepipeline"

  pipeline_name           = "web-pipeline"
  environment             = var.environment
  aws_region              = local.aws_region
  aws_account_id          = local.aws_account_id
  codestar_connection_arn = var.codestar_connection_arn
  repository_id           = var.repository_id
  branch_name             = var.branch_name
  buildspec_path          = "cicd/buildspec-web.yml"
  
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_image        = "aws/codebuild/standard:7.0"
  build_timeout      = 30
  privileged_mode    = false

  environment_variables = {
    ENVIRONMENT = var.environment
    NODE_ENV    = "production"
  }

  log_retention_days   = 7
  enable_notifications = true

  tags = local.common_tags
}

# API Pipeline
module "api_pipeline" {
  source = "../modules/codepipeline"

  pipeline_name           = "api-pipeline"
  environment             = var.environment
  aws_region              = local.aws_region
  aws_account_id          = local.aws_account_id
  codestar_connection_arn = var.codestar_connection_arn
  repository_id           = var.repository_id
  branch_name             = var.branch_name
  buildspec_path          = "cicd/buildspec-api.yml"
  
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_image        = "aws/codebuild/standard:7.0"
  build_timeout      = 30
  privileged_mode    = false

  environment_variables = {
    ENVIRONMENT = var.environment
    NODE_ENV    = "production"
  }

  log_retention_days   = 7
  enable_notifications = true

  tags = local.common_tags
}

# Infrastructure Pipeline
module "infrastructure_pipeline" {
  source = "../modules/codepipeline"

  pipeline_name           = "infrastructure-pipeline"
  environment             = var.environment
  aws_region              = local.aws_region
  aws_account_id          = local.aws_account_id
  codestar_connection_arn = var.codestar_connection_arn
  repository_id           = var.repository_id
  branch_name             = var.branch_name
  buildspec_path          = "cicd/buildspec-infrastructure.yml"
  
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_image        = "hashicorp/terraform:1.6"
  build_timeout      = 45
  privileged_mode    = false

  environment_variables = {
    ENVIRONMENT    = var.environment
    TF_VERSION     = "1.6.0"
    TF_IN_AUTOMATION = "true"
  }

  log_retention_days   = 7
  enable_notifications = true

  tags = local.common_tags
}

