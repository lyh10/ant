local lm = require "luamake"

lm:copy "copy_task_lua" {
    inputs = {
        lm.AntDir .. "/3rd/ltask/service/root.lua",
        lm.AntDir .. "/3rd/ltask/service/service.lua",
        lm.AntDir .. "/3rd/ltask/service/timer.lua",
    },
    outputs = {
        lm.AntDir .. "/engine/firmware/root.lua",
        lm.AntDir .. "/engine/firmware/service.lua",
        lm.AntDir .. "/pkg/ant.ltask/service/timer.lua",
    }
}

lm:lua_source "ltask" {
    deps = "copy_task_lua",
    sources = {
        lm.AntDir .. "/3rd/ltask/src/*.c",
        "!" .. lm.AntDir .. "/3rd/ltask/src/main.c",
    },
    defines = {
        --"DEBUGLOG",
        "DEBUGTHREADNAME",
    },
    windows = {
        links = {
            "user32",
            "winmm",
        }
    },
    linux = {
        defines = {
            "_GNU_SOURCE",
        },
    },
    msvc = {
        flags = {
            "/experimental:c11atomics"
        },
    },
    gcc = {
        links = "pthread",
    },
}
