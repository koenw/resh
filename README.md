# NRPE-SH

`nrpe-sh` is a shell intended for nagios remote command execution. It does
functionally the same as the nagios NRPE daemon, except it uses ssh as a
transport instead of a separate daemon.

The idea is that you configure nrpe-sh as the system shell for the user you
want to execute local checks as. You configure the commands that are allowed to
be executed; using short aliases in a way similar to NRPE. All other commands
are disallowed. This way you can safely execute nagios checks over ssh, without
worrying about handing out shell access; with the added benefit over NRPE that
you don't need another daemon listening on the network.
