# Import Commands for Existing Resources

If you get errors about resources already existing, use these commands to import them into Terraform state.

## RDS Parameter Group

```bash
cd ops/iac
terraform import module.data.aws_db_parameter_group.main apprenticefinal-db-params-staging
```

## S3 Bucket (if it still exists)

```bash
terraform import module.compute.aws_s3_bucket.web apprenticefinal-web-staging-522814722683
```

## After Import

Run `terraform plan` to verify everything is in sync, then `terraform apply` to continue.

