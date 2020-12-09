local mRandom = math.random

local util = {}

function util.DisplayCircles(event)
    local phase = event.phase
    if phase == "began" or phase == "moved" then
        local circles = {}
        for i = 1, mRandom(5) do
            local randomNumber = mRandom(3, 8)
            local xValues = {event.x + randomNumber*randomNumber, event.x - randomNumber*randomNumber}
            local yValues = {event.y + randomNumber*randomNumber, event.y - randomNumber*randomNumber}
            local circle = circles[i]
            circle = display.newCircle(event.x, event.y, randomNumber)
            circle.strokeWidth = 1
            circle:setStrokeColor(0)
            circle:setFillColor(mRandom(), mRandom(), mRandom(), mRandom())
            transition.to(circle, {time = 100 * i, x = xValues[mRandom(2)], y = yValues[mRandom(2)], transition = easing.inOutQuart,
                onComplete = function(t)
                    transition.to(t, {alpha = 0, time = 200,
                        onComplete = function(t)
                            t:removeSelf()
                            t = nil
                        end
                    })
                end
            })
        end
    end
end

return util