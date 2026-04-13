extends Control

@onready var score = $Score:
	set(value):
		score.text = "SCORE: " + str(value)

@onready var timer_label = $TimerLabel

var uilife_scene = preload("res://scenes/ui_life.tscn")

@onready var lives = $Lives

func init_lives(amount):
	for ul in lives.get_children():
		ul.queue_free()
	for i in amount:
		var ul = uilife_scene.instantiate()
		lives.add_child(ul)

func set_time(time_left):
	timer_label.text = "TIME: " + str(ceil(time_left))
