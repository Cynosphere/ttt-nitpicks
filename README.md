# [TTT(2) Nitpicks](https://steamcommunity.com/sharedfiles/filedetails/?id=3214989196)

Various fixes for TTT(2) for things I personally find annoying. Everything is configurable via cvars.
In TTT2, there is a dedicated section for every cvar in the Server Addons section of the help menu.

# Fixes

## Holstered Viewmodel (`ttt_nitpicks_holstered_viewmodel`)

Changes the holstered viewmodel to normal hands for compatibility with viewmodel addons such as VManip.

## Magneto-Stick Binds [TTT2 Only] (`ttt_nitpicks_magneto_binds`)

Unflips Magneto-Stick binds to how they are in stock TTT.

## No See Credits [TTT2 Only] (`ttt_nitpicks_no_see_credits`)

Fix subjectively broken logic where all roles can see credits on a body in the death screen.

It might just completely remove the credits field from the death screen despite checking if your role can take the credits, but whatever, doesn't matter.

## PrintMessage Non-Blocking [TTT2 Only] (`ttt_nitpicks_printmessage_nonblocking`)

Fixes PrintMessage calls being set to blocking and filling up the popup queue.
Useful when using tools like Navmesh Optimizer.

# Planned

- Magneto-Stick c_model
