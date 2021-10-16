let Limits = ../../src/dhall/shared/Limits/package.dhall

let limits
    : Limits.Type
    = { cpu = 100, memory = 1024, storage = 0, pods = 10 }

in  limits
