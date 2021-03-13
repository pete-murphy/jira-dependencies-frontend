{ name = "jira-dependencies"
, dependencies =
  [ "aff-promise"
  , "console"
  , "csv"
  , "debug"
  , "dom-filereader"
  , "effect"
  , "generics-rep"
  , "psci-support"
  , "react-basic-dom"
  , "react-basic-hooks"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
