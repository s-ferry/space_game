extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var timer = $GameTimer
@onready var asteroid_spawn_timer = $AsteroidSpawnTimer
@onready var game_over_screen = $UI/GameOverScreen
@onready var victory_screen = $UI/VictoryScreen
@onready var spawn_points = $SpawnPoints
@onready var fact_label = $UI/StartMenu/Facts

var game_started := false
var difficulty := "easy"

var easy_spawn_rate := 10.0
var medium_spawn_rate := 8.0
var hard_spawn_rate := 6.0

var easy_survival_time := 60.0
var medium_survival_time := 90.0
var hard_survival_time := 120.0

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
	asteroid_spawn_timer.start()

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
	$UI/StartMenu.quit_pressed.connect(_on_start_menu_quit_pressed)
	$UI/StartMenu.easy_selected.connect(_on_easy_selected)
	$UI/StartMenu.medium_selected.connect(_on_medium_selected)
	$UI/StartMenu.hard_selected.connect(_on_hard_selected)
	
	timer.timeout.connect(_on_timer_timeout)
	asteroid_spawn_timer.timeout.connect(_on_asteroid_spawn_timer_timeout)
	
	$UI.visible = true
	$UI/StartMenu.visible = true
	$UI/StartMenu/DifficultyMenu.visible = false
	$UI/HUD.visible = false
	$UI/GameOverScreen.visible = false
	$UI/VictoryScreen.visible = false
	
	set_game_active(false)
	
	game_over_screen.visible = false
	score = 0
	lives = 3
	
	hud.set_time(timer.wait_time)
	
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _process(_delta):
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

func spawn_asteroid_offscreen():
	var viewport_size = get_viewport_rect().size
	var side = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match side:
		0: # top
			spawn_pos = Vector2(randf_range(0, viewport_size.x), -80)
		1: # right
			spawn_pos = Vector2(viewport_size.x + 80, randf_range(0, viewport_size.y))
		2: # bottom
			spawn_pos = Vector2(randf_range(0, viewport_size.x), viewport_size.y + 80)
		3: # left
			spawn_pos = Vector2(-80, randf_range(0, viewport_size.y))
	
	var a = asteroid_scene.instantiate()
	a.global_position = spawn_pos
	a.size = Asteroid.AsteroidSize.LARGE
	a.connect("exploded", _on_asteroid_exploded)
	
	var center = viewport_size / 2
	var direction = (center - spawn_pos).normalized()
	
	
	a.rotation = Vector2.UP.angle_to(direction)
	asteroids.add_child(a)

func _on_asteroid_spawn_timer_timeout():
	spawn_asteroid_offscreen()


func get_safe_spawn_point():
	var safe_points = []
	
	for spawn_point in spawn_points.get_children():
		var spawn_area = spawn_point.get_node_or_null("PlayerSpawnArea")
		if spawn_area != null and spawn_area.is_empty:
			safe_points.append(spawn_point)
	
	if safe_points.size() > 0:
		return safe_points[randi() % safe_points.size()]
	
	return null


func _on_player_died():
	$PlayerDieSound.play()
	lives -= 1
	if lives <= 0:
		timer.stop()
		asteroid_spawn_timer.stop()
		game_started = false
		set_game_active(false)
		$GameMusic.stop()
		$Lossmusic.play()
		await get_tree().create_timer(2).timeout
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		var spawn_point = null
		
		while spawn_point == null:
			spawn_point = get_safe_spawn_point()
			if spawn_point == null:
				await get_tree().create_timer(0.1).timeout
		
		player.respawn(spawn_point.global_position)


func _on_timer_timeout():
	game_started = false
	set_game_active(false)
	
	timer.stop()
	asteroid_spawn_timer.stop()
	$GameMusic.stop()
	$WinMusic.play()
	$UI/VictoryScreen.show()

func _on_easy_selected():
	difficulty = "easy"
	timer.wait_time = easy_survival_time
	asteroid_spawn_timer.wait_time = easy_spawn_rate
	start_game()

func _on_medium_selected():
	difficulty = "medium"
	timer.wait_time = medium_survival_time
	asteroid_spawn_timer.wait_time = medium_spawn_rate
	start_game()

func _on_hard_selected():
	difficulty = "hard"
	timer.wait_time = hard_survival_time
	asteroid_spawn_timer.wait_time = hard_spawn_rate
	start_game()

func start_game():
	$StartMenuMusic.stop()
	$GameMusic.play()
	
	$UI/StartMenu.hide()
	$UI/HUD.show()
	
	$Player.show()
	
	for asteroid in asteroids.get_children():
		asteroid.show()
		
	game_started = true
	set_game_active(true)
	
	timer.stop()
	asteroid_spawn_timer.stop()
	
	timer.start()
	asteroid_spawn_timer.start()
	
	game_started = true
	set_game_active(true)
	
	timer.start()
	asteroid_spawn_timer.start()
