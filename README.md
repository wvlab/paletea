# Paletea
## Description
Paletea is a tool for managing themes for your linux environment, written in
elixir, with extensebility and customizibillity in mind.
## Dependencies
- imagemagick
## Building
### Arch
```sh
curl "https://raw.githubusercontent.com/wvlab/paletea/master/res/PKGBUILD" > PKGBUILD
makepkg -si
```
### Any linux distro
```sh
git clone https://github.com/wvlab/paletea.git
mix escript.build
mv paletea ${XDG_LOCAL_DATA:-$HOME/.local/share}/bin/paletea
```
> **Note**
> You'll need to add $XDG_LOCAL_DATA/bin to PATH env var
