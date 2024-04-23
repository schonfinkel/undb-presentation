# undb-presentation

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)
[![Build PDF](https://github.com/schonfinkel/undb-presentation/actions/workflows/build.yml/badge.svg)](https://github.com/schonfinkel/undb-presentation/actions/workflows/build.yml)

Being some beamer-based presentation done at a local event.

## Development

To dive into a local development shell you should run:

```shell
nix develop --impure
```

## Build

```shell
nix develop .#ci --impure -c make
```
or
```shell
nix build -L ".#document"  
```

## TODO

- [x] Setup Nix devenv
- [x] Make local nix builds work
- [x] Make CI builds work
