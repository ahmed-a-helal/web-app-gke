project             = "ahmed-attia-iti" 
name_prefix         = "iti-webapp-project"
region              = ["europe-west8", "us-east1"]
cidr_subnet         = ["172.16.0.0/29", "172.16.128.0/29"]
database_image_name = "mongo:1"
frontend_image_name = "web:1"
alpine_image_name   = "alpine:1"
helmdir             = "helm"