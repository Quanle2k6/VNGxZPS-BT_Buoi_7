extends Pickup

## One coin
func _collect(_fox: Player) -> void:
	Inventory.add_coin(1)
	EventBus.item_collected.emit("coin", 1)
