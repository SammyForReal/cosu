---
-- CosuLib is a lightweight and powerful 
-- collection of tools for creating interfaces.
-- It includes as basis an element called Component.
-- Other components can extended it for its needs.
-- cosu comes with some basic components like Grid, 
-- which serves as a container for other 
-- components, and more like Button and Label. Those  
-- can be rendered using the integrated rendering
-- engine and a theme.
--
-- Components can listen to various events, which can 
-- be passed explicitly or automatically handled by 
-- Grid.
--
-- The rendering engine is responsible for rendering a
-- Component and its childs in such a way it is done as 
-- efficient as possible, without multible unecessary loops, 
-- while also maintaining the freedom for each Component.
--
-- It will need a theme however, to do so properly, as a theme 
-- will control the actual appeal of any Component.
--
-- @see cosu.base
-- @see cosu.components
-- @see cosu.theme
-- @see cosu.renderer
--
-- @author Sammy L. Koch *(aka. 1Turtle)*
-- @license MIT
-- @copyright Sammy L. Koch 2023
--
-- @module cosu

local cosu = require("cosu.base")

-- Other parts
cosu.theme = require("cosu.theme")
cosu.renderer = require("cosu.renderer")

-- Components
for name,creator in pairs( require("cosu.components") ) do
    if not cosu.new[name] then
        cosu.new[name] = creator
    else error(("Conflic within Component: \'%s\'; Already exists!"):format(""..name))
end end

return cosu