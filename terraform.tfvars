# DO YOUR OVERRIDING OF DEFAULTS HERE

# GENERAL VARIABLES
# tags = { foo: "bar"}
# location = "West Europe"

# RESOURCE-GROUP VARIABLES
rg_name = "rg-acs-test"
# create_rg = false

# KEYVAULT VARIABLES
kv_name = "kv-acs-test-12345"
kv_rg_name = "rg-acs-test"
# create_kv = false
# byok_name = "byok"
# enable_kv_logs_to_loganalytics = true

# MANAGED IDENTITY VARIABLES
mi_name = "mi-acs"
mi_rg_name = "rg-acs-test"
# create_mi = false

# DEAD LETTER STORAGE ACCOUNT VARIABLES
sa_name = "sadeadletter12345"
# sa_replication_type = "GZRS"
# sa_tier = "Standard"
# enable_sa_logs_to_loganalytics = true

# ACS VARIABLES
acs_name = "acs-1234"
# data_location = "Europe"
# enable_acs_logs_to_loganalytics = true

# EVENT HUB VARIABLES
eventhub_name = "acs-eventhub-12345"
# eventhub_capacity = 1
# eventhub_sku = "Premium"
# eventhub_zone_redundant = true
# eventhub_partition_count = 2
# eventhub_message_retention = 30
# enable_eventhub_logs_to_loganalytics = true

# EVENTGRID VARIABLES
eventgrid_name = "acs-eventgrid-12345"
# enable_eventgrid_logs_to_loganalytics = true

# LOG ANALYTICS VARIABLES
# loganalytics_name = "acs-loganalytics"
# loganalytics_sku = "PerGB2018"
# loganalytics_retention_in_days = 30
