# Lessons learned while developing blue-ray-godot-game (and maybe before and maybe some general wisdom)

## Structuring / Godot editor 
- Use text-format for files where possible (.tscn, .tres etc.)
- You can have recursive scene instances if you want / need
- Don't be afraid to create entities and variations of them if needed!
- Materials can inherit from parent!
- Use bitmap fonts - dynamic fonts doesn't work very well when exported
- Signals are useful mostly for re-usable components to signal state to other components in an object tree
- Have no idea when I should use groups
- The integrated tilemap editor is only for non-advanced editing
- For managing tilesets - consider using vnen tiled importer instead
- Use plugins if you need to generate texture atlases from spritesheets - but this is surprisingly painful in Godot unfortunately

## Particles
- Explosion adjusts the burst
- Use color ramps - it mostly looks better

## Physics
- NEVER scale colliders
- Hitbox sizing design is important - they should often be smaller than you think
- If in doubt - use a collision polygon
- Area2D are useful, but remember to add collider and check their monitoring / monitorable properties
- For players and entities that needs deterministic movement, use KinematicBody
- Stop applying gravity when player is on ground
- Collision circles can be used for simple cases - in many cases any difference wont be noticed
- Plan layers from the start - at least separate static environment, player, enemies and possible projectiles in different layers
	- Layer = where object exists - Layer Mask = what object collides with
- Remember that you can raycast manually if needed
	- Remember to include the correct classes when doing collisions
- Joints only work with rigid bodies + colliders

## Animation
- Be careful when animating positions - you might need to add an additional parent
- Tween nodes are currently quite useless
- You can have more than one Animation Player if you want to play 2 animations at once
- You can animate shader parameters easily!

## Programming
- There is no shame in small scripts
- Resolve all nodes and store them in variables with `onready var` or in `_ready` - don't litter your code with `get_node`!
- Start early with implementing a level reload mechanic to discover race conditions, missing persistence, leaks etc.
- You can check object leaks and inspect the scene with Debug > Remote
- Check if an object has a method with `has_method("name")`
- Objects can store arbitrary metadata
- Separate effects from entities when possible (make them their own entities)
	- Create (persistant) helper classes for easy instanciating re-usable effects
- Sometimes a simple accumulator / counter does the trick - no need for complex timer objects and signals in all cases
- Yield can be used in conjunction with signals if you want
- Beware of changing default parameters in code - they will be decoupled if used
- Use `export var` with range parameters for sensible sliders in the editor
- Avoid direct setting / getting of another object's variables - create functions for it
- Singletons and persistent objects are great - remember they are under /root and will not be reloaded
- If finding nodes, remember to say "owned = false" in the third parameter if their outside the current object tree
	- Instanced objects are not owned and cannot be found unless owned = false...
- You can refer directly to shader parameters by using the property notation "shader_param/xxx" on the material
- Shaders are easy and fun (and have live previews!)
- texscreen doesn't work for HTML5, be careful with fullscreen shaders
- `tool` keyword makes the script execute in editor mode
- If in doubt, and if documentation is lacking and Google is unfriendly - check the Godot source code directly yourself!
- Don't do premature optimalization
- Always prefer simple solutions even if they don't feel proper according to <insert programming pattern / ideology / paradigm>

## Art
- A tileset and a tilemap are not always the answer for game art
- Everyone can do art - it is mostly a matter of practice + time + interest
- There is no shame using pre-made assets!
	- If you have the rights to them
	- Remember to credit if applicable
	- Be sure that the style is consistent
- Art is easier with constraints (size, palette etc.)

## Music
- See Art
- Garage Band looks simple and toyish but is actually quite powerful