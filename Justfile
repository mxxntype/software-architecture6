alias up := start
alias down := stop
alias reup := restart

# List all available recipes.
default:
    @just --list

# Open up the task in a browser.
view-task:
    xdg-open assets/task.pdf

# Fire up all services.
start:
    docker compose up --detach

# Bring all services to a halt.
stop:
    docker compose down

# Shutdown and re-ignite all services.
restart: stop start

# Run all tests in the workspace.
test:
    cargo nextest run --workspace --no-fail-fast

# Ensure correct ownership of the `./data` folder.
[confirm]
set-ownership:
    sudo chown astrumaureus:users -R data

# Erase all services' persistent data volumes.
[confirm]
flushall: stop set-ownership
    docker compose down --volumes
    rm -rf ./data/postgresql/*
