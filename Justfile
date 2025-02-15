# List all available recipes.
default:
    @docker compose ps

# Open up the task in a browser.
view-task:
    xdg-open assets/task.pdf

# Fire up all services.
start:
    docker compose up --detach
    docker compose logs --follow

# Bring all services to a halt.
stop:
    docker compose down

# Shutdown and re-ignite all services.
restart: stop start

# Ensure correct ownership of the `./data` folder.
[confirm]
set-ownership:
    sudo chown astrumaureus:users -R data

# Erase all services' persistent data volumes.
[confirm]
flushall: stop set-ownership
    docker compose down --volumes
    rm -rf ./data/postgresql/*
