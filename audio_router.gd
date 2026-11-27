extends Node
class_name AudioRouter

var surface_steps := {
    "concrete": preload("res://audio/placeholder_step.tres") if ResourceLoader.exists("res://audio/placeholder_step.tres") else null,
    "metal": null,
    "wood": null,
    "gravel": null
}

func surface_name_from_collider(collider: Object) -> String:
    if collider and collider.has_meta("surface_type"):
        return str(collider.get_meta("surface_type"))
    return "concrete"

func estimate_distance_mix(distance: float) -> float:
    # 1.0 close, fading smoothly toward a distant gunshot.
    return clampf(1.0 - distance / 140.0,0.08,1.0)

func estimate_occlusion_mix(is_occluded: bool) -> float:
    return 0.42 if is_occluded else 1.0
