let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.8-20200822/packages.dhall sha256:b4f151f1af4c5cb6bf5437489f4231fbdd92792deaf32971e6bcb0047b3dd1f8

in  upstream
  with csv =
      { dependencies =
          [ "arrays"
          , "parsing"
          , "ordered-collections"
          ]
      , repo =
          "https://github.com/nwolverson/purescript-csv.git"
      , version =
          "v3.0.0"
      }
  with dotlang =
      { dependencies =
          [ "colors"
          , "console"
          , "effect"
          , "generics-rep"
          , "prelude"
          , "psci-support"
          , "strings"
          , "test-unit"
          ]
      , repo = 
          "https://github.com/csicar/purescript-dotlang.git"
      , version =
          "v3.1.0"
      }