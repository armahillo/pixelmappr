# Pixelmappr

Currently built using ruby `3.0.6`.

## Setup

### `rmagick` requires `imagemagick`

You will need the `imagemagick` development library.

#### MacOS ARM

If you use homebrew, this can be installed with `brew install imagemagick`.

#### Linux

In the debian ecosystem, `sudo apt install imagemagick` will install the library.

## Usage

The simplest usage is:

```sh
ruby bin/pixelmapper.rb path/to/your/image.gif
```

This will create a companion file called: `export/image.html`

Alternately, you can pass it a target output:

```sh
ruby bin/pixelmapper.rb path/to/your/image.gif /home/bob/tmp/my_output.html
```

The default output is always HTML.

**IMPORTANT**

The expectation is that you're processing a single sprite (eg. 32x64, 256x256, etc). This is going to map pixel-for-pixel over the file. Check the dimensions (at 72dpi) before attempting, or it might time out.