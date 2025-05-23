---@class BufCloseConfig
local default_config = {
    ---@type boolean Always force close buffers
    always_force = false,
}

local M = {}

---@type BufCloseConfig
M.config = default_config

--- Returns a list of all open buffers, try to fetch them from a buffer line plugin if available, otherwise
--- just call vim.api.nvim_list_bufs()
function M.buf_list()
    -- bufferline
    local bufferline_ok, bufferline = pcall(require, "bufferline.state")
    if bufferline_ok then
        local buffers = {}

        for _, comp in ipairs(bufferline.visible_components or {}) do
            local id = comp["id"] or nil
            if id ~= nil then
                table.insert(buffers, id)
            end
        end

        return buffers
    end

    local cokeline_ok, cokeline = pcall(require, "cokeline.buffers")
    if cokeline_ok then
        local buffers = {}

        for _, buffer in ipairs(cokeline.get_valid_buffers() or {}) do
            local id = buffer["number"] or nil
            if id ~= nil then
                table.insert(buffers, id)
            end
        end

        return buffers
    end

    return vim.api.nvim_list_bufs()
end

--- Close current buffer
--- @param force boolean|nil
function M.buf_close_current(force)
    force = force or false
    if M.config.always_force then
        force = true
    end

    local current = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_delete(current, { force = force })
end

--- Close all buffers except for current
--- @param force boolean|nil
function M.buf_close_others(force)
    force = force or false
    if M.config.always_force then
        force = true
    end

    local current = vim.api.nvim_get_current_buf()

    for _, i in ipairs(M.buf_list()) do
        if i ~= current then
            vim.api.nvim_buf_delete(i, { force = force })
        end
    end
end

--- Close all buffers
--- @param force boolean|nil
function M.buf_close_all(force)
    force = force or false
    if M.config.always_force then
        force = true
    end

    for _, i in ipairs(M.buf_list()) do
        vim.api.nvim_buf_delete(i, { force = force })
    end
end

--- Close all buffers to the right
--- @param force boolean|nil
---@param args string[]
function M.buf_close_right(force, args)
    force = force or false
    if M.config.always_force then
        force = true
    end

    if #args > 1 then
        vim.notify("Error: Too many arguments passed to buf_close_right", vim.log.levels.ERROR)
        return
    end

    local max_count = tonumber(args[1])

    local current = vim.api.nvim_get_current_buf()
    local closing = false

    local count = 0

    for _, i in ipairs(M.buf_list()) do
        if closing and vim.api.nvim_buf_is_valid(i) then
            vim.api.nvim_buf_delete(i, { force = force })
            count = count + 1

            if max_count ~= nil and count >= max_count then
                closing = false
            end
        end

        if i == current then
            closing = true
        end
    end
end

--- Takes the last {num} elements from a list
---@param tbl table
---@param num integer
local function take_last(tbl, num)
    assert(type(tbl) == "table")
    assert(type(num) == "number")

    if num <= 0 then
        return {}
    end

    local len = #tbl
    if num >= len then
        return tbl
    end

    return vim.list_slice(tbl, len - num + 1)
end

--- Close all buffers to the left
---@param force boolean|nil
---@param args string[]
function M.buf_close_left(force, args)
    force = force or false
    if M.config.always_force then
        force = true
    end

    if #args > 1 then
        vim.notify("Error: Too many arguments passed to buf_close_left", vim.log.levels.ERROR)
        return
    end

    local max_count = tonumber(args[1])

    local current = vim.api.nvim_get_current_buf()

    local to_close = {}

    -- gather buffers to close
    for _, i in ipairs(M.buf_list()) do
        if i == current then
            break
        end

        if vim.api.nvim_buf_is_valid(i) then
            table.insert(to_close, i)
        end
    end

    if max_count ~= nil then
        to_close = take_last(to_close, max_count)
    end

    for _, i in ipairs(to_close) do
        vim.api.nvim_buf_delete(i, { force = force })
    end
end

--- Returns pairs of buffer id, buffer name for debugging
function M.buf_state()
    local state = {}

    for _, buf in ipairs(M.buf_list()) do
        table.insert(state, { buf, vim.api.nvim_buf_get_name(buf) })
    end

    return state
end

---@param opts? BufCloseConfig
function M.setup(opts)
    M.config = vim.tbl_extend("force", M.config, opts or {})
end

return M
