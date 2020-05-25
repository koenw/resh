# resh

[![Build Status](https://api.travis-ci.org/koenw/resh.svg?branch=master)](https://travis-ci.org/koenw/resh)

`resh` is a shell that only allows the execution of previously
whitelisted commands. Use it to restrict automated ssh logins.

## Usage

Define aliases for the commands you want to allow in the *commands* section of
`/etc/resh.toml`:

```sh
$ cat /etc/resh.toml
[commands]
foo = "echo hello"
```

Next set resh as the login shell for the user you want to restrict. The user
will now only be able to execute the whitelisted commands:

```sh
# su - example_user
Usage: -resh <command alias>
# su - example_user bar
Undefined command alias: bar
#  su - example_user foo
hello
```

Or using ssh:
```sh
$ ssh example_user@localhost foo
hello
```

### Alternative config file locations

You can specify an alternative config file by setting the `RESH_CONFIG`
environmental variable. For example, to specify a config file per ssh key:

```sh
$ cat ~example_user/.ssh/authorized_keys
environment="RESH_CONFIG=/home/test/resh.toml" AAAAB3NzaC1yc2EAAAADAQABAAACAQD7BsnSaa0gkPJDGZM7psAEkx+68ILJlKHS6MlUfVpQu7UoercvJXqctHczeIEf1eJToK7RmiKufoicLkHQplRpI9kP4IDAx2V0LO4BRncIOyF8wk6I7N6k6glAxePA4MgPaSsFp8SyXYW9wy+0491YHr9sWaqaKG78OQSCyf+/wwynRnwdn2u0dcRl064CGxrYleGe0AHHOSl9jj9J2Ve6M7pjZLuixRLqB2VBYyIAwy/zO7dvuxxvLIGr31TqKdLnnUvLKeInn5IU+UPMxuHG9DC9yLnif29OUzNRERTF4utkRI+ywByFTj/QePp+uTvmVv0PtkGwm77LKxeBP7jP3Hhe2uvf5clApcF+6EjFBNKWxVReH35NGPasY8DNL7Mt5CfBZcdi4nhQZyCQ7Z/XlXmJRMxmYsowhHQB8HkOM8MpHPqP9EBf9eTnxhMaA5qnrSy/z+1vdKHVXc4camSF8z7dRJKDmuoYl+aPcjS5MX6AEVz5gtFsizjhLq+mp2HkvskSZCPY87D0/hriPPtSMUlhh4XKyFJ2VzkfIr1uqQlaN1tIPdCAdUDjH5o5fnqSFHqkD8iah8OiNhmGLk2VPiYohnMLcDdLGtPMkOpX3ODgjNOTcaUfaMZW4IacVcHA2A11Zxe8r73qcjKjcX5mEppMa1Z2vosqJn2dGTasHQ== example_user@example
```

### Use resh without changing the login shell

If you don't want to change the user's login shell, you can force resh on a
per-key basis by setting the `command` option for the ssh public key:

```sh
$ cat ~example_user/.ssh/authorized_keys
command="/usr/local/bin/resh" AAAAB3NzaC1yc2EAAAADAQABAAACAQD7BsnSaa0gkPJDGZM7psAEkx+68ILJlKHS6MlUfVpQu7UoercvJXqctHczeIEf1eJToK7RmiKufoicLkHQplRpI9kP4IDAx2V0LO4BRncIOyF8wk6I7N6k6glAxePA4MgPaSsFp8SyXYW9wy+0491YHr9sWaqaKG78OQSCyf+/wwynRnwdn2u0dcRl064CGxrYleGe0AHHOSl9jj9J2Ve6M7pjZLuixRLqB2VBYyIAwy/zO7dvuxxvLIGr31TqKdLnnUvLKeInn5IU+UPMxuHG9DC9yLnif29OUzNRERTF4utkRI+ywByFTj/QePp+uTvmVv0PtkGwm77LKxeBP7jP3Hhe2uvf5clApcF+6EjFBNKWxVReH35NGPasY8DNL7Mt5CfBZcdi4nhQZyCQ7Z/XlXmJRMxmYsowhHQB8HkOM8MpHPqP9EBf9eTnxhMaA5qnrSy/z+1vdKHVXc4camSF8z7dRJKDmuoYl+aPcjS5MX6AEVz5gtFsizjhLq+mp2HkvskSZCPY87D0/hriPPtSMUlhh4XKyFJ2VzkfIr1uqQlaN1tIPdCAdUDjH5o5fnqSFHqkD8iah8OiNhmGLk2VPiYohnMLcDdLGtPMkOpX3ODgjNOTcaUfaMZW4IacVcHA2A11Zxe8r73qcjKjcX5mEppMa1Z2vosqJn2dGTasHQ== example_user@example
```

### Full ssh *`authorized_keys`* example

```sh
$ cat ~example_user/.ssh/authorized_keys
command="/usr/local/bin/resh",environment="RESH_CONFIG=/usr/local/etc/resh.toml",restrict AAAAB3NzaC1yc2EAAAADAQABAAACAQD7BsnSaa0gkPJDGZM7psAEkx+68ILJlKHS6MlUfVpQu7UoercvJXqctHczeIEf1eJToK7RmiKufoicLkHQplRpI9kP4IDAx2V0LO4BRncIOyF8wk6I7N6k6glAxePA4MgPaSsFp8SyXYW9wy+0491YHr9sWaqaKG78OQSCyf+/wwynRnwdn2u0dcRl064CGxrYleGe0AHHOSl9jj9J2Ve6M7pjZLuixRLqB2VBYyIAwy/zO7dvuxxvLIGr31TqKdLnnUvLKeInn5IU+UPMxuHG9DC9yLnif29OUzNRERTF4utkRI+ywByFTj/QePp+uTvmVv0PtkGwm77LKxeBP7jP3Hhe2uvf5clApcF+6EjFBNKWxVReH35NGPasY8DNL7Mt5CfBZcdi4nhQZyCQ7Z/XlXmJRMxmYsowhHQB8HkOM8MpHPqP9EBf9eTnxhMaA5qnrSy/z+1vdKHVXc4camSF8z7dRJKDmuoYl+aPcjS5MX6AEVz5gtFsizjhLq+mp2HkvskSZCPY87D0/hriPPtSMUlhh4XKyFJ2VzkfIr1uqQlaN1tIPdCAdUDjH5o5fnqSFHqkD8iah8OiNhmGLk2VPiYohnMLcDdLGtPMkOpX3ODgjNOTcaUfaMZW4IacVcHA2A11Zxe8r73qcjKjcX5mEppMa1Z2vosqJn2dGTasHQ== example_user@example
```

For more information on the options you can specify in the `authorized_keys`
file, refer to the *`AUTHORIZED_KEYS FILE FORMAT`* section of `man 8 sshd`. You
may especially be interested in the `restrict` option, which disables
features like tcp port forwarding.

## Building

To build resh, you will need rust and cargo. Then, from the repo root
directory:

```sh
cargo build --release
```

The resulting binary will be written to `target/release/resh`.

## Future ideas

* Possibly support an *IncludeDir* option in the config file, for easier
  provisioning from e.g. puppet or ansible.
* Provide pre-build binaries for OpenBSD, FreeBSD and linux.

## Feedback & Questions

If you've got any feedback or questions, please don't hesitate :)
