PWSH = pwsh

.PHONY: build
build: sample.cabal Main.hs rust/target/release
	cabal build

rust/target/release: rust/Cargo.toml rust/Cargo.lock rust/src/lib.rs
	$(PWSH) -Command "& { Push-Location rust; cargo build --release; Pop-Location }"

.PHONY: setup
setup:
	rustup default stable-x86_64-pc-windows-gnu

.PHONY: clean
clean:
	$(PWSH) -Command "& { Push-Location rust; cargo clean; Pop-Location }"
	cabal clean
