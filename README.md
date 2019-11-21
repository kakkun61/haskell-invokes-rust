# The sample of the FFI from Haskell (GHC) to Rust

## Build

I tested on Windows, but you may run this on Linux etc.

On Windows, choose the GNU toolchain.

```
> rustup default stable-x86_64-pc-windows-gnu
```

Build the Rust library.

```
> cd rust
> cargo build --release
```

Build the Haskell executable and run it.

```
> cd ..
> cabal run haskell-invokes-rust
Hello from Haskell!
Hello from Rust!
```

## Explanation

Create the Rust library.

```
> cargo new sample
```

Edit _Cargo.toml_ and _src/lib.rs_ etc.

The one of the points is specifying `staticlib` as `lib.crate-type` to create a static library.

```toml
[lib]
name = "sample"
crate-type = ["staticlib"]
```

The second one is marking `#[no_mangle]` not to [mangling](https://en.wikipedia.org/wiki/Name_mangling) the name.

```rust
#[no_mangle]
pub extern fn hello_rust() {
    println!("Hello from Rust!");
}
```

Check what libraries are depended by the library which we want to create.

```
> cd rust
> mkdir target\release
> rustc --print=native-static-libs --crate-type=staticlib .\src\lib.rs -o .\target\release\sample.lib
note: Link against the following native artifacts when linking against this static library. The order and any duplication can be significant on some platforms.

note: native-static-libs: -ladvapi32 -lws2_32 -luserenv -lgcc_eh -lpthread
```

Create the Haskell executable.

```
> cabal init
```

Edit _sample.cabal_ and _Main.hs_ etc.

First, if you want to distribute this package, you should include the Rust sources in this Haskell package too.

```cabal
…
extra-source-files:  rust/Cargo.toml
                   , rust/src/**/*.rs
```

Second, specify extra libraries and the directory which contains the library we create with Rust. These extra libraries are ones which `rustc` prints in the previous step.

```cabal
executable haskell-invokes-rust
  …
  extra-libraries:     sample, advapi32, ws2_32, userenv, gcc_eh, pthread
  extra-lib-dirs:      rust/target/release
```

Third, import the foreign function with this syntax.

```haskell
foreign import ccall "hello_rust" helloRust :: IO ()
```

And then build them.

# Used versions

```
> rustc --version
rustc 1.39.0 (4560ea788 2019-11-04)
> cargo --version
cargo 1.39.0 (1c6ec66d5 2019-09-30)
> ghc --version
The Glorious Glasgow Haskell Compilation System, version 8.8.1
> cabal --version
cabal-install version 3.0.0.0
compiled using version 3.0.0.0 of the Cabal library
```

# Extra

The FFI from C to Rust is able with the Microsoft Visual C++ toolchain too.

```
> rustup default stable-x86_64-pc-windows-msvc
> cd rust
> rustc --print=native-static-libs --crate-type=staticlib .\src\lib.rs
note: Link against the following native artifacts when linking against this static library. The order and any duplication can be significant on some platforms.

note: native-static-libs: advapi32.lib ws2_32.lib userenv.lib msvcrt.lib
```

Invoke “x64 Native Tools Command Prompt for VC 2019” from the Start menu. Remove msvcrt.lib from the library list, because msvcrt.lib is conflicted with the default library libcmt.lib (see [LNK4098](https://docs.microsoft.com/en-us/cpp/error-messages/tool-errors/linker-tools-warning-lnk4098?view=vs-2019)).

```
> cl /EHsc main.c .\rust\target\release\sample.lib advapi32.lib ws2_32.lib userenv.lib
```

And run the executable.

```
> main.exe
Hello from Rust!
```

```
> cl /help
Microsoft(R) C/C++ Optimizing Compiler Version 19.23.28107 for x64
```
