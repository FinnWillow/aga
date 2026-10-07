/// the camera is persistent, so it exists before any room's instances run
/// their Create events (the player sets itself as the camera's target).
if (!instance_exists(obj_camera)) {
    instance_create_depth(0, 0, 0, obj_camera)
}
