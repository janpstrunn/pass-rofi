<img src="https://git.disroot.org/janpstrunn/images/raw/branch/main/pass.png" align="right" height="100"/>
<br>

# pass-rofi: Because typing `pass` is just too much

`pass-rofi` is a `rofi` script, meant to be used alongside [pass](https://github.com/janpstrunn/pass) which tries to replace the [passwordstore](https://www.passwordstore.org/) keeping its core philosophies.

It's a tool that combines all the `pass`, `pass-otp` and `pass-tomb` functionalities within `rofi` to allow you to easily get the passwords you need faster than anyone else.

## Features

- Create, copy and delete passwords
- Create, copy, delete and edit OTP keys using nano
- Create, delete and edit recovery keys using nano
- Open and close a `tomb`
- Customize master password and PIN dialog tool

## Requirements

- [pass](https://github.com/janpstrunn/pass)
- [pass-otp](https://github.com/janpstrunn/pass-otp)
- [pass-tomb](https://github.com/janpstrunn/pass-tomb)
- `rofi`

## Installation

```
curl -sSL https://github.com/janpstrunn/pass-rofi/raw/main/install.sh | bash
```

## Usage

```
pass-rofi: A rofi extension for pass

Usage: $0 [options] <command> [arguments]

Options:
  -d             Enable custom dialog
  -e             Exhume buried key to unlock a tomb
  -k [-e -g]     Specify a Tomb Key if not present in .passrc
  -g             Create a tomb key using GPG ID
  -h             Display this help message and exit
  -v             Display the current version number

Commands:
  help                     Display this help message and exit
  version                  Display the current version number

Examples:
  pass-rofi -e -g -k tomb.key
                 # Use a GPG key that is buried to unlock a tomb
```

> [!IMPORTANT]
> First time running `pass-rofi`, requires to use setup your [pass](https://github.com/janpstrunn/pass) first.

## Notes

This script has been only tested in a Linux Machine.

## License

This repository is licensed under the MIT License, a very permissive license that allows you to use, modify, copy, distribute and more.
