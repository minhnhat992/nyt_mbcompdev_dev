cd terraform
terraform init --upgrade  -reconfigure  \
-var credentials_file="creds/nyt-mbcompdev-dev-5c351ded4d94.json" \
-backend-config=gcs_backend_local.conf

terraform plan \
-var terraform_credentials_file="creds/nyt-mbcompdev-dev-5c351ded4d94.json"


terraform apply --auto-approve