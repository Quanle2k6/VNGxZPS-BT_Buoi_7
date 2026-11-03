extends Node3D

## A ball fired from where it stands, `angle` degrees above the horizontal toward +X, at `speed` m/s;
## gravity pulls it down. Space (`jump`) fires it, again and again. Its physics is stepped by hand,
## `step_time` seconds at a time:
##   velocity.y -= gravity · dt        position += velocity · dt
## The smaller the step, the closer it follows the exact parabola y = y0 + vy·t − ½·g·t², which
## TrajectoryPreview draws.

@export var speed := 15.0
@export_range(0.0, 90.0) var angle := 45.0
@export var gravity := 24.0
## Seconds per step. Try 0.1, 0.02, 0.001 and compare with the drawn path.
@export_range(0.001, 0.5, 0.001) var step_time := 0.02
@export var _finish: Vector3 = Vector3(8.0, 1.0, 0.0)

## The smallest step it takes, whatever step_time says.
const MIN_STEP := 0.001

var velocity := Vector3.ZERO
var flying := false

var _start := Vector3.ZERO
## Frame time not stepped yet: a frame rarely holds a whole number of steps.
var _left_over := 0.0


func _ready() -> void:
	_start = position


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		launch()


## Back to the launch point, then off: velocity = (cos a, sin a, 0) · speed.
func launch() -> void:
	var aimed := aim_angle(_start, _finish, speed, gravity)
	if not is_nan(aimed):
		angle = aimed
	position = _start
	var a := deg_to_rad(angle)
	velocity = Vector3(cos(a), sin(a), 0.0) * speed
	flying = true
	_left_over = 0.0


func _physics_process(delta: float) -> void:
	if not flying:
		return
	_left_over += delta
	var dt := maxf(step_time, MIN_STEP)    # a step of 0 would never use up the frame
	while flying and _left_over >= dt:
		_left_over -= dt
		step(dt)

## The smaller angle (degrees above the horizontal, toward +X) that sends a ball fired at `speed`
## m/s from `from` through `to`, with `gravity` pulling it down. NAN when `to` is out of reach.
static func aim_angle(from: Vector3, to: Vector3, speed: float, gravity: float) -> float:
	var x := to.x - from.x
	var y := to.y - from.y
	if x <= 0.0:
		return NAN    # this ball only flies toward +X
	var v2 := speed * speed
	var root := v2 * v2 - gravity * (gravity * x * x + 2.0 * y * v2)
	if root < 0.0:
		return NAN    # too far or too high for this speed
	return rad_to_deg(atan((v2 - sqrt(root)) / (gravity * x)))

## One step of `dt` seconds. Once back down at the launch height it stops there.
func step(dt: float) -> void:
	#Not flying: do nothing
	#velocity.y loses gravity · dt; position moves by velocity · dt
	#Back down to the launch height (_start.y) or below: put it on that height, stop flying
	if not flying:
		return
	velocity.y -= gravity * dt
	position += velocity * dt
	if position.y <= _start.y:
		position.y = _start.y
		flying = false
	pass
