{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "b64"
  , "console"
  , "effect"
  , "milkis"
  , "psci-support"
  , "react-basic-dom"
  , "react-basic-hooks"
  , "simple-json"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
