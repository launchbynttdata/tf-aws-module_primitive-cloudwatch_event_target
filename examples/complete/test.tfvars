logical_product_family  = "lpf"
logical_product_service = "lps"
class_env               = "dev"
instance_env            = "01"
instance_resource       = "01"

resource_names_map = {
  event_rule   = { name = "eventrule", max_length = 64 }
  log_group    = { name = "cloudwatchloggroup", max_length = 512 }
  event_target = { name = "eventtarget", max_length = 64 }
  kms_key      = { name = "kmskey", max_length = 64 }
}

tags = {
  Environment = "test"
}
