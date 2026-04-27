extends Control

signal easy_selected
signal medium_selected
signal hard_selected
signal quit_pressed

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
	"Make sure you clean your room!",
	"Spacecraft Psyche is flying for almost 6 years across over 2 billion miles!",
	"Once it arrives, Spacecraft Psyche will orbit for at least two years while it does its job!",
	"Spacecraft Psyche uses ion propulsion, producing a faint blue glow and allowing it to fly further with less!",
	"With its solar panels extended, Psyche is about the size of a tennis court!",
	"Spacecraft Psyche rode on one of the most powerful rockets in use- a Falcon Heavy!",
	"Spacecraft Psyche was scheduled to fly by Mars in May of 2026- look it up!",
	"It only took 90 minutes after launch for Spacecraft Psyche to start communicating with Earth!",
	"Spacecraft Psyche is going to see if Asteroid Psyche had a magnetic field in the past!",
	"Asteroid Psyche is the biggest known metal asteroid in the entire Asteroid Belt!",
	"Asteroid Psyche is lighter than solid iron- so it might be porous or have rock mixed in there!",
	"If Asteroid Psyche isn't the old core scientists think it is, it might be a whole new type of object!",
	"While NASA's Jet Propulsion Laboratory is handling operations, the Psyche mission is actually led by Arizona State University",
	"Asteroid Psyche orbits the Sun about 3 times farther than Earth does!",
	"While we know a few things about Asteroid Psyche, the Spacecraft Psyche will take the first direct pictures of it!"
]

@onready var start_buttons = $StartButtons
@onready var difficulty_menu = $DifficultyMenu
@onready var tutorial_control = $TutorialControl
@onready var facts_label = $Facts
@onready var credits_control = $CreditsControl

func _ready():
	start_buttons.show()
	difficulty_menu.hide()
	tutorial_control.hide()

func _on_start_button_pressed():
	$StartButtons.hide()
	$DifficultyMenu.show()

func _on_fact_button_pressed():
	facts_label.text = facts[randi() % facts.size()]

func _on_tutorial_button_pressed():
	$StartButtons.hide()
	$Title.hide()
	$Facts.hide()
	$TutorialControl.show()

func _on_back_button_pressed():
	$TutorialControl.hide()
	$CreditsControl.hide()
	$Title.show()
	$StartButtons.show()
	$Facts.show()

func _on_credits_button_pressed():
	$StartButtons.hide()
	$Title.hide()
	$Facts.hide()
	$CreditsControl.show()

func _on_quit_pressed():
	quit_pressed.emit()



func _on_easy_button_pressed():
	easy_selected.emit()

func _on_medium_button_pressed():
	medium_selected.emit()

func _on_hard_button_pressed():
	hard_selected.emit()
