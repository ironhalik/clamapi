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

@test "same filename does not hide eicar" {
    run curl -s -F "file=@files/eicar.zip;filename=same.zip" -F "file=@files/clean.zip;filename=same.zip" ${HOST}/scan
    assert_output --partial '"status":"failed"'
    assert_output --partial '"FOUND","Eicar-Signature"'
}

@test "archive nested past clamd MaxRecursion is flagged" {
    cd "${BATS_TEST_TMPDIR}"
    echo hello > l0
    prev=l0
    for i in $(seq 1 20); do
        zip -q "l${i}.zip" "${prev}"
        prev="l${i}.zip"
    done
    run curl -s -F "file=@${prev}" ${HOST}/scan
    assert_output --partial '"status":"failed"'
    assert_output --partial 'Heuristics.Limits.Exceeded'
}

@test "upload over MAX_CONTENT_LENGTH is rejected" {
    dd if=/dev/zero of="${BATS_TEST_TMPDIR}/big.bin" bs=1048576 count=101 2>/dev/null
    run curl -s -o /dev/null -w '%{http_code}' -F "file=@${BATS_TEST_TMPDIR}/big.bin" ${HOST}/scan
    assert_output "413"
}
