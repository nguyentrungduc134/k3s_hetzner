# README for Terraform Hetzner Kubernetes Cluster Deployment

## Overview

This Terraform configuration file is designed to deploy a Kubernetes cluster on Hetzner Cloud using the `kube-hetzner` module. The configuration includes options for setting up control plane and agent node pools, configuring load balancers, and deploying Helm charts for additional services such as Nginx and CSI Driver SMB.

## Prerequisites

- **Terraform**: Ensure that Terraform is installed and that your environment meets the required Terraform version (`>= 1.5.0`).
- **Hetzner API Token**: Obtain an API token with `Read & Write` permissions from your Hetzner project. You can either set this token directly in the Terraform file or as an environment variable (`TF_VAR_hcloud_token`).
- **SSH Key Pair**: A valid SSH key pair is required for accessing the nodes.

## Configuration

### 1. Hetzner API Token

You can specify your Hetzner API token in two ways:
- **In the Terraform file**: Modify the `hcloud_token` in the `locals` block.
- **As an environment variable**: Set the `TF_VAR_hcloud_token` in your shell environment:

  ```bash
  export TF_VAR_hcloud_token=xxxxxxxxxxx
  ```

### 2. SSH Keys

The SSH keys used to access the nodes should be specified in the configuration:
- **Public Key**: The `ssh_public_key` points to your public SSH key file (`id_rsa.pub`).
- **Private Key**: The `ssh_private_key` points to your private SSH key file (`id_rsa`).

### 3. Node Pools

This configuration sets up multiple node pools:
- **Control Plane Node Pools**: Defined under `control_plane_nodepools`, specifying the server type, location, and other options.
- **Agent Node Pools**: Defined under `agent_nodepools`, specifying the server type, location, and other options.
- **Autoscaler Node Pools**: Automatically scales the nodes based on the load, defined under `autoscaler_nodepools`.

### 4. Load Balancer

A load balancer is configured using the `load_balancer_type` and `load_balancer_location` parameters. Ensure that these match your requirements for handling traffic.

### 5. Additional Configurations

- **Nginx Ingress Controller**: Customize the Nginx Ingress controller using the `nginx_values` block.
- **CSI Driver SMB**: Configure the CSI Driver SMB for persistent storage using the `csi_driver_smb_values` block.
- **DNS Servers**: Customize DNS servers for the cluster.

### 6. Provider Configuration

The Hetzner Cloud provider is configured using the API token specified either in the Terraform file or as an environment variable.

## Usage

1. **Initialize Terraform**: Run `terraform init` to initialize the configuration.

2. **Plan the Deployment**: Use `terraform plan` to preview the changes Terraform will make to your infrastructure.

3. **Apply the Configuration**: Deploy the infrastructure by running:

   ```bash
   terraform apply --var-file=dev.tfvars -auto-approve
   ```

4. **Access the Cluster**: The `kubeconfig` for the cluster is output by the module and can be used to interact with the Kubernetes cluster.

## Output

- **Kubeconfig**: The kubeconfig file required to access your Kubernetes cluster is provided as a sensitive output.

## Notes

- **Security**: Ensure that your API token and SSH keys are stored securely and not hard-coded in your files.
- **Customization**: Modify the provided example configurations (e.g., node pools, load balancer, Nginx, etc.) to fit your specific use case.
- **Monitoring**: Consider integrating monitoring tools such as Prometheus and Grafana for better observability of your Kubernetes cluster.

## Conclusion

This Terraform configuration provides a robust setup for deploying a Kubernetes cluster on Hetzner Cloud with customizable options for node pools, load balancing, and additional services. By following the steps outlined, you can quickly and efficiently set up and manage your infrastructure on Hetzner.
