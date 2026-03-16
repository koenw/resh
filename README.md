<div align="center">

<br/>

<h1>resh</h1>

<p><em>Restrict access. Define commands. Stay in control.</em></p>

<p>
  <a href="https://www.rust-lang.org"><img src="https://img.shields.io/badge/Rust-2018-000000?style=for-the-badge&logo=rust&logoColor=white" alt="Rust 2018" /></a>
  <a href="https://crates.io/crates/resh"><img src="https://img.shields.io/badge/crates.io-v0.2.0-orange?style=for-the-badge&logo=rust&logoColor=white" alt="crates.io v0.2.0" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-22c55e?style=for-the-badge" alt="MIT License" /></a>
</p>

<p>A secure, restricted SSH-compatible shell built in Rust.<br/>Define exactly which commands users can run. Nothing more. Nothing less.</p>

<br/>

</div>

---

## What is resh?

`resh` is a **restricted shell** you install as a user's login shell or enforce via an SSH key. Define a list of command aliases in a simple TOML config, and users can only execute those — by name. No shell escapes, no surprises.

It integrates natively with **SSH** via `SSH_ORIGINAL_COMMAND`, supports **per-user command overrides**, and drops into an **interactive prompt** when no command is given.

---

## Features

|     | Feature                   | Description                                                     |
| --- | ------------------------- | --------------------------------------------------------------- |
| 🔒  | **Command allowlist**     | Users can only run explicitly defined command aliases           |
| 👤  | **Per-user overrides**    | Define different commands or arguments on a per-user basis      |
| 🔧  | **Argument substitution** | Pass arguments through with `%@`, `%1`, `%2`, …                 |
| 🖥️  | **Interactive mode**      | Drop into a `resh>` prompt when no command is provided          |
| 🔑  | **SSH integration**       | Reads `SSH_ORIGINAL_COMMAND` for seamless key-level enforcement |
| 📁  | **Per-key config**        | Scope config per SSH key via `RESH_CONFIG` in `authorized_keys` |
| ⚙️  | **TOML config**           | Simple, human-readable configuration with sane defaults         |

---

## Quick Start

### 1 · Install resh

Via Cargo (installs to `~/.cargo/bin`):

```sh
cargo install resh
```

Or build from source:

```sh
cargo build --release
# binary written to target/release/resh
```

### 2 · Configure commands

Create `/etc/resh.toml` and define your allowed command aliases:

```toml
[commands]
ls  = "ls -l"
foo = "echo bar"

[user_commands.alice]
echo = "echo %@"
foo  = "echo bar override"
```

`%@` passes all arguments through. `%1`, `%2`, … pass individual positional arguments.

### 3 · Set as the login shell

```sh
usermod -s /usr/local/bin/resh example_user
```

The user can now only execute whitelisted aliases:

```sh
$ ssh example_user@localhost foo
bar
$ ssh example_user@localhost notallowed
Undefined command alias: notallowed
```

### 4 · Interactive mode

When no command is given, resh drops into an interactive prompt:

```sh
$ su - example_user
resh> foo
bar
resh>
```

---

## Config Reference

| Key                          | Description                                    |
| ---------------------------- | ---------------------------------------------- |
| `[commands]`                 | Global command aliases available to all users  |
| `[user_commands.<username>]` | Per-user overrides that shadow global commands |
| `%@`                         | Substitute all provided arguments              |
| `%1`, `%2`, …                | Substitute individual positional arguments     |
| `RESH_CONFIG`                | Override the default `/etc/resh.toml` path     |

---

## SSH `authorized_keys` Integration

Force resh for a specific key without changing the login shell:

```sh
# ~/.ssh/authorized_keys
command="/usr/local/bin/resh" ssh-rsa AAAA... example_user@example
```

Scope config per key and lock down SSH features with `restrict`:

```sh
command="/usr/local/bin/resh",environment="RESH_CONFIG=/home/example_user/resh.toml",restrict ssh-rsa AAAA... example_user@example
```

> The `restrict` option disables TCP port forwarding and other SSH features. See the `AUTHORIZED_KEYS FILE FORMAT` section of `man 8 sshd` for the full list of options.

---

## Stack

| Layer          | Technology                |
| -------------- | ------------------------- |
| 🦀 Language    | Rust (edition 2018)       |
| 📦 Config      | TOML via `serde` + `toml` |
| 🖥️ CLI         | `clap` v4                 |
| 🔍 User lookup | `whoami`                  |

---

## Project Structure

```
resh/
├── src/
│   └── main.rs               # Core shell logic, config parsing, command execution
├── test/
│   ├── docker-compose.yaml   # Integration test environment
│   ├── resh.toml             # Test config
│   └── test.bats             # Bats integration tests
├── Cargo.toml                # Package manifest and dependencies
└── test.sh                   # Test runner script
```

---

<div align="center">

Made with ❤️ by [Koen Wilde](https://github.com/koenw)

MIT License · Free forever · Self-host it

</div>
