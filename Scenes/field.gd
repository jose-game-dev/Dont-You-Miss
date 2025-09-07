extends Node2D
@onready var bullet_node: Label = $CanvasLayer/bullet
@onready var Round_node: Label = $CanvasLayer/round
@onready var score_node: Label = $CanvasLayer/score
@onready var music: AudioStreamPlayer = $"Music"

var bullet_count = 6:
	set(value):
		#bullet_node.text = "BULLETS: "
		if value >= 0:
			bullet_count = value
			bullet_node.text = "BULLETS: " + str(value)
		else:
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

@export var flying_mob_node: PackedScene

var alive_enemies: int = 0
var next_round_enemy_count: int = 3
var spawn_positions := [Vector2(160,90), Vector2(200,100), Vector2(120,110), Vector2(180,120)]

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
	alive_enemies = next_round_enemy_count
	for i in range(next_round_enemy_count):
		var enemy = flying_mob_node.instantiate()
		enemy.speed = 100
		enemy.position = spawn_positions[i % spawn_positions.size()]
		enemy.next_round.connect(_on_enemy_dead)
		get_tree().current_scene.add_child(enemy)

func _on_enemy_dead():
	alive_enemies -= 1
	score += 100
	if alive_enemies <= 0:
		if next_round_enemy_count == 3:
			next_round_enemy_count = 4
		else:
			next_round_enemy_count = 3
		
		Round += 1
		bullet_count = 6
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
	get_tree().reload_current_scene()
