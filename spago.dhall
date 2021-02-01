{ name = "jira-dependencies"
, dependencies =
  [ "console"
  , "effect"
  , "psci-support"
  , "react-basic-dom"
  , "react-basic-hooks"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
