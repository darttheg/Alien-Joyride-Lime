--[[

Lime Free Camera
Toggle this camera to fly around in free camera mode!

]]

local FreeCamera = {}

local spd = 8.0
local spdSprintF = 3
FreeCamera.sensitivity = 0.25

local function range(x, a, b)
    if x < a then x = a end
    if x > b then x = b end
    return x
end

local function HandleInputKeyboard(dt)
    -- Use WASD to move camera, SHIFT to speed up, C to go down, SPACE to go up.
    -- Only register movement if RMB is down.
    -- Use MOUSE WHEEL to increase/decrease speed.
    if not FreeCamera.camera then return end

    if not Lime.Input.isMouseButtonDown(Lime.Enum.Mouse.Right) then
        Lime.Input.setMouseVisible(true)
        return
    end

    local fSpd = Lime.Input.isKeyDown(Lime.Enum.Key.LShift) and (spd * spdSprintF) or spd
    local dOut = Lime.Input.getMouseDelta()

    FreeCamera.camera.rotation.y = FreeCamera.camera.rotation.y + dOut.x * FreeCamera.sensitivity
    FreeCamera.camera.rotation.x = range(FreeCamera.camera.rotation.x + dOut.y * FreeCamera.sensitivity, -89.9, 89.9)

    local right = FreeCamera.camera:getLeft() * -1
    local forward = FreeCamera.camera:getForward()

    local outMove = Vec3.new(0)
    if Lime.Input.isKeyDown(Lime.Enum.Key.W) then outMove = outMove + forward end
    if Lime.Input.isKeyDown(Lime.Enum.Key.S) then outMove = outMove - forward end
    if Lime.Input.isKeyDown(Lime.Enum.Key.D) then outMove = outMove + right end
    if Lime.Input.isKeyDown(Lime.Enum.Key.A) then outMove = outMove - right end
    if Lime.Input.isKeyDown(Lime.Enum.Key.Space) then outMove.y = outMove.y + 1 end
    if Lime.Input.isKeyDown(Lime.Enum.Key.LControl) then outMove.y = outMove.y - 1 end

    if outMove:length() > 0 then
        outMove = outMove:normalize()
        FreeCamera.camera.position = FreeCamera.camera.position + outMove * fSpd * dt
    end

    Lime.Input.setMouseVisible(false)
    Lime.Input.setMousePosition(Lime.Window.getSize() / 2)
end

---@type Camera
FreeCamera.camera = nil
---@type Hook
local inputHook = nil
local wasSetActive = false

function FreeCamera.setActive(enable)
    if not FreeCamera.camera then return end
    if enable then FreeCamera.camera:setActive() end

    if not enable then
        if inputHook then
            inputHook = inputHook:unhook()
        end
    else
        if not inputHook then
            inputHook = Lime.onUpdate:hook(HandleInputKeyboard)
        end
    end

    wasSetActive = enable
end

local function CreateFreeCamera()
    FreeCamera.camera = Camera.new()
    FreeCamera.camera.viewPlanes = Vec2.new(0.1, 250)
    FreeCamera.camera.fieldOfView = 90

    if wasSetActive then
        FreeCamera.setActive(wasSetActive)
    end
    
    Lime.log("[FreeCamera] Created Free Camera", Lime.Enum.PrintColor.Blue)
end

function FreeCamera.destroy()
    FreeCamera.camera = FreeCamera.camera:destroy()
end

CreateFreeCamera()

return FreeCamera