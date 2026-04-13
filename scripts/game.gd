extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var timer = $Timer
@onready var game_over_screen = $UI/GameOverScreen
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var player_spawn_area = $PlayerSpawnPos/PlayerSpawnArea
@onready var fact_label = $UI/StartMenu/Facts

var facts = [
	"Psyche is the first mission to explore an asteroid that contains more metal than rock or ice!",
	"Asteroid Psyche is located about three times farther from the Sun than Earth!",
	"There are more stars in the universe than grains of sand on Earth.",
	"A teaspoon of a neutron star would weigh billions of tons!",
	"Asteroid Psyche is potato-shaped! It's about 173 miles wide at its widest, and 144 miles at the narrowest.",
	"Asteroid Psyche's surface is about 64,000 square miles- more than that of Georgia (the country or the US state)!",
	"Scientists think asteroid Psyche may consist of metal form the core of a planetesimal- a building block of early planets!",
	"Asteroid Psyche's orbital year takes about five Earth years, but its 'day' takes only a bit over four hours!",
	"Asteroid Psyche was discovered by Italian astronomer Annibale de Gasparis on March 17, 1852!",
	"Asteroid Psyche is named for Psyche, the Greek goddess of the soul!",
	"Spacecraft Psyche should reach its destination in August of 2029!",
	"Spacecraft Psyche is testing a system that lets it communicate with Earth with lasers!",
	"You're Amazing!",
	"Stay in School!",
	"Try Minecraft!",
	"Study Hard!",
	"Make sure you eat your vegetables!",
	"Make sure you clean your room!"
]

var game_started := false

# start
func _on_start_menu_start_pressed():
	$StartMenuMusic.stop()
	$GameMusic.play()
	
	$UI/StartMenu.hide()
	$UI/HUD.show()
	$Player.show()
	$Asteroids/Asteroid.show()
	$Asteroids/Asteroid2.show()
	$Asteroids/Asteroid3.show()
	$Asteroids/Asteroid4.show()
	$Asteroids/Asteroid5.show()
	$Asteroids/Asteroid6.show()
	$Asteroids/Asteroid7.show()
	
	game_started = true
	set_game_active(true)
	timer.start()


func _on_start_menu_fact_pressed():
	print("Game recieved fact signal")
	fact_label.text = facts[randi() % facts.size()]


func _on_start_menu_tutorial_pressed():
	print("Game recieved tutorial signal")
	$UI/StartMenu/Title.hide()
	$UI/StartMenu/Facts.hide()
	$UI/StartMenu/StartButtons.hide()
	$UI/StartMenu/TutorialControl.show()



func _on_start_menu_quit_pressed():
	print("Game received quit signal")
	get_tree().quit()


func _on_back_pressed():
	print("Game received back signal")
	$UI/StartMenu/Title.show()
	$UI/StartMenu/Facts.show()
	$UI/StartMenu/StartButtons.show()
	$UI/StartMenu/TutorialControl.hide()


func set_game_active(active: bool):
	player.set_process(active)
	player.set_physics_process(active)
	
	for asteroid in asteroids.get_children():
		asteroid.set_physics_process(active)
# end


var asteroid_scene = preload("res://scenes/asteroid.tscn")


var score := 0:
	set(value):
		score = value
		hud.score = score


var lives: int:
	set(value):
		lives = value
		hud.init_lives(lives)


func _ready():
	$UI/StartMenu.start_pressed.connect(_on_start_menu_start_pressed)
	$UI/StartMenu.tutorial_pressed.connect(_on_start_menu_tutorial_pressed)
	$UI/StartMenu.fact_pressed.connect(_on_start_menu_fact_pressed)
	$UI/StartMenu.quit_pressed.connect(_on_start_menu_quit_pressed)

	timer.timeout.connect(_on_timer_timeout)

	$UI.visible = true
	$UI/StartMenu.visible = true
	$UI/HUD.visible = false
	$UI/GameOverScreen.visible = false

	set_game_active(false)

	game_over_screen.visible = false
	score = 0
	lives = 3

	hud.set_time(timer.wait_time)

	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)

	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _process(delta):
	if game_started:
		hud.set_time(timer.time_left)

	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)


func _on_asteroid_exploded(pos, size, points):
	$AsteroidHitSound.play()
	score += points
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass


func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)


func _on_player_died():
	$PlayerDieSound.play()
	lives -= 1
	player.global_position = player_spawn_pos.global_position
	if lives <= 0:
		timer.stop()
		game_started = false
		set_game_active(false)
		await get_tree().create_timer(2).timeout
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn(player_spawn_pos.global_position)


func _on_timer_timeout():
	game_started = false
	set_game_active(false)

	$UI/HUD.hide()
	$UI/GameOverScreen.show()
