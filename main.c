// This is not necessary for the FFI from Haskell to Rust.

void hello_rust(void);

int main (void) {
  hello_rust();
  return 0;
}
