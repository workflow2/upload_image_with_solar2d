-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local util = require "Libs.util"
local widget = require "widget"

--
-- Check for current platform
local platform = system.getInfo("platform")
if platform == "ios" then
    widget.setTheme("widget_theme_ios")
elseif platform == "android" then
    widget.setTheme("widget_theme_android")
else
    widget.setTheme("widget_theme_android_holo_light")
end

-- Declare forward variables
local selectPhotoButton
local buttons = {}
local buttonsLabel = {"media.PhotoLibrary", "media.SavedPhotosAlbum"}

--
-- Audio
local wooshSound = audio.loadSound("Audio/woosh.mp3")
local uploadedSound = audio.loadSound("Audio/uploaded.wav")

--
-- Font
local fontName = "Fonts/AtomicMd-3zXDZ.ttf" or "Fonts/BigmomRegular-d9yqx.ttf"

--
-- Background
local background = display.newImageRect("Images/workflow.png", display.contentWidth * 1.5, display.contentHeight / 2)
background.x, background.y = display.contentCenterX, display.contentHeight * 0.8

--
-- Circle image
local profileImage = display.newCircle(display.contentCenterX, display.contentCenterY / 2, 100)

--
-- Listener for retrieve the photo
local function SetPhotoImage(event)
    local mediaType = event.target.label
    local mediaImage = "image.png"

    local function mediaListener(event)
        timer.performWithDelay(2000,
            function()
                local path = system.pathForFile(mediaImage, system.DocumentsDirectory)
                profileImage.fill = {type = "image", filename = path}
                profileImage.fill.yScale = 2
                audio.play(uploadedSound)
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

    for i = 1, #buttons do
        transition.to(buttons[i], {alpha = 0, x = display.contentWidth, time = 200 * i, transition = easing.inOutQuart,
            onComple = function(t)
                t:removeSelf()
                t = nil
            end
        })
    end

    selectPhotoButton:setEnabled(true)
end

--
-- Set Listener for Buttons
local function SelectPhotoButtonListener(event)
    audio.play(wooshSound)
    selectPhotoButton:setEnabled(false)

    for i = 1, 2 do
        local btn = widget.newButton{
            label = buttonsLabel[i]:sub(7, -1),
            labelColor = {default = {0, 0, 0}, over = {0, 0, 0, 0.3}},
            font = fontName,
            width = 150, height = 40,
            fontSize = 15,
            x = selectPhotoButton.x, y = selectPhotoButton.y + (50 * i),
            onRelease = SetPhotoImage
        }
        btn.alpha = 1
        transition.from(btn, {alpha = 0, x = display.contentWidth, time = 200 * i, transition = easing.inOutQuart})
        buttons[#buttons+1] = btn
    end
end

--
-- Select Photo with media.selectPhoto mode
selectPhotoButton = widget.newButton{
    label = "Select Photo",
    labelColor = {default = {0, 0, 0}, over = {0, 0, 0, 0.3}},
    font = fontName,
    fontSize = 25,
    width = 200, height = 50,
    x = display.contentCenterX, y = display.contentCenterY,
    onRelease = SelectPhotoButtonListener
}

Runtime:addEventListener("touch", util.DisplayCircles)