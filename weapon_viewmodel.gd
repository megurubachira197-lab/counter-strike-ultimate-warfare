extends Node3D
class_name WeaponViewModel

var weapon_data: Dictionary = {}
var kick := 0.0
var sway_time := 0.0

func build(data: Dictionary) -> void:
    weapon_data = data
    for child in get_children():
        child.queue_free()
    var category := str(data.get("category","Fusil de asalto"))
    var body_length := 0.52
    var body_width := 0.12
    if category == "Pistola":
        body_length = 0.30
        body_width = 0.105
    elif category == "Escopeta" or category == "Fusil de precisión":
        body_length = 0.72
        body_width = 0.14
    elif category == "Ametralladora ligera":
        body_length = 0.68
        body_width = 0.18
    elif category == "Cuerpo a cuerpo":
        body_length = 0.42
        body_width = 0.06

    _add_box(Vector3(0,0,-body_length*0.25),Vector3(body_width,0.13,body_length*0.65),Color(0.105,0.12,0.13))
    _add_box(Vector3(0,-0.10,0.015),Vector3(body_width*0.68,0.22,0.13),Color(0.20,0.18,0.15))
    _add_box(Vector3(0,0.09,-body_length*0.20),Vector3(body_width*0.55,0.045,body_length*0.52),Color(0.24,0.27,0.28))
    if category != "Cuerpo a cuerpo":
        _add_box(Vector3(0,0,-body_length*0.72),Vector3(0.055,0.055,body_length*0.55),Color(0.075,0.08,0.085))
        if category in ["Fusil de asalto","Subfusil","Ametralladora ligera"]:
            _add_box(Vector3(0,-0.14,-0.12),Vector3(0.075,0.20,0.10),Color(0.12,0.13,0.13))
    else:
        _add_box(Vector3(0,0,-body_length*0.55),Vector3(0.025,0.035,body_length*0.85),Color(0.62,0.66,0.68))
    _add_box(Vector3(0,0.13,-body_length*0.18),Vector3(0.045,0.045,0.12),Color(0.04,0.045,0.05))

func _add_box(pos: Vector3, size: Vector3, tint: Color) -> void:
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.metallic = 0.62
    mat.roughness = 0.38
    mesh.material_override = mat
    mesh.position = pos
    add_child(mesh)

func play_recoil(amount: float) -> void:
    kick = minf(kick + amount,0.12)

func _process(delta: float) -> void:
    sway_time += delta
    kick = move_toward(kick,0.0,delta*0.65)
    position = Vector3(0.28 + sin(sway_time*7.0)*0.006, -0.24 + absf(sin(sway_time*7.0))*0.008, -0.48 + kick)
    rotation.x = -kick*1.8
