extends Control

signal start_pressed
signal fact_pressed
signal tutorial_pressed
signal quit_pressed
signal back_pressed


func _on_start_button_pressed():
	start_pressed.emit()


func _on_fact_button_pressed():
	fact_pressed.emit()


func _on_tutorial_button_pressed() -> void:
	tutorial_pressed.emit()


func _on_quit_pressed():
	quit_pressed.emit()


func _on_back_button_pressed() -> void:
	back_pressed.emit()
