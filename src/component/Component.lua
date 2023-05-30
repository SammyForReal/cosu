--- Component class
-- @module cosu.component.Component

local cosu = require("cosu.base")

--- Creator
-- @section creator

---Creates a new Component.
--
--@param nX number The x position of the upper left corner.
--@param nY number The y position of the upper left corner.
--@param nW number The width of the component.
--@param nH number The height of the component.
--
--@return table Component A new Component class.
function cosu.new.Component(nX,nY, nW,nH)
    local Component
    cosu._IDs = cosu._IDs+1

    Component = {
        -- Internal variables.
        _CLASS = "cosu.component",
        _ID = cosu._IDs,
        _PARENT = "ROOT",
        _DEAF = false,
        _ENABLED = true,
        _VISIBLE = false,
        _BG = nil,
        _FG = nil,

        -- Location and Dimensions.
        pos = vector.new(nX, nY),
        size = vector.new(nW, nH),

        -- Internal variables.
        event = {},
        content = 0
    }

    --- Functions
    -- @section functions

    ---Sets the background of this component.
    -- In addition to the numbers of the colors API, {renderer.translucent}
    -- can be used too for making that layer translucent.
    -- If the default color should be used, nil can be used.
    --
    -- @param c number|string|nil The color, {renderer.translucent} for translucent or nil for default.
    Component.setBG = function(c)
        Component._BG = c
    end

    ---Sets the foreground of this component.
    -- In addition to the numbers of the colors API, {renderer.translucent}
    -- can be used too for making that layer translucent.
    -- If the default color should be used, nil can be used.
    --
    -- @param c number|string|nil The color, {renderer.translucent} for translucent or nil for default.
    Component.setFG = function(c)
        Component._FG = c
    end

    ---Sets the position of the Component.
    --
    -- @param nX number The new x position.
    -- @param nY number The new y position.
    Component.setPos = function(nX, nY)
        Component.pos = vector.new(nX,nY)
    end

    ---Sets the size of the Component.
    --
    -- @param nW number The new width.
    -- @param nH number The new height.
    Component.setSize = function(nW, nH)
        Component.size = vector.new(nW, nH)
    end

    ---Returns the content a Component has. May be overritten by classes that extend this one.
    --
    -- @return any content Whatever this component stores.
    Component.getContent = function()
        return Component.content
    end

    ---Passes an event to the Component, which may handle fourther actions.
    --
    -- @param ... any Arguments of the event, including the name. 
    Component.pass = function(...)
        if Component._DEAF then return end
        local arg = {...}
        
        if type(Component.event[arg[1]]) == "function" then
            Component.event[arg[1]](...)
        end
    end

    cosu.util.genSetFunctions(Component)
    return Component
end

return cosu.new.Component