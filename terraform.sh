cd terraform
terraform init --upgrade \
-var credentials_file="creds/nyt-mbcompdev-dev-5c351ded4d94.json" \
-backend-config=gcs_backend_circle.conf

terraform apply --auto-approve