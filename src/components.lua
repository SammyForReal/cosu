--- Loads all CosuLib components.
--
-- @module cosu.components

--- Components
-- @section components

--- cosu.component.Component
-- @see cosu.component.Component
local Component = require("cosu.component.Component")

--- cosu.component.Grid
-- @see cosu.component.Grid
local Grid = require("cosu.component.Grid")

--- cosu.component.Label
-- @see cosu.component.Label
local Label = require("cosu.component.Label")

---
-- @export
return {
    Component = Component,
    Grid = Grid,
    Label = Label
}