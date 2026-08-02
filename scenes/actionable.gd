extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String


func action() -> void:
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
