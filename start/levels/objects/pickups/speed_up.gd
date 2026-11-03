extends Pickup

func _collect(_fox: Player) -> void:
	_fox.speed_up(3, 8.0)
