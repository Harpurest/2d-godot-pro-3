extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Pit.connect("body_fell", $YSort/Player, "_on_Pit_body_fell")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
