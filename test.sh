#!/bin/sh -ex

main() {
    export RUST_BACKTRACE=1
    # Allow environment variables to pass through
    export MIRIFLAGS="-Zmiri-disable-isolation"
    export LANG=C.UTF8

    export LOOM_CHECKPOINT_FILE=target/loom_test.json
    export LOOM_CHECKPOINT_INTERVAL=1
    export LOOM_LOG=1
    export LOOM_LOCATION=1
    export LOOM_MAX_PREEMPTIONS=10

    args="--no-default-features"
    miri_args="$args --target-dir miri-target"

    feature="permutation_testing"
    cargo test --release $args --features $feature $@

    for feature in default; do
        cargo +nightly miri test $miri_args --features $feature $@
        cargo +nightly miri test --release $miri_args --features $feature $@
    done
}

if [ -z ${CLEARED+x} ]; then
    exec env -i CLEARED=1 TERM="$TERM" PATH="$PATH" $0 $@
else
    cd $(dirname $(realpath $0))
    main $@
fi
