#[macro_use]
extern crate serde_derive;
extern crate toml;

#[macro_use]
extern crate clap;

use std::collections::BTreeMap;
use std::fs::File;
use std::io::prelude::*;

use clap::{App, Arg};

macro_rules! die(
    ($($arg:tt)*) => { {
        writeln!(std::io::stderr(), $($arg)*)
            .expect("Failed to print to stderr");
        std::process::exit(1);
    } }
);

#[derive(Deserialize)]
struct Config {
    commands: BTreeMap<String, String>,
}

fn read_config<P: AsRef<std::path::Path>>(path: P) -> Result<Config, Box<dyn std::error::Error>> {
    let mut contents = String::new();

    File::open(path)?.read_to_string(&mut contents)?;

    let config: Config = toml::from_str(&contents)?;
    Ok(config)
}

fn run_command(command: &str) -> Result<i32, Box<dyn std::error::Error>> {
    let mut child = std::process::Command::new("/bin/sh")
        .arg("-c")
        .arg(command)
        .spawn()?;

    child
        .wait()?
        .code()
        .ok_or_else(|| std::io::Error::last_os_error().into())
}

fn main() {
    let matches = App::new(crate_name!())
        .version(crate_version!())
        .author("Koen Wilde <koen@chillheid.nl>")
        .about("Restricted (ssh) Shell that only allows whitelisted commands")
        .arg(
            Arg::with_name("command")
                .short("-c")
                .help("Alias of command to execute")
                .value_name("COMMAND"),
        )
        .get_matches();

    let command_alias = match matches.value_of("command") {
        Some(cmd) => String::from(cmd),
        None => match std::env::var("SSH_ORIGINAL_COMMAND") {
            Ok(cmd) => cmd,
            _ => die!("Usage: {} <command alias>", crate_name!()),
        },
    };

    let config_file = std::env::var("RESH_CONFIG").unwrap_or_else(|_| "/etc/resh.toml".to_string());

    let config: Config = read_config(&config_file).unwrap_or_else(|e| {
        die!("Failed to read {}: {}", config_file, e);
    });

    let full_command = match config.commands.get(&command_alias) {
        Some(cmd) => cmd,
        None => die!("Undefined command alias: {}", command_alias),
    };

    let exitcode = run_command(full_command).unwrap_or(1);

    std::process::exit(exitcode);
}
