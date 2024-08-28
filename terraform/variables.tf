variable "docker_username" {
  type = string
  description = "Docker username"
}

variable "docker_password" {
  type = string
  description = "Docker password"
}

variable "master_nodes" {
  type = number
  description = "number of master nodes: 1,3,5"
  default = 3
}

variable "nodes" {
  type = number
  description = "number of nodes from default node pool"
  default = 1
}

variable "min_nodes" {
  type = number
  description = "number of minimum nodes from autoscale node pool"
  default = 1
}

variable "max_nodes" {
  type = number
  description = "number of maximum nodes from autoscale node pool"
  default = 5
}


