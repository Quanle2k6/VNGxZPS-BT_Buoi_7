extends Pickup

@export var powerup: PowerupDecoratorData

func _collect(fox: Player) -> void:
	if powerup == null:
		push_warning("%s has no power-up" % name)
		return
	if powerup.id == "shield":
		fox.is_protected = true
	fox.decorator_manager.apply(powerup)
