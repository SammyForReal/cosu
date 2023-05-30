--- Used to create themes.
-- @module cosu.theme

local cosu = require("cosu.base")
if not cosu.renderer then cosu.renderer = require("cosu.renderer") end

local theme
theme = {
    ---Creates a new template theme.
    ---
    ---@class TUI-Theme
    ---
    ---@param sName string The name of the theme.
    ---@param sDescription? string The description of the theme.
    ---@param bGraphicsMode? boolean whenever this theme is meant for TUI or GUI mode.
    ---
    ---@return table theme The created theme tempalte.
    create = function(sName, sDescription, bGraphicsMode)
        local newTheme
        newTheme = {
            name = sName,
            description = sDescription or "No description.",
            bGraphicsMode = bGraphicsMode or false,

            component = {},
            generic = {
                placeholder = function(CharacterBuffer, Component)
                    local nX,nY = cosu.util.getScreenPosition(Component)
                    local sName = (Component._CLASS..'_'..Component._ID)

                    local c = cosu.util.search(
                        newTheme.palette.tFullColorArray,
                        cosu.util.hash(sName:reverse())%(colors.black),
                        nil,
                        true
                    )
                    c = newTheme.palette.tFullColorArray[c]

                    CharacterBuffer.setBackgroundColor(c)
                    CharacterBuffer.setTextColor( newTheme.palette.tOppositeColors[c] )

                    for y=nY,nY+Component.size.y-1 do
                        CharacterBuffer.setCursorPos(nX,y)
                        CharacterBuffer.write((' '):rep(Component.size.x))
                    end

                    CharacterBuffer.setCursorPos(nX,nY)
                    CharacterBuffer.write( sName:sub(1, Component.size.x) )
                end
            }
        }

        newTheme.palette = cosu.util.deepClone(cosu.renderer.tFullColorArray)

        return newTheme
    end
}

return theme