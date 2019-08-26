data "template_file" "dd_message_slack_underused_servers" {
  template = "**Hostname**: {{host.name}}\n**IP**: {{host.ip}}\n**Provider**: $${provider}\n{{#is_warning}}$${dd_underused_servers_slack_channel}{{/is_warning}}\n{{#is_warning_recovery}}$${dd_underused_servers_slack_channel}{{/is_warning_recovery}}\n{{#is_alert}}$${dd_underused_servers_slack_channel}{{/is_alert}}\n{{#is_alert_recovery}}$${dd_underused_servers_slack_channel}{{/is_alert_recovery}}"

  vars = {
    provider                           = var.host_provider
    dd_underused_servers_slack_channel = var.dd_underused_servers_slack_channel
  }
}

resource "datadog_monitor" "dd_memory_monitor_underused" {
  message        = data.template_file.dd_message_slack_underused_servers.rendered
  name           = "Memory usage is low for ${var.dd_group_name} group"
  query          = "avg(last_1h):avg:system.mem.pct_usable{devops_group:${var.dd_group_name}} by {host} > 0.9"
  type           = "metric alert"
  notify_no_data = false
  tags           = ["service:devops", "memory", "underused"]

  thresholds = {
    critical = 0.9
  }

  require_full_window = false
  include_tags        = false
  new_host_delay      = 300
}

resource "datadog_monitor" "dd_loadavg_monitor_underused" {
  message        = data.template_file.dd_message_slack_underused_servers.rendered
  name           = "LoadAvg5 is low for ${var.dd_group_name} group"
  query          = "avg(last_1h):avg:system.load.norm.5{devops_group:${var.dd_group_name}} by {host} < 0.1"
  type           = "metric alert"
  notify_no_data = false
  tags           = ["service:devops", "cpu", "underused"]

  thresholds = {
    critical = 0.1
  }

  require_full_window = false
  include_tags        = false
  new_host_delay      = 300
}
