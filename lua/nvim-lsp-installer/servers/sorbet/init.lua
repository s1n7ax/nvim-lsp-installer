local server = require "nvim-lsp-installer.server"
local gem = require "nvim-lsp-installer.installers.gem"

local root_dir = server.get_server_root_path "sorbet"

return server.Server:new {
    name = "sorbet",
    root_dir = root_dir,
    installer = gem.packages { "sorbet" },
    default_options = {
        cmd = { gem.executable(root_dir, "srb"), "tc", "--lsp" },
        cmd_env = gem.env(root_dir),
    },
}
