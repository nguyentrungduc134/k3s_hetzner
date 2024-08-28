# K3S Hetzner

## 2. Installing Grafana Monitoring

### Overview
This guide provides instructions to install and set up Grafana monitoring in a Kubernetes cluster using Helm. You will use the `k3s-monitoring` repository to deploy Prometheus and Grafana with pre-configured settings.

### Prerequisites
- A running Kubernetes cluster (e.g., k3s).
- Helm installed and configured.

### Installation Steps

#### 1. Clone the `k3s-monitoring` Repository
Begin by cloning the `k3s-monitoring` repository, which contains the necessary Helm values files and configurations:

```bash
git clone https://github.com/cablespaghetti/k3s-monitoring.git
cd k3s-monitoring
```

#### 2. Add the Prometheus Helm Chart Repository
Add the Prometheus community Helm chart repository to your local Helm installation:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

#### 3. Install Prometheus and Grafana
Install Prometheus and Grafana using Helm. The `kube-prometheus-stack` Helm chart will deploy both Prometheus and Grafana with pre-configured settings provided in the `kube-prometheus-stack-values.yaml` file:

```bash
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --version 39.13.3 --values kube-prometheus-stack-values.yaml
```

#### 4. Edit the Grafana Service to Use a NodePort
To access Grafana externally, you need to modify the Grafana service to use a NodePort:

```bash
kubectl edit service/prometheus-grafana
```

- Locate the `type` field and change its value from `ClusterIP` to `NodePort`.
- Save and exit the editor.

#### 5. Access Grafana
Once the service type is set to NodePort, you can access the Grafana dashboard from your browser:

- Open your web browser and go to `http://<your-k3s-node-ip>:<nodeport>/login`.
- Use the following default credentials to log in:
  - **Username:** `admin`
  - **Password:** `prom-operator`

## Conclusion
You have now installed Grafana and Prometheus for monitoring your Kubernetes cluster. By following the steps outlined in this guide, you can access the Grafana dashboard to visualize and monitor metrics collected by Prometheus.

## Troubleshooting
If you encounter any issues during the installation, verify that Helm is correctly installed and configured, and ensure your Kubernetes cluster is running and accessible.
## 3. Steps to Test Pod Autoscaling

###  Set Up Horizontal Pod Autoscaling (HPA)
Use the following command to create an HPA for your deployment:

```bash
kubectl autoscale deployment app --cpu-percent=50 --min=1 --max=10
```

- **`--cpu-percent=50`**: The HPA will scale the deployment when the average CPU usage across all pods exceeds 50%.
- **`--min=1`**: The minimum number of pods to run.
- **`--max=10`**: The maximum number of pods that can be created.

###  Get the Cluster IP of the Service
Retrieve the Cluster IP of the service associated with your deployment:

```bash
kubectl get services
```

Identify the Cluster IP of the `app` service from the output.

###  Simulate Load on the Application
Use a load generator to simulate traffic to the `app` service. Replace `Cluster-IP` with the actual IP address obtained in the previous step:

```bash
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.0000000000000001; do wget -q -O- http://Cluster-IP:8080/health; done"
```

- This command runs a `busybox` container that continuously sends HTTP requests to the `/health` endpoint of the `app` service, generating a high load.

###  Monitor Horizontal Pod Autoscaling
In a separate terminal, monitor the HPA as it adjusts the number of pods:

```bash
kubectl get hpa --watch
```

This command will show the scaling activity in real-time.

###  Monitor Node Scaling (If Applicable)
If your cluster supports dynamic node scaling, you can also monitor the node count as the load increases:

```bash
kubectl get node --watch
```

This will display the node scaling activity in response to the increased demand.



## 4. CICD
This GitHub Actions workflow is designed to automate the process of building and deploying a Dockerized application to Docker Hub, followed by restarting a Kubernetes deployment. The workflow is triggered on every push to the `main` branch.

### Workflow Details

#### Triggers
- **Push to `main` branch**: The workflow is triggered whenever changes are pushed to the `main` branch.

#### Jobs

##### 1. Build
This job is responsible for building the Docker image and pushing it to Docker Hub.

- **Runs-on**: `ubuntu-latest`
- **Steps**:
  - **Checkout Code**: Uses `actions/checkout@v3` to pull the latest code from the repository.
  - **Set up Docker Buildx**: Uses `docker/setup-buildx-action@v3` to set up Docker Buildx, a CLI plugin that extends the docker command with the full support of the features provided by Moby BuildKit.
  - **Log in to Docker Hub**: Uses `docker/login-action@v3` to authenticate to Docker Hub using credentials stored in GitHub Secrets.
  - **Build and Push Docker Image**: Uses `docker/build-push-action@v6` to build the Docker image defined by the `Dockerfile` and push it to Docker Hub under the tag `latest`.

##### 2. Deploy
This job restarts the Kubernetes deployment to reflect the newly built Docker image.

- **Runs-on**: `ubuntu-latest`
- **Steps**:
  - **Checkout Code**: Uses `actions/checkout@v4` to pull the latest code from the repository.
  - **Restart Kubernetes Deployment**: Uses `actions-hub/kubectl@v1.29.0` to restart the Kubernetes deployment named `app` by using the `rollout restart deployment/app` command.

#### Environment Variables
- **Docker Hub Credentials**:
  - `DOCKER_USERNAME`: Docker Hub username, stored in GitHub Secrets.
  - `DOCKER_PASSWORD`: Docker Hub password, stored in GitHub Secrets.
- **Kubernetes Configuration**:
  - `KUBECONFIG`: Kubernetes configuration, stored in GitHub Secrets.

#### Secrets
Ensure the following secrets are set up in your GitHub repository:
- `DOCKER_USERNAME`: Your Docker Hub username.
- `DOCKER_PASSWORD`: Your Docker Hub password.
- `KUBECONFIG`: Your Kubernetes configuration file.

### Usage
1. **Push Changes**: Make sure your changes are pushed to the `main` branch.
2. **Monitor Workflow**: The workflow will automatically build and deploy your Dockerized application, then restart the relevant Kubernetes deployment.

