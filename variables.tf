/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* Gitlab | Variable Definition                                         */
/*----------------------------------------------------------------------*/
variable "github_runner_parameters" {
  type        = any
  description = "github-runner parameteres to configure github-runner module"
  default     = {}
}

variable "github_runner_defaults" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}