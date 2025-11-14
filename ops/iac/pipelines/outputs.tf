# Outputs for Pipeline Infrastructure

# Web Pipeline Outputs
output "web_pipeline_id" {
  description = "ID of the web pipeline"
  value       = module.web_pipeline.pipeline_id
}

output "web_pipeline_name" {
  description = "Name of the web pipeline"
  value       = module.web_pipeline.pipeline_name
}

output "web_codebuild_project" {
  description = "CodeBuild project name for web"
  value       = module.web_pipeline.codebuild_project_name
}

output "web_artifact_bucket" {
  description = "S3 bucket for web pipeline artifacts"
  value       = module.web_pipeline.artifact_bucket_name
}

output "web_sns_topic_arn" {
  description = "SNS topic ARN for web pipeline notifications"
  value       = module.web_pipeline.sns_topic_arn
}

# API Pipeline Outputs
output "api_pipeline_id" {
  description = "ID of the API pipeline"
  value       = module.api_pipeline.pipeline_id
}

output "api_pipeline_name" {
  description = "Name of the API pipeline"
  value       = module.api_pipeline.pipeline_name
}

output "api_codebuild_project" {
  description = "CodeBuild project name for API"
  value       = module.api_pipeline.codebuild_project_name
}

output "api_artifact_bucket" {
  description = "S3 bucket for API pipeline artifacts"
  value       = module.api_pipeline.artifact_bucket_name
}

output "api_sns_topic_arn" {
  description = "SNS topic ARN for API pipeline notifications"
  value       = module.api_pipeline.sns_topic_arn
}

# Infrastructure Pipeline Outputs
output "infrastructure_pipeline_id" {
  description = "ID of the infrastructure pipeline"
  value       = module.infrastructure_pipeline.pipeline_id
}

output "infrastructure_pipeline_name" {
  description = "Name of the infrastructure pipeline"
  value       = module.infrastructure_pipeline.pipeline_name
}

output "infrastructure_codebuild_project" {
  description = "CodeBuild project name for infrastructure"
  value       = module.infrastructure_pipeline.codebuild_project_name
}

output "infrastructure_artifact_bucket" {
  description = "S3 bucket for infrastructure pipeline artifacts"
  value       = module.infrastructure_pipeline.artifact_bucket_name
}

output "infrastructure_sns_topic_arn" {
  description = "SNS topic ARN for infrastructure pipeline notifications"
  value       = module.infrastructure_pipeline.sns_topic_arn
}

