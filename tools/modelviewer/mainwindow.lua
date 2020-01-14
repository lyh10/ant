local runtime = import_package "ant.imguibase".runtime
runtime.start {
	policy = {
		"ant.render|mesh",
		"ant.serialize|serialize",
		"ant.bullet|collider.capsule",
		"ant.render|render",
		"ant.render|name",
		"ant.render|shadow_cast",
		"ant.animation|animation",
		"ant.animation|state_machine",
		"ant.animation|skinning",
	},
	system = {
		"ant.modelviewer|model_review_system",
		"ant.modelviewer|memory_stat",
		"ant.camera_controller|camera_controller2"
	},
	pipeline = {
		{ name = "init",
			"init",
			"post_init",
		},
		{ name = "update",
			"timer",
			"data_changed",
			{name = "collider",
				"update_collider_transform",
				"update_collider",
			},
			"data_changed",
			{name = "collider",
				"update_collider_transform",
				"update_collider",
			},
			{ name = "animation",
				"animation_state",
				"sample_animation_pose",
				"skin_mesh",
			},
			{ name = "sky",
				"update_sun",
				"update_sky",
			},
			"widget",
			{ name = "render",
				"shadow_camera",
				"load_render_properties",
				"filter_primitive",
				"make_shadow",
				"debug_shadow",
				"cull",
				"render_commit",
				{ name = "postprocess",
					"bloom",
					"tonemapping",
					"combine_postprocess",
				}
			},
			"camera_control",
			"lock_target",
			"pickup",
			{ name = "ui",
				"ui_start",
				"ui_update",
				"ui_end",
			},
			"end_frame",
			"final",
		}
	}
}
