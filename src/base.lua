--- Returns basic functions for cosu.
-- This module will be called on initial state of cosu (@see cosu).
-- It contains the basic structure of the actual module.
--
-- @module cosu.base

local cosu = {
    _VERSION = 1.0,

    craft_os_pc_support = ((_G._HOST or ""):find("CraftOS%-PC") and true or false),
    -- Stores specific default settings before possible changes.
    _ORIGINAL_SETTINGS = {
        mouse_move_throttle = settings.get("mouse_move_throttle"),
        cosu_cursor = settings.get("cosu.custom_cursor")
    },

    -- Contains functions that create new components.
    new = {},
    -- Utilities for all kinds of tasks.
    util = {},

    -- Internal counter for component of this "environment".
    _IDs = 0,
}

---Utilities
-- @section util

---Hashes a given string input to a representing number using the djb2 algorithm.
--
--@param sInput string The input to hash.
--
--@return number output The hashed result.
function cosu.util.hash(sInput)
    local hash = 5381
    
    for i = 1, #sInput do
        hash = bit32.bxor(bit32.lshift(hash, 5), hash) + string.byte(sInput, i)
    end

    return hash
end

---Returns the actual screen position of the given Component.
--
--@param Component table The component.
--
--@return number nX The screen x position of the component.
--@return number nY The screen y position of the component.
function cosu.util.getScreenPosition(Component)
    local nX, nY = Component.pos.x, Component.pos.y
    local parent = Component._PARENT

    while parent ~= "ROOT" do
        nX = nX+parent.pos.x
        nY = nY+parent.pos.y
        parent = parent._PARENT
    end

    return nX, nY
end


---Returns a exact copy of the given table and its sub-tables.
--
--@param obj table The table that should be cloned.
--@param knownTables? table Only needed internally. Contains the already cloned tables of the given table.
--
--@return any
function cosu.util.deepClone(obj, knownTables)
    if type(knownTables) ~= "table" then knownTables = {} end

    if type(obj) == "table" then
        if type(knownTables[tostring(obj)]) == "nil" then
            local clone = {}
            for k,v in pairs(obj) do
                clone[cosu.util.deepClone(k)] = cosu.util.deepClone(v)
            end
            knownTables[tostring(obj)] = clone
        end

        return knownTables[tostring(obj)]
    else
        return obj
end end

---Searches for a value in a table via binary search. Returns the index of the value or nil if not found.
--
--@param t table The table that will be searched for the value.
--@param value any The wanted value.
--@param getCondition? function If the elements inside the given table has some specific way to compare for, this function can be provided in addition.
--@param bSimilar? boolean Whenever it should take the next best value it can find or return nil. False by default.
--
--@return number|nil index The index of the value in the table or nil if not found.
function cosu.util.search(t, value, getCondition, bSimilar)
    -- Use default condition.
    if type(getCondition) ~= "function" then
        getCondition = function(v) return v end
    end

    local low,high = 1,#t

    -- The Algorithm.
    local mid
    while low <= high do
        mid = math.floor((low+high)/2)

        if getCondition(t[mid]) == value then
            -- Hit!
            return mid
        elseif getCondition(t[mid]) < value then
            low = mid+1
        else
            high = mid-1
    end end

    -- Nothing found.
    return bSimilar and mid or nil
end

---Converts functions that don't return anything in a given Class to return their own Class.
-- This way, the Classes methods can be mostly chained.
--
--@param Class table The Class with the methods to convert.
function cosu.util.genSetFunctions(Class)
    for name,func in pairs(Class) do
        if type(func) == "function" and type(name) == "string"
        and name:sub(1,3) == "set" then
            Class[name] = function(...)
                func(...)
                return Class
end end end end

return cosu
--[[
    Todo:

    * Move Component and Grid to own file

    * UI handler (component managing, creating, event passing)
    !!! Grid size changes with theme (theme decides how much space it needs)
    * Rendering engine (buffers; themes; animations)
    * logging system
]]