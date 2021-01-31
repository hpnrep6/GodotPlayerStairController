extends KinematicBody

const AUTO_JUMP_VELOCITY: float = 5.0;


var speed: float = 13.0;
var acceleration: float = 10.0;
var gravity: float = 50.0;
var jump: float = 15.0;

var mouseSensitivity: float = 0.1;

var direction: Vector3 = Vector3();
var velocity: Vector3 = Vector3()
var fall: Vector3 = Vector3()

onready var head: Spatial = $Head
onready var rayMin: RayCast = $Rays/Min;
onready var rayMax: RayCast = $Rays/Max;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouseSensitivity));
		head.rotate_x(deg2rad(-event.relative.y * mouseSensitivity));
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90));

func _physics_process(delta: float):
	checkStep();
	movement(delta);

func checkStep():
	if(!is_on_floor()):
		return;
	if(rayMin.is_colliding() && !rayMax.is_colliding()):
		fall.y = AUTO_JUMP_VELOCITY;

func movement(delta: float):
	var hasMoved = false; # variable to check if the player should be moving or not, prevents sliding down slopes (and stairs)
	
	direction = Vector3()
	if(Input.is_key_pressed(KEY_W)):
		hasMoved = true;
		direction -= transform.basis.z;
	elif (Input.is_key_pressed(KEY_S)):
		hasMoved = true;
		direction += transform.basis.z;
	if (Input.is_key_pressed(KEY_A)):
		hasMoved = true;
		direction -= transform.basis.x;
	elif (Input.is_key_pressed(KEY_D)):
		hasMoved = true;
		direction += transform.basis.x;
		
	if(is_on_floor()):
		if(Input.is_key_pressed(KEY_SPACE)):
			fall.y = jump;
			hasMoved = true;
	else:
		hasMoved = true;
		fall.y -= gravity * delta;

	direction = direction.normalized();
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta);
	if(hasMoved):
		velocity = move_and_slide(velocity, Vector3.UP);
		move_and_slide(fall, Vector3.UP);
