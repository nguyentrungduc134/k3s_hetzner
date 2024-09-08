variable "redis_config" {
  type = any
  default = {
    volume_size                      = ""
  }
  description = "Specify the configuration settings for Redis, including the name, environment, storage options, replication settings, and custom YAML values."
}
