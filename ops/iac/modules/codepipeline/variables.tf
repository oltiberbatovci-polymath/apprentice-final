# Variables for CodePipeline Module

variable "pipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string
  default     = "staging"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection to GitHub"
  type        = string
}

variable "repository_id" {
  description = "GitHub repository ID (format: owner/repo)"
  type        = string
}

variable "branch_name" {
  description = "Branch name to monitor"
  type        = string
  default     = "main"
}

variable "detect_changes" {
  description = "Automatically detect changes in the repository"
  type        = bool
  default     = true
}

variable "buildspec_path" {
  description = "Path to the buildspec file"
  type        = string
}

variable "build_compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "CodeBuild Docker image"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "build_timeout" {
  description = "Build timeout in minutes"
  type        = number
  default     = 30
}

variable "privileged_mode" {
  description = "Enable privileged mode for Docker builds"
  type        = bool
  default     = false
}

variable "environment_variables" {
  description = "Environment variables for CodeBuild"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_notifications" {
  description = "Enable SNS notifications for pipeline events"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

