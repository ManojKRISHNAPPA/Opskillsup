variable "project" {
  type    = string
  default = "opskillup"
}

variable "kubernetes_version" {
  type    = string
  default = "1.34"
}

variable "ssh_key_name" {
  type        = string
  description = "Existing EC2 key pair name in the configured AWS region."
  default     = "advance-devops-course"
}

variable "ssh_source_security_group_ids" {
  type        = list(string)
  description = "Security groups allowed to SSH to the managed nodes."
  default     = []
}