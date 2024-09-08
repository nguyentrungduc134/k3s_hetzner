variable "mongodb_config" {
  type = any
  default = {
    volume_size                      = ""
    replica_count                    = 3
    custom_databases                 = ""
    custom_databases_usernames       = ""
    custom_databases_passwords       = ""
  }
  description = "Specify the configuration settings for Mongodb, including the name, environment, storage options, replication settings, and custom YAML values."
}
