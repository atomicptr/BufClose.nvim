# BufClose.nvim

Handy commands for quickly closing several buffers

Inspired by Helix buffer commands

## Install

### Lazy

```lua
    { "atomicptr/BufClose.nvim", lazy = false },
```

## Commands

- **BufClose** or **Bc**: Close the current buffer
- **BufCloseAll** or **Bca**: Close all open buffers
- **BufCloseOther** or **Bco**: Close all open buffers except the current one
- **BufCloseRight** or **Bcr**: Close all (or the specified number of) open buffers to the right of the current one
- **BufCloseLeft** or **Bcl**: Close all (or the specified number of) open buffers to the left of the current one

## License

GPLv3
