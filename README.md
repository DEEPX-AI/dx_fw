<div align="center">

# DX-FW

**Firmware images for DEEPX NPUs.**

[![Release](https://img.shields.io/github/v/release/DEEPX-AI/dx_fw)](https://github.com/DEEPX-AI/dx_fw/releases)

</div>

DX-FW holds the firmware for DEEPX NPU devices. It is part of [DX-Runtime](https://github.com/DEEPX-AI/dx-runtime),
the target-side bundle of [DX-AllSuite](https://github.com/DEEPX-AI/dx-all-suite). The DX-Runtime installer
flashes the matching firmware for you; use this repository to update or pin the firmware by hand.

## What You Need

| | |
|---|---|
| **NPU** | DX-M1, DX-M1M or DX-H1 Quattro |
| **DX-RT** | Installed on the NPU machine, for `dxcli` |

## Quick Start

Run on the machine with the NPU, after DX-RT is installed. Example for a DX-M1 M.2 module:

```bash
dxcli -g m1/latest/mdot2/fw.bin      # check the firmware file version

sudo systemctl stop dxrt.service
dxcli -u m1/latest/mdot2/fw.bin      # update the firmware
sudo systemctl start dxrt.service
```

`dxcli` was called `dxrt-cli` in earlier DX-RT releases. Files for other devices → [Which File](#which-file)

## Which File

| Device | Firmware file |
|---|---|
| DX-M1 (M.2) | `m1/<version>/mdot2/fw.bin` |
| DX-M1M (M.2) | `m1m/<version>/mdot2/fw.bin` |
| DX-H1 Quattro | `m1/<version>/h1/fw.bin` |

`<version>` is a release such as `2.7.6`, or `latest`. `uart_boot/` holds UART boot images; use them only when
DEEPX support asks you to.

## Documentation & Support

- Changes in each version: [Release Notes](./RELEASE_NOTES.md)
- For technical questions, please ask in the DEEPX Developer Community: https://community.deepx.ai/c/support/5

## License

See [LICENSE](./LICENSE) for terms of use.

Copyright © DEEPX Co., Ltd.
