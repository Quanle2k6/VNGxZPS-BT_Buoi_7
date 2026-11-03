class_name Chest
extends Node3D

## A chest that opens with a key. Press `interact` next to it: with a key in the inventory.
@export var reward_coins := 5

@onready var _sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var _area: InteractiveArea3D = $InteractiveArea3D

func _ready() -> void:
	_sprite.play("close")
	_area.interacted.connect(_on_interacted)

func _on_interacted() -> void:
	var fox := _fox_in_reach()
	if fox == null:
		return
	if not Inventory.use_key():
		Conversation.play("chest_locked", fox)
		return
	_area.queue_free()
	_sprite.play("open")
	_sprite.animation_finished.connect(_on_opened.bind(fox), CONNECT_ONE_SHOT)

func _on_opened(_fox: Player) -> void:
	Inventory.add_coin(reward_coins)
	EventBus.item_collected.emit("coin", reward_coins)

func _fox_in_reach() -> Player:
	for body: Node3D in _area.get_overlapping_bodies():
		if body is Player:
			return body
	return null
