local util = {}; util.__index = {}

local renderpkg = import_package "ant.render"
local computil = renderpkg.components

local mathpkg = import_package "ant.math"
local mu = mathpkg.util

local fs = require "filesystem"

local function fill_procedural_sky_mesh(skyentity)
	local skycomp = skyentity.procedural_sky
	local w, h = skycomp.grid_width, skycomp.grid_height

	local vb = {"ff",}
	local ib = {}

	local w_count, h_count = w - 1, h - 1
	for j=0, h_count do
		for i=0, w_count do
			local x = i / w_count * 2.0 - 1.0
			local y = j / h_count * 2.0 - 1.0
			vb[#vb+1] = x
			vb[#vb+1] = y
		end 
	end

	for j=0, h_count - 1 do
		for i=0, w_count - 1 do
			local lineoffset = w * j
			local nextlineoffset = w*j + w

			ib[#ib+1] = i + lineoffset
			ib[#ib+1] = i + 1 + lineoffset
			ib[#ib+1] = i + nextlineoffset

			ib[#ib+1] = i + 1 + lineoffset
			ib[#ib+1] = i + 1 + nextlineoffset
			ib[#ib+1] = i + nextlineoffset
		end
	end

	local meshcomp = skyentity.mesh
	meshcomp.assetinfo = computil.create_simple_mesh("p2", vb, w * h, ib, #ib)
end

function util.create_procedural_sky(world, whichhour, whichmonth, whichlatitude, turbidity, follow_by_directional_light)
    local skyeid = world:create_entity {
		transform = mu.identity_transform(),
		mesh = {},
		material = computil.assign_material(
			fs.path "/pkg/ant.resources/depiction/materials/sky/procedural/procedural_sky.material",
			{
				uniforms = {
					u_sunDirection = {type="v4", name="sub direction", value = {0, 0, 1, 0}},
					u_sunLuminance = {type="v4", name="sky luminace in RGB color space", value={0, 0, 0, 0}},
					u_skyLuminanceXYZ = {type="v4", name="sky luminance in XYZ color space", value={0, 0, 0, 0}},
					u_parameters = {type="v4", name="parameter include: x=sun size, y=sun bloom, z=exposition, w=time", 
						value={}},
					u_perezCoeff = {type="v4", name="Perez coefficients", value = {}},
				}
			}),
		procedural_sky = {
			grid_width = 32, 
			grid_height = 32,
			follow_by_directional_light = follow_by_directional_light or true,
			which_hour 	= whichhour or 12,	-- high noon
			turbidity 	= turbidity or 2.15,
			month 		= whichmonth or "June",
			latitude 	= whichlatitude or math.rad(50),
		},
		main_view = true,
		can_render = true,
		name = "procedural sky",
	}

	fill_procedural_sky_mesh(world[skyeid])
end


return util