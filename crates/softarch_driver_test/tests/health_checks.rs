#![expect(clippy::used_underscore_binding)]

use elasticsearch::Elasticsearch;
use elasticsearch::http::transport::Transport;
use redis::Commands;
use rstest::{fixture, rstest};
use softarch_error_layer::color_eyre::eyre::{ContextCompat, Report};
use sqlx::PgPool;
use std::env;
use std::time::Duration;

#[fixture]
fn error_layer() {
    softarch_error_layer::install_error_layer().unwrap();
}

#[rstest]
#[timeout(Duration::from_secs(3))]
#[tokio::test]
async fn elasticsearch(_error_layer: ()) -> Result<(), Report> {
    let transport = Transport::single_node("http://localhost:9200")?;
    let client = Elasticsearch::new(transport);
    let _ = client
        .health_report(elasticsearch::HealthReportParts::None)
        .send()
        .await?;
    Ok(())
}

#[rstest]
#[timeout(Duration::from_secs(3))]
#[tokio::test]
async fn redis(_error_layer: ()) -> Result<(), Report> {
    let client = redis::Client::open("redis://localhost:6379")?;
    let mut connection = client.get_connection()?;
    let _: () = connection.ping()?;
    Ok(())
}

#[rstest]
#[timeout(Duration::from_secs(3))]
#[tokio::test]
async fn postgresql(_error_layer: ()) -> Result<(), Report> {
    let database_url = env::var("DATABASE_URL")?;
    let pool = PgPool::connect(&database_url).await?;
    let mut connection = pool
        .try_acquire()
        .wrap_err("Failed to get a connection from the pool")?;
    let records = sqlx::query!("SELECT * FROM _sqlx_migrations")
        .fetch_all(connection.as_mut())
        .await?;
    for _ in records {}

    Ok(())
}
