### README for Docker Environment Variable Setup in Terraform

#### Overview

This README provides instructions on how to set up and pass environment variables to a Docker container using Terraform. The example demonstrates configuring the `API_key` environment variable and integrating it into a Terraform-managed Docker deployment.

### Step 1: Define the Environment Variable in Terraform

1. **Define the `API_key` variable in `variables.tf`**:

   Create a `variables.tf` file and define the `API_key` variable as follows:

    ```hcl
    variable "API_key" {
      type        = string
      description = "API key for accessing the application"
    }
    ```

2. **Add the variable to `main.tf`**:

    In your `main.tf` file, use the `locals` block to manage the `API_key` and other necessary variables:

    ```hcl
    locals {
      vars = {
        docker_password = var.docker_password
        API_key         = var.API_key
      }
    
      user_data = base64encode(templatefile("./init.sh", {
        docker_password = local.vars.docker_password,
        API_key         = local.vars.API_key
      }))
    }
    ```

### Step 2: Docker Run Command with Environment Variable

1. **Update the `init.sh` Script**:

    In your `init.sh` file, include the `docker run` command with the `API_key` environment variable:

    ```bash
    # terraform/init.sh
    docker run -p 8080:8080 -e API_key=${API_key} -d ducnt134/go_app:latest
    ```

### Step 3: Include `API_key` in Terraform Apply Command

When applying your Terraform configuration, ensure that the `API_key` is included in the `terraform apply` command:

```bash
terraform apply --var-file=dev.tfvars \
  -var="hcloud_token=${{ secrets.HCLOUD_TOKEN }}" \
  -var="docker_password=${{ secrets.DOCKER_PASSWORD }}" \
  -var="prometheus_password=${{ secrets.PROMETHEUS_PASSWORD }}" \
  -var="API_key=${{ secrets.API_key }}" \
  --auto-approve
```

This will pass the `API_key` to the Terraform configuration, which then gets used in the Docker container's environment.

### Conclusion

By following these steps, you can effectively pass environment variables such as `API_key` to your Docker container using Terraform. This setup ensures that sensitive information is managed securely and deployed correctly within your infrastructure.
