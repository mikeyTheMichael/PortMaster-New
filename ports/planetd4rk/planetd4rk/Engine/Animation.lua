local Animation = {}

function Animation.initialize()
    Animation.all_anim_objects = {}
    Animation.num_anim_objects = 0
end

-- Call this when initializing the object
function Animation.addAnimator(obj)
    obj.Animator = {
        animations = {},
        animLengths = {},
        interFrameTimes = {},
        animEndedFcns = {},
        toLoops = {},
        state = 1,
        currFrameTime = 0,
        currFrame = 1
    }
    Animation.num_anim_objects = Animation.num_anim_objects + 1
    Animation.all_anim_objects[Animation.num_anim_objects] = obj
end

-- Pass in gameobject, animation as a table of sprite indices,
-- the time betwen each frame, and the state number associated with the animation
-- and whether or not the animation is intended to loop. If this is false, then you should
-- specify an animEndedFunction as well to switch the animation and do any other logic you need
-- animEndedFcn is a function that runs after the animation has ended (optional)
-- takes in obj as an input
function Animation.addAnimation(obj, animation, interFrameTime, state, toLoop, animEndedFcn)
    obj.Animator.animations[state] = animation
    obj.Animator.animLengths[state] = #animation
    obj.Animator.interFrameTimes[state] = interFrameTime
    obj.Animator.animEndedFcns[state] = animEndedFcn or function(obj) end
    obj.Animator.toLoops[state] = toLoop
end

-- Pass in the state to change to. Instantly changes the animation
function Animation.changeAnimation(obj, state)
    obj.Animator.state = state
    obj.Animator.currFrame = 1
    obj.Animator.currFrameTime = 0
    obj.spr = obj.Animator.animations[state][1]
end

function Animation.update(dt)
    for k = 1, Animation.num_anim_objects do
        local obj = Animation.all_anim_objects[k]
        if obj.active then
            local state = obj.Animator.state
            obj.Animator.currFrameTime = obj.Animator.currFrameTime + dt
            if obj.Animator.currFrameTime > obj.Animator.interFrameTimes[state] then
                obj.Animator.currFrameTime = 0
                -- advance the frame
                -- reset the frame if we've exceeded the animations length
                if obj.Animator.currFrame >= obj.Animator.animLengths[state] then
                    -- Animation has ended, call the anim function
                    obj.Animator.animEndedFcns[state](obj)
                    obj.Animator.currFrame = 1
                    if obj.Animator.toLoops[state] then
                        obj.spr = obj.Animator.animations[state][obj.Animator.currFrame]
                    end
                else
                    obj.Animator.currFrame = obj.Animator.currFrame + 1
                    obj.spr = obj.Animator.animations[state][obj.Animator.currFrame]
                end
            end
        end
    end
end

return Animation