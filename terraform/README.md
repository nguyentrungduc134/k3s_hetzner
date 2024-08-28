# Terraform Hetzner Kubernetes Cluster Deployment with MicroOS Snapshot

## Overview

This README outlines the steps required to deploy a Kubernetes cluster on Hetzner Cloud using Terraform. The setup involves creating a MicroOS snapshot, configuring Terraform files, and deploying the cluster. The configuration includes node pools, load balancers, and integration with Helm for additional services like Nginx and CSI Driver SMB.

## Prerequisites

- **Terraform**: Ensure that Terraform is installed and meets the required version (`>= 1.5.0`).
- **Packer**: Required for creating the MicroOS snapshot.
- **Hetzner API Token**: Obtain an API token with `Read & Write` permissions from your Hetzner project.
- **SSH Key Pair**: A valid SSH key pair for accessing the nodes.
- **Packer**: Install [Packer](https://www.packer.io/) for building the MicroOS snapshot.

## Steps to Deploy

### 1. Create MicroOS Snapshot

Before deploying the Kubernetes cluster, you need to create a MicroOS snapshot using Packer.

1. Download the Packer template for MicroOS snapshots:

   ```bash
   curl -sL https://raw.githubusercontent.com/kube-hetzner/terraform-hcloud-kube-hetzner/master/packer-template/hcloud-microos-snapshots.pkr.hcl -o hcloud-microos-snapshots.pkr.hcl
   ```

2. Set your Hetzner Cloud API token:

   ```bash
   export HCLOUD_TOKEN="your_hcloud_token"
   ```

3. Initialize the Packer template:

   ```bash
   packer init hcloud-microos-snapshots.pkr.hcl
   ```

4. Build the MicroOS snapshot:

   ```bash
   packer build hcloud-microos-snapshots.pkr.hcl
   ```

### 2. Configure Terraform

1. **Hetzner API Token**: 

   Set your Hetzner API token either directly in the Terraform file or as an environment variable:

   ```bash
   export TF_VAR_hcloud_token=xxxxxxxxxxx
   ```

2. **SSH Keys**:
   Create ssh key id_rsa in current directory
   ssh-keygen -t ed25519
   Ensure that the `ssh_public_key` and `ssh_private_key` fields in the Terraform configuration point to your SSH key files.

3. **Node Pools**:

   Customize the `control_plane_nodepools`, `agent_nodepools`, and `autoscaler_nodepools` in the Terraform configuration according to your needs.

4. **Load Balancer**:

   Configure the load balancer settings, including type and location, in the Terraform configuration.

5. **Helm Values**:

   Customize Helm values for additional services like Nginx and CSI Driver SMB if needed.

### 3. Initialize and Apply Terraform

1. **Initialize Terraform**:

   Run the following command to initialize the Terraform environment:

   ```bash
   terraform init
   ```

2. **Plan and Apply**:

Here's the updated section of your README file, including the `dev.tfvars` configuration:

---

## Dev Environment Variables

Before deploying the Terraform configuration, ensure you have a `dev.tfvars` file with the following variables defined:

```hcl
docker_username = "your_docker_username"
docker_password = "your_docker_password"
master_nodes    = 3
nodes           = 1
min_nodes       = 1
max_nodes       = 5
```

- **`docker_username`**: Your Docker Hub username.
- **`docker_password`**: Your Docker Hub password.
- **`master_nodes`**: Number of master nodes in the Kubernetes control plane.
- **`nodes`**: Number of agent nodes in the Kubernetes cluster.
- **`min_nodes`**: Minimum number of nodes for autoscaling.
- **`max_nodes`**: Maximum number of nodes for autoscaling.

Save this configuration in a `dev.tfvars` file and include it in your `terraform apply` command as follows:

```bash
terraform apply --var-file=dev.tfvars -var hcloud_token=xxxxxxx
```

This setup ensures that your Kubernetes cluster is deployed with the appropriate scaling configurations and Docker credentials.
   Review the Terraform plan and apply the configuration:

   ```bash
   terraform apply --var-file=dev.tfvars -auto-approve
   ```

3. **Access the Kubernetes Cluster**:

   The `kubeconfig` file output by Terraform can be used to interact with your Kubernetes cluster.
   ```bash
   terraform output kubeconfig>config.yaml
   ```
   Delete the first and last line of config.yaml
   
   ```bash
   export KUBECONFIG=/home/rama/hcloud/terraform2/config.yaml
   ```
   Encode the key, copy it and put to repository secret KUBECONFIG
   ```bash
   cat config.yaml | base64
   ```

## Output

- **Kubeconfig**: The configuration file needed to access your Kubernetes cluster.

## Security Considerations

- Keep your Hetzner API token and SSH keys secure.
- Customize the firewall rules and load balancer settings to match your security requirements.

## Conclusion

This guide provides a complete walkthrough for deploying a Kubernetes cluster on Hetzner Cloud, starting from creating a MicroOS snapshot to configuring and applying Terraform. By following these steps, you can efficiently set up a scalable and secure Kubernetes environment tailored to your specific needs.
