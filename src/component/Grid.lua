--- Stores other Component's *(childs)* and handles passing over events and such.
--
-- @module cosu.component.Grid

local cosu = require("cosu.base")

--- Creator
-- @section creator

---Creates a new Grid.
--
--@param nX number The x position of the upper left corner.
--@param nY number The y position of the upper left corner.
--@param nW number The width of the component.
--@param nH number The height of the component.
--
--@return table Grid A new Grid class.
function cosu.new.Grid(nX,nY, nW,nH)
    local Grid = cosu.new.Component(nX,nY, nW,nH)
    Grid._CLASS = "cosu.grid"

    -- Internal variables.
    Grid.content = {
        components = {},
        passable = {}
    }

    --- Functions
    -- @section functions

    ---Adds a Component to the Grid.
    --
    -- @param Component table The Component to add. Will remove it from any other Grid it got added to before.
    Grid.add = function(Component)
        -- Remove it from older Grid.
        if type(Component._PARENT) == "table" then
            Component._PARENT.remove(Component)
        end
        -- Mark it so everyone knows it is ours hehe.
        Component._PARENT = Grid
        -- Save it in our components list.
        table.insert(Grid.content.components, Component)
        table.sort(Grid.content.components, function(a,b)
            return (a._ID or 0) < (b._ID or 0)
        end)
    end

    ---Removes a Component from the Grid.
    --
    -- @param Component table The Component to remove.
    Grid.remove = function(Component)
        local index = cosu.util.search(Grid.content.components, Component._IDs, function(comp)
            return comp._ID
        end)
        if index then
            table.remove(Grid.content.components, index)
        end
        if type(Component._PARENT) == "table"
        and Component._PARENT._ID == Grid._ID then
            Component._PARENT = "ROOT"
        end
    end

    ---Returns the Component childs the Grid contains.
    --
    -- @return table childs List of all childs the Grid has. 
    Grid.getContent = function()
        return Grid.content.components
    end

    ---Subscribes an Component for an type of event this Grid may receive.
    -- Those may be passed to the Component, if the Grid does not already listen for them by itself.
    --
    -- @param Component table The Component to subscribe.
    -- @param sEvent string The event that the Component wants to receive.
    Grid.subscribe = function(Component, sEvent)
        -- Create category
        if type(Grid.content.passable[sEvent]) ~= "table" then
            Grid.content.passable[sEvent] = {}
        end
    
        -- Sort table so it can be used within binary_search
        table.insert(Grid.content.passable[sEvent], Component)
        table.sort(Grid.content.passable[sEvent], function(a,b)
            return (a._ID or 0) < (b._ID or 0)
        end)
    end

    ---Unsubscribes an Component for an type of event.
    --
    -- @param Component table The Component to subscribe.
    -- @param sEvent string The type of event the Component should be unsubscribed to.
    Grid.unsubscribe = function(Component, sEvent)
        if type(Grid.content.passable[sEvent]) ~= "table" then return end

        -- Find Component
        local index = cosu.util.search(Grid.content.passable[sEvent], Component._ID, function(comp)
            return comp._ID
        end)

        -- Remove Component
        if index then
            table.remove(Grid.content.passable[sEvent], index)
        end
    end

    ---Passes an event to the Grid's childs.
    -- The childs may handle further actions.
    -- If the Grid listens for the same event however, it wont pass it any further.
    --
    -- @param ... any Arguments of the event, including the name. 
    Grid.pass = function(...)
        if Grid._DEAF then return end
        local arg = {...}

        -- Does Grid catch the event?
        if type(Grid.event[arg[1]]) == "function" then
            Grid.event[arg[1]](...)
        -- Pass event to childs.
        elseif Grid.content.passable[arg[1]] then
            for _,Component in ipairs(Grid.content.passable[arg[1]]) do
                Component.pass(...)
            end
        end
    end

    cosu.util.genSetFunctions(Grid)
    return Grid
end

return cosu.new.Grid