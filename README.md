# dotfiles

The name said it, this is my dotfiles

## Requirements

- Git
- GNU Stow

## Installation

Checkout this repo in `$HOME` directory

```sh
cd
git clone git@github.com:nogazaki/dotfiles.git
```

and then use GNU Stow to create symlinks

```sh
cd dotfiles
stow .
```
