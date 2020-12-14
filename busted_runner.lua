rawset(_G, "lfs", false)

require "busted_resty"()

require "busted.runner"({ standalone = false })
