
set -xe

# Just echo all the relevant env vars to help debug Github Actions.
echo "RUSTFMTCHECK: \"$RUSTFMTCHECK\""
echo "GROESTLCOINVERSION: \"$GROESTLCOINVERSION\""
echo "PATH: \"$PATH\""


# Pin dependencies for Rust v1.41
if [ -n $"$PIN_VERSIONS" ]; then
    cargo generate-lockfile --verbose

    cargo update --verbose --package "log" --precise "0.4.13"
    cargo update --verbose --package "cc" --precise "1.0.41"
    cargo update --verbose --package "cfg-if" --precise "0.1.9"
    cargo update --verbose --package "serde_json" --precise "1.0.39"
    cargo update --verbose --package "serde" --precise "1.0.98"
    cargo update --verbose --package "serde_derive" --precise "1.0.98"
    cargo update --verbose --package "byteorder" --precise "1.3.4"
fi

if [ -n "$RUSTFMTCHECK" ]; then
  rustup component add rustfmt
  cargo fmt --all -- --check
fi

# Integration test.
if [ -n "$GROESTLCOINVERSION" ]; then
    wget https://github.com/Groestlcoin/groestlcoin/releases/download/v$GROESTLCOINVERSION/groestlcoin-$GROESTLCOINVERSION-x86_64-linux-gnu.tar.gz
    tar -xzvf groestlcoin-$GROESTLCOINVERSION-x86_64-linux-gnu.tar.gz
    export PATH=$PATH:$(pwd)/groestlcoin-$GROESTLCOINVERSION/bin
    cd integration_test
    ./run.sh
    exit 0
else
  # Regular build/unit test.
  cargo build --verbose
  cargo test --verbose
  cargo build --verbose --examples
fi
