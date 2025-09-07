extends Node2D
@onready var bullet_node: Label = $CanvasLayer/bullet
@onready var Round_node: Label = $CanvasLayer/round
@onready var score_node: Label = $CanvasLayer/score
@onready var music: AudioStreamPlayer = $"Music"

var bullet_count = 12:
	set(value):
		if value > 0:
			bullet_count = value
			bullet_node.text = "BULLETS: " + str(value)
		else:
			bullet_count = 0
			bullet_node.text = "BULLETS: 0"
			_lose()


var Round = 1:
	set(value):
		#Round_node.text = "ROUND: "
		Round = value
		Round_node.text = "ROUND: " + str(value)

var score = 0:
	set(value):
		#score_node.text = "SCORE: "
		score = value
		score_node.text = "SCORE: " + str(value)

# We preload enemies to work with them better
@export var flying_mob_node: PackedScene
@export var ground_ninja_node: PackedScene = preload("res://Scenes/Ground_ninja.tscn")
@export var minion_demon_node: PackedScene = preload("res://Scenes/Minion_Demon.tscn")
@export var cyclops_demon_node: PackedScene = preload("res://Scenes/Cyclops_Demon.tscn")

var alive_enemies: int = 0
var next_round_enemy_count: int = 3
var spawn_positions := [Vector2(160,90), Vector2(200,100), Vector2(120,110), Vector2(180,120)]
var in_round_transitions := false

func _ready():
	_default_display()
	_spawn_enemy()
	#play music
	music.play()

func _default_display():
	bullet_node.text = "BULLETS: " + str(bullet_count)
	Round_node.text = "ROUND: " + str(Round)
	score_node.text = "SCORE: " + str(score)

func _spawn_enemy():
	in_round_transitions = false
	var mob_pool := [ground_ninja_node, minion_demon_node, cyclops_demon_node]
	
	for i in range(next_round_enemy_count):
	# We select 1 enemy of the pool at random
		var scene: PackedScene = mob_pool[randi() % mob_pool.size()]
		var enemy = scene.instantiate()
		enemy.position = spawn_positions[i % spawn_positions.size()]
		
	# Limits thge amount of bs in the game
		if enemy.has_signal("next_round"):
			if not enemy.next_round.is_connected(_on_enemy_dead):
				enemy.next_round.connect(_on_enemy_dead)
		
		add_child(enemy)
		alive_enemies += 1

func _on_enemy_dead():
	if in_round_transitions:
		return 
		
	alive_enemies -= 1
	score += 100
	
	if alive_enemies == 0:
		in_round_transitions = true 
		
		if Round == 1:
			next_round_enemy_count = 3
		else:
			next_round_enemy_count = min(10, next_round_enemy_count + 1)
		
		Round += 1
		bullet_count = 12
		await get_tree().create_timer(1).timeout
		_spawn_enemy()


func _input(event):
	if event.is_action_pressed("shoot"):
		bullet_count -= 1

func _lose():
	if $Timer.is_stopped():
		find_child("Laugh_mob").dog_laugh()
		for enemy in get_tree().get_current_scene().get_children():
			if "input_pickable" in enemy:
				enemy.input_pickable = false
		$Timer.start()

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")
