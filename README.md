# Build and Deploy Project to Hetzner
## Overview

This GitHub Actions workflow automates the process of building a Docker image from your application code, pushing the image to Docker Hub, and then deploying it to Hetzner Cloud using Terraform. The workflow is triggered on every push to the `main` branch, ensuring that your application is always up-to-date and running the latest code.
 
## Workflow Details

### Workflow Name
- **Name**: Build and Deploy Project to Docker Hub

### Triggers
- **Trigger**: Push events to the `main` branch

### Environment Variables
- **HCLOUD_TOKEN**: Hetzner Cloud API token, sourced from GitHub Secrets.
- **DOCKER_USERNAME**: Docker Hub username, sourced from GitHub Secrets.
- **DOCKER_PASSWORD**: Docker Hub password, sourced from GitHub Secrets.
- **PROMETHEUS_PASSWORD**: Password for Prometheus, sourced from GitHub Secrets.

### Jobs

#### 1. Build Job

- **Runs-on**: `ubuntu-latest`
- **Steps**:
  1. **Checkout Code**: Uses `actions/checkout@v3` to clone the repository.
  2. **Set Up Docker Buildx**: Uses `docker/setup-buildx-action@v3` to set up Docker Buildx, a tool for building multi-platform Docker images.
  3. **Log in to Docker Hub**: Uses `docker/login-action@v3` to authenticate with Docker Hub.
  4. **Build and Push Docker Image**: Uses `docker/build-push-action@v6` to build the Docker image from the provided `Dockerfile` and push it to Docker Hub with the tag `latest`.

#### 2. Deploy Job

- **Needs**: The `build` job must complete successfully before this job runs.
- **Runs-on**: `ubuntu-latest`
- **Working Directory**: `terraform`
- **Steps**:
  1. **Checkout Code**: Re-checkout the codebase to ensure the latest version is used.
  2. **Setup Hetzner Cloud CLI**: Uses `hetznercloud/setup-hcloud@v1` to install the Hetzner Cloud CLI.
  3. **Setup Terraform**: Uses `hashicorp/setup-terraform@v3` to set up Terraform.
  4. **Terraform Init**: Initialize the Terraform working directory.
  5. **Terraform Plan**: Generate and display an execution plan, using secrets and variables provided via the `dev.tfvars` file.
  6. **Terraform Apply**: Apply the changes required to reach the desired state, defined by the Terraform configuration.
  7. **Validate Services**: Execute a validation script (`validate.sh`) to ensure services are running correctly on the new servers.
  8. **Validate Prometheus Metrics**: Run a script (`metric_validate.sh`) to ensure Prometheus metrics are correctly configured.
  9. **Rollback on Failure**: If the previous steps fail, rollback the Docker Prometheus configuration by running a rollback script (`roll_back.sh`).
  10. **Destroy on Failure**: If the deployment fails, destroy the newly created servers to avoid unnecessary costs.
  11. **Switch to Production**: If the deployment is successful, update the load balancer to attach the new servers and detach the old ones using the `change_to_prod.sh` script.

## Usage

To use this workflow:

1. **Secrets Setup**: Ensure the following secrets are set in your GitHub repository:
   - `HCLOUD_TOKEN`
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD`
   - `PROMETHEUS_PASSWORD`
2. **Docker setup**
    - Create a registry for your app in Dockerhub
    - In terraform/init.sh, input your Dockerhub username and application name, in this workflow app name is go_app:latest, also change app name in workflow
4. **Push to Main**:
   - Setup number of servers in terraform/dev.tfvars
   - Push your changes to the `main` branch to trigger the workflow.

5. **Monitor the Workflow**: The workflow will automatically build and deploy your project. Monitor the progress and output in the GitHub Actions tab.

## Conclusion

This CI/CD pipeline streamlines the deployment process, ensuring that your application is consistently built and deployed with minimal manual intervention. By leveraging Docker, Terraform, and Hetzner Cloud, this workflow provides a robust solution for continuous deployment in a cloud environment.
