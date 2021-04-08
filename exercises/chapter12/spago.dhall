{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "arrays"
  , "canvas"
  , "console"
  , "effect"
  , "foldable-traversable"
  , "integers"
  , "lists"
  , "math"
  , "maybe"
  , "partial"
  , "prelude"
  , "psci-support"
  , "random"
  , "refs"
  , "web-dom"
  , "web-events"
  , "web-html"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
