variable "send_logs_to_loganalytics" {
  description = "Send logs to log analytics?"
  default     = true
}

variable "arm_resource_id" {
  description = "The arm resource id of the resource to send logs to."
  default     = ""
}

variable "log_name" {
  description = "The name of the diagnostic setting."
  default     = "log"
}

variable "log_analytics_id" {
  description = "The id of the log analytics workspace."
  default     = ""
}
