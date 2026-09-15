variable "project_id" {
  type = string
}

variable "user_emails" {
  description = "Users to grant IAP tunnel + compute viewer"
  type        = list(string)
}
