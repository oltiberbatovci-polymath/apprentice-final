# Variables for Pipeline Infrastructure

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (staging, production)"
  type        = string
  default     = "staging"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ApprenticeFinal"
}

variable "owner" {
  description = "Owner of the project"
  type        = string
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection to GitHub"
  type        = string
}

variable "repository_id" {
  description = "GitHub repository ID (format: owner/repo-name)"
  type        = string
}

variable "branch_name" {
  description = "Git branch name to track"
  type        = string
  default     = "main"
}

