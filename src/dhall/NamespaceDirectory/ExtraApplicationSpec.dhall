let std = ../prelude.dhall

let Limits = ../shared/Limits/package.dhall

in  { configs : std.Map.Type Text std.JSON.Type, limits : Limits.Type }
