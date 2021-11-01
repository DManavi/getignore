
# GetIgnore

Download the most recent version of the `.gitignore` file for any project directly from Github.

## Installation

There are several methods for installing this utility.

### NPX

> To use this method, you need to have NodeJS installed.

The easiest way of using the command is to use `npx`. Run the command below in your terminal.

```sh
npx getignore-cmd --help
```

### NPM

> To use this method, you need to have NodeJS installed.

In this method, the package is installed as a global dependency using `npm`.

```sh
npm install -g getignore-cmd
getignore --help
```

### Shell

> This method only works on MacOS and Linux.
> Artifacts are limited to x64 and Arm64 CPUs only.
> curl or wget is required.

In this method, the package is installed directly to the user-specific bin folder location (which may be vary in different OS).

#### wget version

```sh
wget -q -O- https://raw.githubusercontent.com/GetIgnore/getignore/master/bin/install.sh | bash
```

#### curl version

```sh
curl -o- -L https://raw.githubusercontent.com/GetIgnore/getignore/master/bin/install.sh | bash
```
