local pathm = require "nvim-lsp-installer.path"
local log = require "nvim-lsp-installer.log"
local settings = require "nvim-lsp-installer.settings"

local uv = vim.loop
local M = {}

local function assert_ownership(path)
    if not pathm.is_subdirectory(settings.current.install_root_dir, path) then
        error(
            ("Refusing to operate on path (%s) outside of the servers root dir (%s)."):format(
                path,
                settings.current.install_root_dir
            )
        )
    end
end

function M.rmrf(path)
    log.debug("fs: rmrf", path)
    assert_ownership(path)
    if vim.fn.delete(path, "rf") ~= 0 then
        log.debug "fs: rmrf failed"
        error(("rmrf: Could not remove directory %q."):format(path))
    end
end

function M.rename(path, new_path)
    log.debug("fs: rename", path, new_path)
    assert_ownership(path)
    assert_ownership(new_path)
    uv.fs_rename(path, new_path)
end

function M.mkdirp(path)
    log.debug("fs: mkdirp", path)
    assert_ownership(path)
    if vim.fn.mkdir(path, "p") ~= 1 then
        log.debug "fs: mkdirp failed"
        error(("mkdirp: Could not create directory %q."):format(path))
    end
end

function M.dir_exists(path)
    local ok, stat = pcall(M.fstat, path)
    if not ok then
        return false
    end
    return stat.type == "directory"
end

function M.file_exists(path)
    local ok, stat = pcall(M.fstat, path)
    if not ok then
        return false
    end
    return stat.type == "file"
end

function M.fstat(path)
    local fd = assert(uv.fs_open(path, "r", 438))
    local fstat = assert(uv.fs_fstat(fd))
    assert(uv.fs_close(fd))
    return fstat
end

function M.readdir(path)
    local dir = assert(uv.fs_opendir(path, nil, 25))
    local all_entries = {}
    local exhausted = false

    repeat
        local entries = uv.fs_readdir(dir)
        if entries and #entries > 0 then
            for i = 1, #entries do
                all_entries[#all_entries + 1] = entries[i]
            end
        else
            exhausted = true
        end
    until exhausted

    assert(uv.fs_closedir(dir))

    return all_entries
end

return M
