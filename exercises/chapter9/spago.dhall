{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "aff"
  , "affjax"
  , "arrays"
  , "bifunctors"
  , "console"
  , "effect"
  , "either"
  , "exceptions"
  , "foldable-traversable"
  , "functions"
  , "maybe"
  , "node-buffer"
  , "node-fs-aff"
  , "node-path"
  , "ordered-collections"
  , "parallel"
  , "prelude"
  , "psci-support"
  , "strings"
  , "test-unit"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
