# shellcheck disable=SC2030,SC2031
setup() {
    load 'lib/bats-support/load'
    load 'lib/bats-assert/load'

    HOST=http://localhost:8000
}


@test "api is returning version" {
    run curl -s ${HOST}/version
    assert_output --partial "ClamAV"
}

@test "scan clean file" {
    run curl -s -F "file=@files/clean.zip" ${HOST}/scan
    assert_output --partial '"status":"ok"'
}

@test "scan eicar file" {
    run curl -s -F "file=@files/eicar.zip" ${HOST}/scan
    assert_output --partial '"status":"failed"'
    assert_output --partial '"FOUND","Eicar-Signature"'
}

@test "scan clean and eicar file" {
    run curl -s -F "file=@files/eicar.zip" -F "file=@files/clean.zip" ${HOST}/scan
    assert_output --partial '"status":"failed"'
}