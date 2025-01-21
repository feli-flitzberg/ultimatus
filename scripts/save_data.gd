@tool
class_name SaveData
extends Resource

## The path where the data will be saved.
@export_group("Data")
@export var path: String

## The data to be saved, stored as a dictionary.
@export var data: Dictionary[StringName, Variant]:
	set(v):
		data = v
		notify_property_list_changed()

## Indicates if the data is read-only. When true, certain properties are not editable in the editor.
@export_group("Debug")
@export var read_only: bool = true:
	set(v):
		read_only = v
		notify_property_list_changed()

## Button to manually trigger saving data.
@export_tool_button("Save") var _save = save_data

## Button to manually trigger loading data.
@export_tool_button("Load") var _load = load_data

## Save data to all nodes implementing a `_save` method.
func save_data():
	Engine.get_main_loop().root.propagate_call("_save", [data], true)

## Load data from all nodes implementing a `_load` method.
func load_data():
	Engine.get_main_loop().root.propagate_call("_load", [data], true)

## Save the data dictionary to a file.
func save_to_file():
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

## Load the data dictionary from a file.
func load_from_file():
	data = JSON.parse_string(FileAccess.get_file_as_string(path))

## Validate and update property usage based on the read-only state.
## This ensures that read-only properties are not editable in the editor.
func _validate_property(property: Dictionary) -> void:
	match property.name:
		"data", "path" when read_only: property.usage |= PROPERTY_USAGE_READ_ONLY
		"_save", "_load" when read_only: property.usage = PROPERTY_USAGE_NO_EDITOR
