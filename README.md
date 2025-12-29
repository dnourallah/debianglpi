<h1 align="center">Debian server for GLPI</h1>

## Getting Started

### Operating System Compatibility

| O/S            | Status |
|:---------------| :----: |
| Debian         |   ✅   |
| macOS      |   ❌   |
| Windows      |   ❌   |

### Prerequisites

- [Debian](https://www.debian.org) should be installed (v12 or more).
- `curl` or `wget` should be installed
- `sudo` should be installed
- `git` should be installed (recommended v2.4.11 or higher)

### Basic Installation

DebianGLPI is installed by running one of the following commands in your terminal. You can install this via the
command-line with either `curl`, `wget` or another similar tool.

| Method    | Command                                                                                                          |
| :-------- |:-----------------------------------------------------------------------------------------------------------------|
| **curl**  | `bash -c "$(curl -fsSL https://raw.githubusercontent.com/dnourallah/debianglpi/main/tools/install.sh)"`      |
| **wget**  | `bash -c "$(wget -q -O- https://raw.githubusercontent.com/dnourallah/debianglpi/main/tools/install.sh)"` |
| **fetch** | `bash -c "$(fetch -o - https://raw.githubusercontent.com/dnourallah/debianglpi/main/tools/install.sh)"`  |

#### Manual Inspection

It's a good idea to inspect the install script from projects you don't yet know. You can do that by
downloading the install script first, looking through it so everything looks normal, then running it:

```sh
wget https://raw.githubusercontent.com/dnourallah/debianglpi/main/tools/install.sh
bash install.sh
```

## License

DebianGLPI is released under the [MIT license](LICENSE).
