module Main where

foreign import ccall "hello_rust" helloRust :: IO ()

main :: IO ()
main = do
  putStrLn "Hello from Haskell!"
  helloRust
