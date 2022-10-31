workspace "McEngine"
    available_apps = os.matchdirs("src/App/*")

    for i=1,#available_apps do
        config_name = path.getname(available_apps[i])
        printf("Config name: %s", config_name)
        configurations { config_name .. "-release" }
        configurations { config_name .. "-debug"   }
    end

    for i=1,#available_apps do
        config_name = path.getname(available_apps[i])
        filter { "configurations:" .. config_name .. "*" }
            defines { "APP_INCLUDE=\"" .. config_name .. ".h\"" }
            defines { "APP_CLASS=" .. config_name }
            filter "configurations:*"
    end

project "McEngine"
    kind "WindowedApp"
    language "C++"
    filter "*"

    -- Sources
    files { "src/**.cpp", "src/**.c" }

    -- Include dirs
    includedirs { "src/**", "libraries/*/include" }

    filter "*"
    filter "system:linux" 
        linkoptions  "-Wl,-rpath=." 

        -- Linking
        libdirs "libraries/*/lib/linux"
        links  { "discord-rpc ", "steam_api ", "curl ", "z", "X11", "Xi", "GL", "GLU", "GLEW", "freetype", "bass", "bass_fx", "OpenCL", "BulletSoftBody", "BulletDynamics", "BulletCollision", "LinearMath", "enet", "pthread", "jpeg" }

        -- Build dirs
        filter { "configurations:*release", "system:linux" }
            targetdir "Release/Linux"
            objdir    "Release/Linux"

        filter { "configurations:*debug", "system:linux" }
            targetdir "Debug/Linux"
            objdir    "Debug/Linux"
        
    filter "*"
    filter "system:windows" 
        -- Linking
        libdirs "libraries/*/lib/windows"
        links { "ogg ", "ADLMIDI ", "mad ", "modplug ", "smpeg ", "gme ", "vorbis ", "opus ", "vorbisfile ", "discord-rpc ", "steam_api ", "SDL2_mixer_ext.dll ", "SDL2 ", "d3dcompiler_47 ", "d3d11 ", "dxgi ", "openvr_api ", "libcurl ", "libxinput9_1_0 ", "libBulletSoftBody ", "libBulletDynamics ", "libBulletCollision ", "libLinearMath ", "freetype ", "opengl32 ", "OpenCL ", "vulkan-1 ", "glew32 ", "glu32 ", "gdi32 ", "bass ", "bass_fx ", "comctl32 ", "Dwmapi ", "Comdlg32 ", "psapi ", "enet ", "ws2_32 ", "winmm ", "pthread ", "libjpeg" }
        -- Build dirs
        filter { "configurations:*release", "system:windows" }
            targetdir "Release/Windows"
            objdir    "Release/Windows"

        filter { "configurations:*debug", "system:windows" }
            targetdir "Debug/Windows"
            objdir    "Debug/Windows"
        


        

