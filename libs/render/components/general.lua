local ecs = ...
ecs.component "position"{
    v = {type="vector"}
}

ecs.component "direction"{
    v = {type="vector"}
}

ecs.component "scale" {
    v = {type="vector"}
}

ecs.component "frustum" {
    near = 0.1,
    far = 10000,
    fov = 90,
    aspect = 4/3,
}

ecs.component "render" {
    material = {type="asset", "assets/assetfiles/material/default.material"},
    mesh = {type="asset", "assets/assetfiles/mesh/default.mesh"},
}



