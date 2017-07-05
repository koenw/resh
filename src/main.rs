#[macro_use]
extern crate serde_derive;
extern crate toml;

use std::collections::BTreeMap;

use std::env;
use std::fs::File;
use std::io::prelude::*;

macro_rules! eprintln(
    ($($arg:tt)*) => { {
        let result = writeln!(&mut std::io::stderr(), $($arg)*);
        result.expect("failed to print to stderr");
    } }
);

#[derive(Deserialize)]
struct Config {
    commands: BTreeMap<String,String>,
}

fn main() {
    let cmd = std::env::args().nth(1).expect("not enought arguments");

    // dermine config file path (env variable, then default)
    let config_file = env::var("RESH_CONFIG")
        .unwrap_or_else(|_| {"/etc/resh.yml".to_string()});

    // load allowed command definitions from file -> exit on failure
    let mut contents = String::new();
    File::open(config_file)
        .unwrap_or_else(|e| {
            eprintln!("Failed to open file: {}", e);
            std::process::exit(1)
        })
        .read_to_string(&mut contents)
        .unwrap_or_else(|e| {
            eprintln!("Failed to read file: {}", e);
            std::process::exit(1)
        });

    let config: Config = toml::from_str(&contents).unwrap();

    let command = match config.commands.get(&cmd) {
        Some(bla) => bla,
        None => {
            eprintln!("Failed to get definition of command {}", cmd);
            std::process::exit(1)
        }
    };


    println!("Executing: {}", command);

    let mut child = std::process::Command::new("/bin/sh")
        .arg("-c")
        .arg(command)
        .spawn()
        .expect("failed to execute child");

    let result = child
        .wait()
        .expect("failed to wait on child");

    std::process::exit(result.code().unwrap());
}
