local bc = require "buf-close"

---@class Command
---@field names string[]
---@field fn function(boolean|nil, string[])
---@field nargs string|nil
---@field desc string

---@type Command[]
local commands = {
    {
        names = { "BufClose", "Bc" },
        fn = bc.buf_close_current,
        desc = "Close current buffer",
    },
    {
        names = { "BufCloseOthers", "Bco" },
        fn = bc.buf_close_others,
        desc = "Close all buffers except for the current one",
    },
    {
        names = { "BufCloseAll", "Bca" },
        fn = bc.buf_close_all,
        desc = "Close all buffers",
    },
    {
        names = { "BufCloseLeft", "Bcl" },
        fn = bc.buf_close_left,
        nargs = "?",
        desc = "Close all buffers left of the current one",
    },
    {
        names = { "BufCloseRight", "Bcr" },
        fn = bc.buf_close_right,
        nargs = "?",
        desc = "Close all buffers right of the current one",
    },
}

-- register commands
for _, cmd in ipairs(commands) do
    for _, name in ipairs(cmd.names) do
        vim.api.nvim_create_user_command(name, function(opt)
            cmd.fn(opt.bang, vim.fn.split(opt.args))
        end, { bang = true, nargs = cmd.nargs, desc = cmd.desc })
    end
end
