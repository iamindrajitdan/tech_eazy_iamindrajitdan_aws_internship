variable "stage" {
  description = "Deployment stage (dev/prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "stop_time" {
  description = "Shutdown delay in minutes"
  type        = number
  default     = 30
}

variable "repo_url" {
  description = "GitHub repository URL"
  type        = string
  default     = "https://github.com/techeazy-consulting/techeazy-devops"
}