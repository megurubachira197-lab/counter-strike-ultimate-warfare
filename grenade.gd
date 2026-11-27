extends RigidBody3D
class_name TacticalGrenade

signal detonated(kind: String, at: Vector3)

@export_enum("Frag","Smoke","Flash","Incendiary","Decoy") var kind := "Frag"
@export var fuse_seconds := 2.8
@export var effect_radius := 7.0
@export var damage := 90
var fuse := 0.0
var exploded := false

func _ready() -> void:
    fuse = fuse_seconds
    mass = 0.45
    linear_damp = 0.12
    angular_damp = 0.15
    contact_monitor = true
    max_contacts_reported = 4

func _physics_process(delta: float) -> void:
    if exploded:
        return
    fuse -= delta
    if fuse <= 0:
        detonate()

func detonate() -> void:
    if exploded:
        return
    exploded = true
    detonated.emit(kind,global_position)
    match kind:
        "Frag":
            _apply_frag()
        "Flash":
            _apply_flash()
        "Smoke":
            _spawn_effect(Color(0.48,0.5,0.52),effect_radius,7.0)
        "Incendiary":
            _apply_incendiary()
        "Decoy":
            _spawn_effect(Color(0.9,0.65,0.2),2.5,4.0)
    queue_free()

func _apply_frag() -> void:
    for node in get_tree().get_nodes_in_group("enemies"):
        if node is Node3D:
            var d := global_position.distance_to(node.global_position)
            if d < effect_radius and node.has_method("take_damage"):
                var amount := int(damage * (1.0-d/effect_radius))
                node.take_damage(amount,global_position)
    _spawn_effect(Color(1.0,0.48,0.12),effect_radius,0.35)

func _apply_flash() -> void:
    for node in get_tree().get_nodes_in_group("enemies"):
        if node is Node3D and global_position.distance_to(node.global_position) < effect_radius*1.8:
            if node.has_method("apply_flash"):
                node.apply_flash(2.0)
    _spawn_effect(Color(1,1,0.8),effect_radius*0.6,0.25)

func _apply_incendiary() -> void:
    for node in get_tree().get_nodes_in_group("enemies"):
        if node is Node3D and global_position.distance_to(node.global_position) < effect_radius:
            if node.has_method("take_damage"):
                node.take_damage(35,global_position)
    _spawn_effect(Color(1,0.25,0.04),effect_radius,4.0)

func _spawn_effect(tint: Color, radius: float, duration: float) -> void:
    var fx := OmniLight3D.new()
    fx.light_color = tint
    fx.light_energy = 3.0
    fx.omni_range = radius
    fx.position = global_position
    get_tree().current_scene.add_child(fx)
    var timer := get_tree().create_timer(duration)
    timer.timeout.connect(fx.queue_free)
