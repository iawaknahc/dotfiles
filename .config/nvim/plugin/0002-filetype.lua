-- If you run :checkhealth, we may still see a warning saying yaml.docker-compose is not a valid filetype.
-- For a filetype to be considered as valid, there have to be a `ftplugin/<filetype>.{vim,lua}`
-- But it is really a warning.
vim.filetype.add({
  extension = {
    mjml = "html",
  },
  filename = {
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["docker-compose.yml"] = "yaml.docker-compose",
  },
})
