#!/usr/bin/env bats

setup() {
    load '../test/test_helper/bats-support/load'
    load '../test/test_helper/bats-assert/load'
}

@test "Setup" {
    run docker-compose -f test/docker-compose.yaml up --build -d
    [ $status -eq 0 ]
    run docker exec -it resh-test-ssh-client cp /mnt/resh-ssh-volume/ssh_host_ed25519_key /root/.ssh/ssh_host_ed25519_key
    [ $status -eq 0 ]
    run docker exec -it resh-test-ssh-client chmod 700 /root/.ssh
    [ $status -eq 0 ]
    run docker exec -it resh-test-ssh-client sh -c 'echo [resh-test]:1234 $(cat /mnt/resh-ssh-volume/ssh_host_ed25519_key.pub) >> /root/.ssh/known_hosts'
    [ $status -eq 0 ]
    run docker exec -it resh-test-ssh-client chmod 700 /root/.ssh/known_hosts
    [ $status -eq 0 ]
    run docker exec -it resh-test-ssh-client cat /root/.ssh/known_hosts
    [ $status -eq 0 ]

    # Docker resh-test-ssh-client is authorized into resh-test
    run docker exec -it resh-test-ssh-client ssh -i /root/.ssh/ssh_host_ed25519_key root@resh-test -p 1234 echo 'hello world!'
    [ $status -eq 0 ]
    refute_output --partial 'Connection refused'
    refute_output --partial 'Permission denied'
    assert_output --partial 'hello world!'
}

@test "resh-test-toml-found" {
    run docker cp test/resh.toml resh-test:/etc/resh.toml
    [ $status -eq 0 ]
    run docker exec -it resh-test ./resh -c
    [ $status -ne 0 ]
    assert_output --partial 'a value is required for'
}

@test "resh-test-toml-global-command-valid" {
    run docker exec -it resh-test ./resh -c ls
    assert_output --partial 'root'
}

@test "resh-test-toml-global-command-unavailable" {
    run docker exec -it resh-test ./resh -c touch
    assert_output --partial 'Undefined command alias'
}

@test "resh-test-toml-global-user-command" {
    run docker exec -it resh-test ./resh -c lsa
    assert_output --partial '..'
}

@test "resh-test-toml-global-user-command-with-args" {
    run docker exec -it resh-test ./resh -c 'echo hello world!'
    assert_output --partial 'hello world!'
}

@test "resh-test-toml-global-user-command-overrides-global" {
    run docker exec -it resh-test ./resh -c 'foo'
    assert_output --partial 'bar override'
}

@test "resh-test-ssh-entrypoint-full" {
    run docker exec -it resh-test mkdir -p /usr/local/etc
    [ $status -eq 0 ]
    run docker cp test/resh.toml resh-test:/usr/local/etc/resh.toml
    [ $status -eq 0 ]
    run docker exec resh-test /bin/sh -c "sed -i 's/^/command=\"\\/root\\/resh\",environment=\"RESH_CONFIG=\\/usr\\/local\\/etc\\/resh.toml\", /' /root/.ssh/authorized_keys"
    [ $status -eq 0 ]
    run docker exec -it resh-test-ssh-client ssh -i /root/.ssh/ssh_host_ed25519_key root@resh-test -p 1234 foo
    [ $status -eq 0 ]
    refute_output --partial 'Connection refused'
    refute_output --partial 'Permission denied'
    assert_output --partial 'bar override'
}

@test "Teardown" {
    teardown_once
}

teardown_once() {
    docker kill resh-test
    docker kill resh-test-ssh-client
    docker rm resh-test
    docker rm resh-test-ssh-client
    docker volume rm test_resh-ssh-volume
    docker network rm test_resh-isolated-network
}
