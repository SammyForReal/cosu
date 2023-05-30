--- The Label component.
-- @module cosu.component.Label

local cosu = require("cosu.base")
if not cosu.renderer then cosu.renderer = require("cosu.renderer") end
local wrap = require("cc.strings").wrap

---Creates a new Label that extends Component.
---
---@param nX number The x position of the upper left corner.
---@param nY number The y position of the upper left corner.
---@param sText string The text of the Label.
---
---@return table Label A new Label class.
function cosu.new.Label(nX,nY, sText, nW,nH)
    local label = cosu.new.Component(nX,nY, nW or 1, nH or 1)
    label._CLASS = "cosu.label"

    label.content = { "Label_"..label._ID }
    label.dynamic = not (nW and nH)

    ---Replaces the text of the Label.
    ---
    ---@param str string The new text for the Label.
    label.setText = function(str)
        -- Adjust size
        if label.dynamic then
            local nW,nH

            if type(label._PARENT) ~= "table" then
                nW,nH = cosu.renderer._SCREEN.getSize()
            else
                nW,nH = label._PARENT.size.x, label._PARENT.size.y
            end

            label.size.x = #str:sub(1, nW-label.pos.x)
        end

        -- Adjust text
        label.content = wrap(str, label.size.x)
        if label.dynamic then
            label.size.y = #label.content
        end
    end

    cosu.util.genSetFunctions(label)
    label.setText(sText)
    return label
end

return cosu.new.Label