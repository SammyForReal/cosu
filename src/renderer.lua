--- The renderer engine.
-- @module cosu.renderer

local cosu = require("cosu.base")

local renderer = {
    _SCREEN = term.native(),
    _THEME = nil,

    tBlits = { [colors.white]='0', [colors.orange]='1', [colors.magenta]='2', [colors.lightBlue]='3', [colors.yellow]='4', [colors.lime]='5', [colors.pink]='6', [colors.gray]='7', [colors.lightGray]='8', [colors.cyan]='9', [colors.purple]='a', [colors.blue]='b', [colors.brown]='c', [colors.green]='d', [colors.red]='e', [colors.black]='f', },
    tOppositeColors = { [colors.white]=colors.black, [colors.orange]=colors.blue, [colors.magenta]=colors.green, [colors.lightBlue]=colors.red, [colors.yellow]=colors.gray, [colors.lime]=colors.pink, [colors.pink]=colors.lime, [colors.gray]=colors.yellow, [colors.lightGray]=colors.cyan, [colors.cyan]=colors.lightGray, [colors.purple]=colors.brown, [colors.blue]=colors.orange, [colors.brown]=colors.purple, [colors.green]=colors.magenta, [colors.red]=colors.lightBlue, [colors.black]=colors.white, },
    tFullColorArray = { colors.white, colors.orange, colors.magenta, colors.lightBlue, colors.yellow, colors.lime, colors.pink, colors.gray, colors.lightGray, colors.cyan, colors.purple, colors.blue, colors.brown, colors.green, colors.red, colors.black, },
    translucent = ' '
}

-- Convert palette to gray-scale if colors are not supported.
if not term.native().isColor() then
    local tBlits = renderer.tBlits
    local tNewBlits = { [colors.white]=tBlits[colors.white], [colors.orange]=tBlits[colors.white], [colors.magenta]=tBlits[colors.white], [colors.lightBlue]=tBlits[colors.white], [colors.yellow]=tBlits[colors.white], [colors.lime]=tBlits[colors.white], [colors.pink]=tBlits[colors.white], [colors.gray]=tBlits[colors.gray], [colors.lightGray]=tBlits[colors.lightGray], [colors.cyan]=tBlits[colors.lightGray], [colors.purple]=tBlits[colors.black], [colors.blue]=tBlits[colors.black], [colors.brown]=tBlits[colors.black], [colors.green]=tBlits[colors.black], [colors.red]=tBlits[colors.black], [colors.black]=tBlits[colors.black] }
    renderer.tBlits = tNewBlits
end

