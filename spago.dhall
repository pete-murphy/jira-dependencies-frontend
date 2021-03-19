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
  , "node-process"
  , "ordered-collections"
  , "profunctor-lenses"
  , "psci-support"
  , "react-basic-dom"
  , "react-basic-hooks"
  , "record-extra"
  , "validation"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
