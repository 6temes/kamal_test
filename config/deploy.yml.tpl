# Name of your application. Used to uniquely configure containers.
service: kamal_test

# Name of the container image.
image: ghcr.io/6temes/kamal_test

# Deploy to these servers.
servers:
  web:
    - ${SERVER_PUBLIC_IP}
  job:
    hosts:
      - ${SERVER_PUBLIC_IP}
    cmd: bin/jobs

# Enable SSL auto certification via Let's Encrypt and allow for multiple apps on a single web server.
# Remove this section when using multiple web servers and ensure you terminate SSL at your load balancer.
#
# Note: If using Cloudflare, set encryption mode in SSL/TLS setting to "Full" to enable CF-to-app encryption.
proxy:
  ssl: true
  host: ${APP_HOSTNAME}

# Credentials for your image host.
registry:
  # Specify the registry server, if you're not using Docker Hub
  server: ghcr.io
  username: 6temes

  # Always use an access token rather than real password when possible.
  password:
    - GHCR_PAT

# Inject ENV variables into containers (secrets come from .kamal/secrets).
env:
  secret:
    - RAILS_MASTER_KEY
    - POSTGRES_PASSWORD
  clear:
    # Run the Solid Queue Supervisor inside the web server's Puma process to do jobs.
    # When you start using multiple servers, you should split out job processing to a dedicated machine.
    SOLID_QUEUE_IN_PUMA: true

    # Set number of processes dedicated to Solid Queue (default: 1)
    # JOB_CONCURRENCY: 3

    # Set number of cores available to the application on each server (default: 1).
    CONCURRENCY: 2

    # Database configuration for PostgreSQL
    DB_HOST: kamal_test-db
    DB_NAME: kamal_test_pg_production
    DB_USER: kamal_test_pg
    DB_PORT: 5432

    # Log everything from Rails
    # RAILS_LOG_LEVEL: debug

# Aliases are triggered with "bin/kamal <alias>". You can overwrite arguments on invocation:
# "bin/kamal logs -r job" will tail logs from the first server in the job section.
aliases:
  console: app exec --interactive --reuse "bin/rails console"
  shell: app exec --interactive --reuse "bash"
  logs: app logs -f
  dbc: app exec --interactive --reuse "bin/rails dbconsole"


# Use a persistent storage volume for sqlite database files and local Active Storage files.
# Recommended to change this to a mounted volume path that is backed up off server.
volumes:
  - "kamal_test_storage:/rails/storage"


# Bridge fingerprinted assets, like JS and CSS, between versions to avoid
# hitting 404 on in-flight requests. Combines all files from new and old
# version inside the asset_path.
asset_path: /rails/public/assets

# Configure the image builder.
builder:
  arch: amd64

  # # Build image via remote server (useful for faster amd64 builds on arm64 computers)
  # remote: ssh://docker@docker-builder-server
  #
  # # Pass arguments and secrets to the Docker build process
  # args:
  #   RUBY_VERSION: 3.4.5
  # secrets:
  #   - GITHUB_TOKEN
  #   - RAILS_MASTER_KEY

# Use a different ssh user than root
ssh:
  user: admin
  port: 54022

# Use accessory services (secrets come from .kamal/secrets).
accessories:
  db:
    image: postgres:17
    host: ${SERVER_PUBLIC_IP}
    # Only expose PostgreSQL locally to prevent external access
    port: "127.0.0.1:5432:5432"
    env:
      clear:
        POSTGRES_DB: kamal_test_pg_production
        POSTGRES_USER: kamal_test_pg
      secret:
        - POSTGRES_PASSWORD
    directories:
      - data:/var/lib/postgresql/data
  # redis:
  #   image: redis:7.0
  #   host: ${SERVER_PUBLIC_IP}
  #   port: 6379
  #   directories:
  #     - data:/data
