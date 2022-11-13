extends KinematicBody2D

var direction = Vector2()

onready var remoteTransform2D = $RemoteTransform2D
onready	var	camerad2D = $Camera2D

func _ready():
	$DisplayUsername.text = Network.username
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	
	# Wait one frame before checking if we are the master of this node
	# Otherwise it won't be defined yet
	yield(get_tree(), "idle_frame")
	
	set_physics_process(is_network_master())
	
	_on_network_peer_connected("")

func _on_network_peer_connected(id):
	if is_network_master():
		remoteTransform2D.remote_path = "Camera2D"
		camerad2D.current = true
		rpc("share_name", $DisplayUsername.text)

remotesync func share_name(data):
	$DisplayUsername.text = data

remotesync func position(data):
	position = data

func _physics_process(delta):
	direction.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	direction.y = -Input.get_action_strength("ui_up") + Input.get_action_strength("ui_down")

	move_and_slide(direction * 500)
	rpc_unreliable("position", position)
