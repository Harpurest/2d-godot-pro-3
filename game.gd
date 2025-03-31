extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_tree().get_nodes_in_group('player')[0]
	var monsters = get_tree().get_nodes_in_group('monster')
	for monster in monsters:
		monster.set_target(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
