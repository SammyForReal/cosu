local cosu = require("cosu.base")
if not cosu.renderer then cosu.renderer = require("cosu.renderer") end
if not cosu.theme then cosu.theme = require("cosu.theme") end

-- Header
local consult = cosu.theme.create("CONSULT",
--------------------------------------------------------
[[The official theme for the cosu framework!
Based on the appearence of the consult.madefor.cc editor.

By Sammy.K (aka. 1Turtle)
Available under the MIT Licence]])

-- Label
consult.component["cosu.label"] = function(CharacterBuffer, Component)
    local nX,nY = cosu.util.getScreenPosition(Component)

    CharacterBuffer.setBackgroundColor(Component._BG or cosu.renderer.translucent)
    CharacterBuffer.setTextColor(Component._FG or colors.white)

    for i,line in ipairs(Component.content) do
        CharacterBuffer.setCursorPos(nX,nY+i-1)
        CharacterBuffer.write(line)
    end
end

return consult