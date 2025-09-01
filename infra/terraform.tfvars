# AWS configuration for Kamal app deployment

# AWS region to deploy to
aws_region = "ap-northeast-1"

# SSH public key for server access
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzjIooA5fBusTQfKQhUM13DPf6WN3IqwxxZKcbiDvnDzdSMSm/7wRnLH1LanYjP32De4BcHHXi0z1ES8ZnPryJnQGDpBkxHuOqRfMjrtUBuykvlluxzGqvxjVRP/WD9zk7X18+dZzSdT2Itc91twsbQ7WR48CczG/K72v7CUUcNQ0iGG6cvaM3aC+Oe5ZWhtxJN/Whvy6wXbun16iPjFyJeYmT+o9h2mDDEebzZ1UQbyfdtllsHiHQ3jk7jcdHbMHt1HPm7YbcSjh4S+LBzFy5/XyVOXChCknThkSiR+OUeaS2C+8YjJPnWRcc5vaDrjjcA2NfySCOuO/6QaWWpatToqvUcPAyNjv/wyCoIGG7YlQRg5/a2WeB1iN8lu0++AUhoJ8YeZSL3hlNFBD006CT1QKrz7HBnDJszFqbgCc9d7KkBKgmCDJXpxfZFQvit8ajA8zER8jPLqrRjcTZ1szCpabBp/RNvMhF2Kp+rsP/I898otUnHnpjS6AZxDimyNZHbFmgeAfAuCjpT4teVZ46ukvCAPshVxfr5dIh5annAxx38XovVayQ5u6ecHgoNOTmBrajCQCcVDax9J5DJQo9kCknlhAxZcLc4PgZI8Cf4JZ7k048j70YDLNZaJUL487TJJHsjPz0bl2NSuGB8PQoOAtlhmmibSbXowYe1sn0Mw== daniel@6temes.cat"

# Server settings
project_name  = "kamal-app"
server_name   = "kamal-app-server"
instance_type = "t3.medium" # 4GB RAM, 2 vCPUs
environment   = "production"

# Storage settings
root_volume_size = 20 # GB

# Enable detailed CloudWatch monitoring (additional cost)
enable_detailed_monitoring = false

# Cloudflare DNS settings
domain_name   = "6temes.net"
app_subdomain = "kamal-test"
