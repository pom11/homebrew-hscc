# homebrew-hscc

Homebrew tap for [HSCC — Hermes Spark Cluster Control](https://github.com/pom11/hscc).

```sh
brew tap pom11/hscc
brew install hscc
```

Then run the bootstrap once — it is what wires HSCC into Hermes
(`~/.hermes` plugins, skills, roles) and registers the daemon. `brew install`
itself touches nothing outside the brew prefix.

```sh
hscc bootstrap --yes
```

Full documentation, command reference and cluster setup live in the
[hscc repository](https://github.com/pom11/hscc).
