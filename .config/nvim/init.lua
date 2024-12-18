-- moonwalk and fennel
require("moonwalk").add_loader("fnl", function(src)
  return require("fennel").compileString(src)
end)

require("myconfig")

require("mylazy")
