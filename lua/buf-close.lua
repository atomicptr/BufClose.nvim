--- Close current buffer
--- @param force boolean|nil
local function buf_close_current(force)
    if force == nil then
        force = false
    end

    local current = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_delete(current, { force = force })
end

--- Close all buffers except for current
--- @param force boolean|nil
local function buf_close_others(force)
    if force == nil then
        force = false
    end

    local current = vim.api.nvim_get_current_buf()

    for _, i in ipairs(vim.api.nvim_list_bufs()) do
        if i ~= current then
            vim.api.nvim_buf_delete(i, { force = force })
        end
    end
end

--- Close all buffers
--- @param force boolean|nil
local function buf_close_all(force)
    if force == nil then
        force = false
    end

    for _, i in ipairs(vim.api.nvim_list_bufs()) do
        vim.api.nvim_buf_delete(i, { force = force })
    end
end

--- Close all buffers to the right
--- @param force boolean|nil
local function buf_close_right(force)
    if force == nil then
        force = false
    end

    local current = vim.api.nvim_get_current_buf()
    local closing = false

    for _, i in ipairs(vim.api.nvim_list_bufs()) do
        if closing and vim.api.nvim_buf_is_valid(i) then
            vim.api.nvim_buf_delete(i, { force = force })
        end

        if i == current then
            closing = true
        end
    end
end

--- Close all buffers to the left
--- @param force boolean|nil
local function buf_close_left(force)
    if force == nil then
        force = false
    end

    local current = vim.api.nvim_get_current_buf()
    local closing = true

    for _, i in ipairs(vim.api.nvim_list_bufs()) do
        if i == current then
            closing = false
        end

        if closing and vim.api.nvim_buf_is_valid(i) then
            vim.api.nvim_buf_delete(i, { force = force })
        end
    end
end

---@class Command
---@field names string[]
---@field fn function(boolean|nil)
---@field desc string

---@type Command[]
local commands = {
    { names = { "BufClose", "Bc" }, fn = buf_close_current, desc = "Close current buffer" },
    {
        names = { "BufCloseOthers", "Bco" },
        fn = buf_close_others,
        desc = "Close all buffers except for the current one",
    },
    { names = { "BufCloseAll", "Bca" }, fn = buf_close_all, desc = "Close all buffers" },
    { names = { "BufCloseLeft", "Bcl" }, fn = buf_close_left, desc = "Close all buffers left of the current one" },
    { names = { "BufCloseRight", "Bcr" }, fn = buf_close_right, desc = "Close all buffers right of the current one" },
}

return {
    setup = function(opts)
        -- register commands
        for _, cmd in ipairs(commands) do
            for _, name in ipairs(cmd.names) do
                vim.api.nvim_create_user_command(name, function(opt)
                    local force = opt.bang

                    if opts.always_force then
                        force = true
                    end

                    cmd.fn(force)
                end, { bang = true, desc = cmd.desc })
            end
        end
    end,
    opts = {
        always_force = false,
    },
}
