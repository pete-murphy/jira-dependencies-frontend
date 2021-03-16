{ name = "jira-dependencies"
, dependencies =
  [ "aff-promise"
  , "console"
  , "csv"
  , "debug"
  , "dom-filereader"
  , "dotlang"
  , "effect"
  , "generics-rep"
  , "ordered-collections"
  , "psci-support"
  , "react-basic-dom"
  , "react-basic-hooks"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