---A very primitive and lite version of the Term API.
---Can be used as a buffer. Useful for fast character-based buffers.
---
---@class CharacterBuffer
---
---@param nW number The width of the buffer.
---@param nH number The height of the buffer.
function renderer.CharacterBuffer(nW,nH)
    local buffer
    
    buffer = {
        -- The actual buffer.
        content = {
            ['b']={},
            ['f']={},
            ['t']={}
        },

        -- Some internal stuff we need to keep track of.
        size = vector.new(nW,nH),
        cursor = {
            pos = vector.new(1,1),
            bg = 'f',
            fg = '0',
        },

        ---Resizes the buffer. Will be completely cleared afterwards.
        ---
        ---@param nW number The new width of the buffer.
        ---@param nH number The new height of the buffer.
        ---
        resize = function(nW, nH)
            buffer.size.x = nW
            buffer.size.y = nH

            buffer.content = {
                ['b']={},
                ['f']={},
                ['t']={}
            }
            buffer.clear()
        end,

        ---Changes the cursor pos.
        ---
        ---@param nX number The new x position for the cursor.
        ---@param nY number The new y position for the cursor.
        setCursorPos = function(nX, nY)
            buffer.cursor.pos.x = nX
            buffer.cursor.pos.y = nY
        end,

        ---Changes the background color of the cursor.
        ---
        ---@param color number|string The new color (Either via color API or blit character).
        setBackgroundColor = function(color)
            buffer.cursor.bg = renderer.tBlits[color] or color
        end,

        ---Changes the foreground color of the cursor.
        ---
        ---@param color number|string The new color (Either via color API or blit character).
        setTextColor = function(color)
            buffer.cursor.fg = renderer.tBlits[color] or color
        end,

        ---Clears the whole buffer with the current fore- and background colors.
        clear = function()
            -- Setup one cleared line
            local sB=(buffer.cursor.bg):rep(buffer.size.x)
            local sF=(buffer.cursor.fg):rep(buffer.size.x)
            local sT=(' '):rep(buffer.size.x)
            -- Override all
            for i=1,buffer.size.y do
                buffer.content.b[i]=sB
                buffer.content.f[i]=sF
                buffer.content.t[i]=sT
            end
        end,

        ---Writes in the buffer using the current fore- and background colors.
        ---
        ---@param str string The text to write in the buffer.
        write = function(str)
            -- Cursor
            local nX, nY = buffer.cursor.pos.x, buffer.cursor.pos.y
            -- String setup
            str = tostring(str)
            local maxChars = buffer.size.x - nX + 1
            if #str > maxChars then
                str = str:sub(1, maxChars)
            end
            -- Bounds
            if nY < 1 or nY > buffer.size.y then
                return
            end
            if nX > buffer.size.x then
                return
            end
            if nX < 1 then
                str = str:sub(2 - nX)
                nX = 1
            end
            -- Apply
            local cBg,cFg
            -- Override Background?
            if buffer.cursor.bg ~= renderer.translucent then
                cBg = buffer.cursor.bg:rep(#str)
                buffer.content.b[nY] = buffer.content.b[nY]:sub(1, nX-1) .. cBg .. buffer.content.b[nY]:sub(nX+#str)
            end
            -- Override Foreground?
            if buffer.cursor.fg ~= renderer.translucent then
                cFg = buffer.cursor.fg:rep(#str)
                buffer.content.f[nY] = buffer.content.f[nY]:sub(1, nX-1) .. cFg .. buffer.content.f[nY]:sub(nX+#str)
            end
            -- Apply text / cursor
            buffer.cursor.pos.x = nX + #str
            buffer.content.t[nY] = buffer.content.t[nY]:sub(1, nX-1) .. str .. buffer.content.t[nY]:sub(nX+#str)
        end,

        ---Renders the buffer to any terminal or monitor (or anything else that is similar to the Term API).
        ---
        ---@param term table The terminal that should render the buffer.
        render=function(term)
            local nX,nY = term.getCursorPos()

            for i=1,#buffer.content.t do
                term.setCursorPos(nX,nY+i-1)
                term.blit(buffer.content.t[i],buffer.content.f[i],buffer.content.b[i])
            end
        end
    }

    buffer.clear()
    return buffer
end

---Changes the provider (Term API).
---The event "cosu.theme_changed" will be passed afterwards.
function renderer.changeScreen(term)
    renderer._SCREEN = term
    os.queueEvent("cosu.screen_changed", cosu._ID)
end

---Searches for the right graphic provider representing the given Component.
---
---@param Component table The component.
function renderer.peekaboo(Component)
    if renderer._THEME then
        local Graphic = renderer._THEME.component[Component._CLASS]
        -- Found graphic provider
        if Graphic then
            return Graphic
        -- Fallback to placeholder
        else
            Graphic = renderer._THEME.generic.placeholder
            if Graphic then
                return Graphic
            end
        end
    end

    -- No graphic provider was found.
    error("No theme applied or current theme is corrupt.")
end

---Applies a given theme.
---The event "cosu.theme_changed" will be passed afterwards if successfull. 
---
---@param newTheme table The theme.
---
---@return boolean result Whenever it was successfull or not.
function renderer.applyTheme(newTheme)
    if type(newTheme.name) == "string"
    and type(newTheme.bGraphicsMode) == "boolean"
    and type(newTheme.component) == "table"
    and type(newTheme.generic) == "table" then
        renderer._THEME = newTheme
        os.queueEvent("cosu.theme_changed", cosu._ID)
        return true
    end
    return false
end

---Returns whenever the current session supports graphics mode or not. (introduced by CraftOS-PC)
---
---@return boolean hasGraphicsMode
function renderer.hasGraphicsMode()
    return (cosu._CRAFT_OS_PC_SUPPORT and renderer._SCREEN.setGraphicsMode) and true or false
end

---Returns whenever the current session supports advanced mouse features. (introduced by CraftOS-PC)
---
---@return boolean hasAdvancedMouseSupport
function renderer.hasAdvancedMouseSupport()
    return (cosu._CRAFT_OS_PC_SUPPORT and renderer._SCREEN.showMouse and settings.get("cosu.custom_cursor")) and true or false
end

return renderer