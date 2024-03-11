description =
[[
An Incinerator to turn your useless items into Ash or Charcoal!

-V1.0.1-
Small code update for readability.

-V1.0-
Initial Release
]]

name 						= "Incinerator"
author 						= "I'm So HM02"
version 					= "1.0.1"
forumthread 				= ""
icon                        = "modicon.tex"
icon_atlas                  = "modicon.xml"
api_version                 = 10
all_clients_require_mod     = true
dst_compatible              = true
client_only_mod             = false

--Configs
local Options               = {{description = "Ash", data = 1}, {description = "Charcoal", data = 2}}

local Empty                 = {{description = "", data = 0}}

local function Title(title) --Allows use of an empty label as a header
return {name=title, options=Empty, default=0,}
end

local SEPARATOR             = Title("")
 
configuration_options =
{
    Title("Settings"),
    {
        name    = "ASHORCHARCOAL",
        label   = "Give Ash or Charcoal?",
        options = Options,
        default = 1,
    },
}