-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local utils = require "Libs.utils"
local widget = require "widget"

--
-- Retrieve constant position values
local CX, CY, CW, CH = utils.ReturnPositionVariable()

--
-- Check for current platform
local platform = system.getInfo("platform")
local theme = widget.setTheme
if platform == "ios" then
    theme("widget_theme_ios")
elseif platform == "android" then
    theme("widget_theme_android")
end

--
-- Declare forward variables
local buttonsTable = {}
local buttonsLabel = {"media.PhotoLibrary", "media.SavedPhotosAlbum"}
local selectPhotoButton

--
-- Audio
local wooshSound = audio.loadSound("Audio/woosh.mp3")
local uploadedSound = audio.loadSound("Audio/uploaded.wav")

--
-- Font
local fontName = "Fonts/AtomicMd-3zXDZ.ttf"

--
-- Display background
local background = display.newImageRect("Images/background.png", CW, CH)
background.x, background.y = CX, CY

--
-- Display circle profile image
local profileImage = display.newCircle(CX, CY / 2, 100)

--
-- Functions
local function SetPhotoImage(event)
    local mediaType = event.target.label
    local mediaImage = "image.png"

    local function mediaListener(event)
        timer.performWithDelay(2000,
            function()
                local path = system.pathForFile(mediaImage, system.DocumentsDirectory)
                if path then
                    profileImage.fill = {type = "image", filename = path}
                    profileImage.fill:scale(0.5, 0.5)
                    audio.play(uploadedSound)
                end
            end
        )
    end

    if media.hasSource(mediaType) then
        media.selectPhoto{
            listener = mediaListener,
            mediaSource = mediaType,
            destination = {baseDir = system.DocumentsDirectory, filename = mediaImage}
        }
    else
        native.showAlert("Solar2D", "The current device has no support for media", {"OK"})
    end

    for i = 1, #buttonsTable do
        transition.to(buttonsTable[i], {alpha = 0, x = CW, time = 200 * i, transition = easing.inOutQuart,
            onComplete = function(t)
                t:removeSelf()
                t = nil
            end
        })
    end

    selectPhotoButton:setEnabled(true)
end

--
local function onReleaseListener(event)
    audio.play(wooshSound)
    event.target:setEnabled(false)

    for i = 1, 2 do
        local btn = widget.newButton{
            label = buttonsLabel[i]:sub(7, -1),
            labelColor = {default = {0, 0, 0}, over = {0, 0, 0, 0.3}},
            font = fontName,
            fontSize = 15,
            width = 150, height = 40,
            x = event.target.x, y = event.target.y + (50 * i),
            onRelease = SetPhotoImage
        }
        btn.alpha = 1
        transition.from(btn, {alpha = 0, x = CW, time = 200 * i, transition = easing.inOutQuart})
        buttonsTable[#buttonsTable+1] = btn
    end
end

--
-- Display main button for selecting photo
selectPhotoButton = widget.newButton{
    label = "Select Photo",
    labelColor = {default = {0, 0, 0}, over = {0, 0, 0, 0.3}},
    font = fontName,
    fontSize = 25,
    width = 200, height = 50,
    x = CX, y = CY,
    onRelease = onReleaseListener
}