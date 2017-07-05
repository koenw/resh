# resh

`resh`, the restricted shell, allows only the execution of previously defined
aliases. This allows you to precisely control what commands and arguments a
user is able to execute by setting their default shell to resh.

It is useful for example to limit a monitoring user to a limited set of
predefined commands, in a way similar to NRPE.

## Usage

Define aliases for the commands you want to allow in the *commands* section of
`/etc/resh.toml`:

```sh
$ cat /etc/resh.toml
[commands]
foo = "echo hello"
```

Then, set resh as the default shell for the user you want to restrict. Now,
the user will only be able to execute your predefined commands:

```sh
#  su - test foo
hello
```

Or using ssh:
```sh
ssh test@localhost foo
hello
```
