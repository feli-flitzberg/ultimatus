class_name Transition
extends ColorRect

## The target scene to transition to.
@export var _to: PackedScene
## Duration of the fade-out animation (in seconds).
@export var _fade_out_time: float = 2
## Delay before starting the fade-out animation (in seconds).
@export var _fade_out_delay: float = 0
## Duration of the fade-in animation (in seconds).
@export var _fade_in_time: float = 2
## Delay before starting the fade-in animation (in seconds).
@export var _fade_in_delay: float = 1
## Whether the transition starts automatically when ready.
@export var auto_transition: bool = true

## Initialize all properties based on provided parameters.
## [param to]: The target scene to transition to.
## [param fade_out_time]: Duration of the fade-out animation.
## [param fade_out_delay]: Delay before the fade-out starts.
## [param fade_in_time]: Duration of the fade-in animation.
## [param fade_in_delay]: Delay before the fade-in starts.
## [param material]: Optional material for the ColorRect.
func _init(
	to: PackedScene = null,
	fade_out_time: float = 2,
	fade_out_delay: float = 0,
	fade_in_time: float = 2,
	fade_in_delay: float = 1,
	material: Material = null

) -> void:

	self._to = to
	self._fade_out_time = fade_out_time
	self._fade_out_delay = fade_out_delay
	self._fade_in_time = fade_in_time
	self._fade_in_delay = fade_in_delay
	self.material = material

	# Defer adding this node to the root of the scene tree.
	var loop = Engine.get_main_loop()
	loop.root.add_child.call_deferred(self)

func _ready() -> void:
	# Ensure the target scene is valid before continuing.
	assert(is_instance_valid(_to), "No scene to transfer to")

	# Set the Transition node to cover the entire screen.
	top_level = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	custom_minimum_size = get_viewport_rect().size
	color = Color.TRANSPARENT  # Start with a transparent color.

	# Automatically trigger the transition if the setting is enabled.
	if auto_transition:
		transition()

## Start the fade-out, transfer data to the new scene, and then fade-in.
func transition():
	await transition_out()
	await data_transfer(_to)
	await transition_in()
	queue_free.call_deferred()  # Remove this node from the scene tree after completion.


## Create a fade-out animation to transition to black.
func transition_out():
	print("Transitioning Out")
	var t = create_tween()
	t.tween_property(self, "color", Color.BLACK, _fade_out_time).set_delay(_fade_out_delay).set_ease(Tween.EASE_IN)
	await t.finished  # Wait for the animation to finish.


## Create a fade-in animation to transition from black to transparent.
func transition_in():
	print("Transitioning In")
	var t = create_tween()
	t.tween_property(self, "color", Color.TRANSPARENT, _fade_in_time).set_delay(_fade_in_delay).set_ease(Tween.EASE_OUT)
	await t.finished  # Wait for the animation to finish.

## Transfers data between scenes during a scene change.
## This function is the basis of the transition system and can be used indepenetly.
## The above class mostly represents how I might use this function in a project.
## [param scene]: The PackedScene to change to.
## Functionally, it adds two new virtual methods:
## [code]_transfer_on_scene_change[/code]
## [codeblock]
## func _transfer_on_scene_change(data: Dictionary):
##      data["my.key.path"] = "some data"
## [/codeblock]
## [code]_recieve_on_scene_change[/code]
## [codeblock]
## func _recieve_on_scene_change(data: Dictionary):
##      my_value = data["my.key.path"]
## [/codeblock]
static func data_transfer(scene: PackedScene):
	# Prepare a dictionary to hold data for transfer between scenes.
	var data = {}
	var loop := Engine.get_main_loop()

	# Notify the current scene of the transition and pass the data.
	loop.current_scene.propagate_call("_transfer_on_scene_change", [data], true)

	# Change to the target scene and handle errors if the scene cannot be loaded.
	if loop.change_scene_to_packed(scene) != OK:
		return

	# Wait for the new scene to load completely.
	while loop.current_scene == null:
		await loop.process_frame

	# Notify the new scene that the transition has completed and pass the data.
	loop.current_scene.propagate_call("_recieve_on_scene_change", [data], true)

	# Ensure the new scene is ready before continuing.
	if not loop.current_scene.is_node_ready():
		await loop.current_scene.ready
