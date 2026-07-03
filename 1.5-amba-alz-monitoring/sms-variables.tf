variable "enable_sms_action_group" {
  type        = bool
  description = "Create an additional Action Group with SMS receivers and optional email receivers."
  default     = false
}

variable "sms_action_group_name" {
  type        = string
  description = "Name of the SMS-enabled Action Group."
  default     = "ag-land03-amba-sms"
}

variable "sms_action_group_short_name" {
  type        = string
  description = "Short name of the SMS-enabled Action Group. Azure requires this value to be 12 characters or fewer."
  default     = "ambasms"
}

variable "sms_action_group_email_receivers" {
  type        = list(string)
  description = "Optional email receivers to add to the SMS-enabled Action Group."
  default     = []
}

variable "sms_receivers" {
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  description = "SMS receivers for the SMS-enabled Action Group. country_code should not include '+'. Example for Korea: country_code = \"82\"."
  default     = []
}
