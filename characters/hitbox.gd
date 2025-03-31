extends Area2D

var character_owner;

func setup(character):
	character_owner = character

func take_damage(source, amount):
	character_owner.take_damage(source, amount)
