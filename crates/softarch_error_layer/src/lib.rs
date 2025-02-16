use color_eyre::eyre::Report;
use tracing_error::ErrorLayer;
use tracing_subscriber::prelude::*;
use tracing_subscriber::{EnvFilter, fmt};
pub use {color_eyre, tracing, tracing_error, tracing_subscriber};

#[expect(clippy::missing_errors_doc)]
pub fn install_tracing() -> Result<(), Report> {
    let filter_layer = EnvFilter::try_from_default_env().or_else(|_| EnvFilter::try_new("info"))?;
    let format_layer = fmt::layer()
        .with_target(true)
        .without_time()
        .with_writer(std::io::stderr);

    tracing_subscriber::registry()
        .with(filter_layer)
        .with(format_layer)
        .with(ErrorLayer::default())
        .try_init()?;

    Ok(())
}

#[expect(clippy::missing_errors_doc)]
pub fn install_error_layer() -> Result<(), Report> {
    color_eyre::install()?;
    self::install_tracing()?;
    Ok(())
}
