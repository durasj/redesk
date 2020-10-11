# ReDesk - Reimagine your standing desk

Standing desk controller upgrade to make your dumb standing desk bright.
Works by replacing the handset (buttons) that it then simulates.
Still in early stages.

HW part uses ESP32 with [Mongoose OS](https://mongoose-os.com/). Both mobile and HW is written in JS-like languages ([Dart](https://dart.dev/) and [mJS](https://github.com/cesanta/mjs))!

## Building & Running SW App

Use Flutter tools to build and run the mobile app.

## Building & Running HW Controller

You need:

- [`mos` tool](https://mongoose-os.com/docs/mongoose-os/quickstart/setup.md#1-download-and-install-mos-tool)
- (optionally) [Docker](https://www.docker.com/products/docker-desktop) for local builds
- USB-to-Serial drivers

To run local build and flash: `../mos build --local && ../mos flash`.

To run the Mongoose OS GUI with Serial output: `../mos`.

## ESP32 setup

- Down pin = D12
- Up pin = D13
