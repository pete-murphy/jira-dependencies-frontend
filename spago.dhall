{ name = "jira-dependencies"
, dependencies =
  [ "console"
  , "csv"
  , "effect"
  , "psci-support"
  , "react-basic-dom"
  , "react-basic-hooks"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
