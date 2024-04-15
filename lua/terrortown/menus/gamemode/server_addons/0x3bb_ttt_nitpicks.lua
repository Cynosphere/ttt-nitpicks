CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"
CLGAMEMODESUBMENU.title = "0x3bb_ttt_nitpicks_title"

function CLGAMEMODESUBMENU:Populate(parent)
  local form = vgui.CreateTTT2Form(parent, "0x3bb_ttt_nitpicks_title")

  -- sorry i read bottom to top, cope
  form:MakeCheckBox({
    label = "label_ttt_nitpicks_holstered_viewmodel",
    serverConvar = "ttt_nitpicks_holstered_viewmodel",
  })
  form:MakeHelp({
    label = "help_ttt_nitpicks_holstered_viewmodel",
  })

  form:MakeCheckBox({
    label = "label_ttt_nitpicks_magneto_binds",
    serverConvar = "ttt_nitpicks_magneto_binds",
  })
  form:MakeHelp({
    label = "help_ttt_nitpicks_magneto_binds",
  })

  form:MakeCheckBox({
    label = "label_ttt_nitpicks_no_see_credits",
    serverConvar = "ttt_nitpicks_no_see_credits",
  })
  form:MakeHelp({
    label = "help_ttt_nitpicks_no_see_credits",
  })
  form:MakeCheckBox({
    label = "label_ttt_nitpicks_printmessage_nonblocking",
    serverConvar = "ttt_nitpicks_printmessage_nonblocking",
  })
  form:MakeHelp({
    label = "help_ttt_nitpicks_printmessage_nonblocking",
  })
end
