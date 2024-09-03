# **K3S Cluster Deployment and Application Setup - README**

## **1. Requirements Summary**

This deployment involves setting up a K3S cluster for hosting an application, along with Redis and MongoDB services. Below is a summary of the requirements:

### **a. K3S Cluster**

- **Node Groups Configuration:**
  - **MongoDB Node Group:** 3 nodes using `ccx33` instance type.
  - **Redis Node Group:** 3 nodes using `cpx33` instance type.
  - **Application Node Group:** 3 nodes using `cpx33` instance type.
  - **Redis Autoscaling Node Group:** 0-3 nodes using `cpx33` instance type.
  - **Application Autoscaling Node Group:** 0-3 nodes using `cpx33` instance type.

- **Configuration Flexibility:**
  - The number of nodes and their types can be customized in the `dev.tfvars` file.

### **b. Application Deployment**

- **Terraform Automation:**
  - The application is deployed using Terraform, which also handles the setup of autoscaling for both pods and nodes.

### **c. MongoDB Deployment**

- **Cluster Configuration:**
  - **Deployment Model:** 1 Primary and 2 Secondary MongoDB instances.
  - **Networking:** MongoDB instances can be exposed via NodePorts or LoadBalancers (this needs to be configured as per your requirements).
  - **Storage:** 
    - 3 Persistent Volumes, each with 300GB capacity.
  - **Resource Allocation:**
    - MongoDB pods are configured with specific CPU requests and limits.

### **d. Redis Deployment**

- **High Availability Setup:**
  - 6 Redis pods are deployed in a High Availability (HA) configuration. Each Redis have a LoadBalancers (6).
  
- **Storage:**
  - Storage for Redis needs to be defined (this can be configured based on your requirements).

### **e. Storage and Backup**

- **Backup Configuration:**
  - **MongoDB and Redis Backups:** Enabled with a cron job scheduled to run every 2 hours.
  - **Backup Retention:** Old backups are cleaned up after 2 days.

### **f. Monitoring**

- **Grafana Server:**
  - Accessible at `NodeIP:3009`.
  
- **Monitoring Components:**
  - **Cluster Resources:** Monitoring of CPU, memory, and storage usage across the cluster.
  - **Application Monitoring:** Track application performance, including pod health and response times.
  - **MongoDB Monitoring:** Monitor the health, performance, and storage utilization of MongoDB instances.
  - **Redis Monitoring:** Monitor the health and performance of Redis pods, including key metrics for memory usage and response times.

---

This README provides an overview of the key components and configuration details for deploying the application along with MongoDB and Redis on a K3S cluster. For detailed setup instructions and further customization, refer to the Terraform scripts and configuration files provided.
