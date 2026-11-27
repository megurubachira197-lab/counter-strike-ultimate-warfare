extends Node
class_name QualityProfiles

enum Profile { LOW, MEDIUM, HIGH, ULTRA }

static func apply_profile(profile: int) -> void:
    var viewport := Engine.get_main_loop().root
    match profile:
        Profile.LOW:
            Engine.max_fps = 45
            viewport.scaling_3d_scale = 0.65
        Profile.MEDIUM:
            Engine.max_fps = 60
            viewport.scaling_3d_scale = 0.8
        Profile.HIGH:
            Engine.max_fps = 90
            viewport.scaling_3d_scale = 1.0
        Profile.ULTRA:
            Engine.max_fps = 144
            viewport.scaling_3d_scale = 1.0

static func recommended_profile() -> int:
    if OS.has_feature("mobile"):
        return Profile.MEDIUM
    return Profile.HIGH
