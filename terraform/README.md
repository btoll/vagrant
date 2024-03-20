# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

terraform init
terraform plan -out vpc.tfplan
terraform apply vcp.tfplan

