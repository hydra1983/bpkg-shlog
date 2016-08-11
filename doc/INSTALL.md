### Requirements

* bash >= 4 (This is a guess but seems likely)

### From source - system-wide

```
git clone https://github.com/hydra1983/shlog
cd shlog
make install
```

### From source - home directory

To install to your home directory, use the `PREFIX` make variable:

```
make install PREFIX=$HOME/.local
```

Make sure you have `PATH="$HOME/.local/bin:$PATH` in your shell
startup script.

### From source - project specific

`shlog` comes pre-built, so you can use it in your project, e.g. by
including the shlog repo as a git submodule:

```sh
cd ~/myproject
git submodule add https://github.com/hydra1983/shlog deps/shlog
```

In your script, add `~myproject/deps/shlog/dist` to your path and
`source "$(which shlog)"`.

### bpkg bash package manager

```
bpkg install 'hydra1983/shlog'
```
