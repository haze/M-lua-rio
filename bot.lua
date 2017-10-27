-- Bot made for Hackathon
-- Memory map http://www.smwcentral.net/?p=map&type=ram

vars = {}
vars["time"] = 400 -- place holder xd
Game = {deathIndex = 0, dist = 0, frame = 0, instructions = {}}
frameSkipCount = 15
framesStuck = 0
flipTimer = 0
lastMarioX = 0
flipper = false

function Game:fit(dist, time, score)
  if score == nil then
    score = 0
  end
  --return ((dist * 1.3)
  gui.text(5, 187, "Dist: " .. dist)
  return (dist / 3) + (score / 2) + (time - 300) * 0.4
end

function Game:calcDist()
  return 4224 - (maxX * 127)
end



function cross(parentA, parentB)
  aFit = parentA.fit(parentA.dist, vars["time"], vars["score"])
  bFit = parentB.fit(parentB.dist, vars["time"], vars["score"])
  best = nil
  worst = nil
  if aFit > bFit then
    best = parentA
    worst = parentB
  else
    best = parentB
    worst = parentA
  end

  childA = Game:new_clean()

  for i = 0, parentA.deathIndex, 1 do
    childA.instructions[i] = best.instructions[i]
  end

  moves = {2, 3, 4, 5}
  for i = parentA.deathIndex, parentA.deathIndex + frameSkipCount, 1 do
    childA[i] = moves[math.random(3)]
  end

  for i = parentA.deathIndex + frameSkipCount, table.getn(parentB.instructions) * 0.3, 1 do
    childA.instructions[i] = worst.instructions[i]
  end

  childB = childA
  --for i = 0, #childB.instructions, 1 do
  --  if math.random(10) == 1 then
  --    childB.instructions[math.random(#childB.instructions)] = childB.instructions[math.random(#childB.instructions)]
  --  end
  --end
  
  return childA, childB
end

function Game:new_clean()
  -- for i=1, frames, 1 do
  --  self.instructions[i] = {}
  -- end
  return self
end

function Game:new()
  -- 300 seconds
  -- 0 left
  -- 1 up
  -- 2 right
  -- 3 down
  -- 4 c
  -- 5 x
  function randomArr()
    arr = {}
    arrx = {2, 3, 4, 5}
    hasMadeCount = -1
    for z=1,#arrx,1 do
      i = arrx[z]
      if not (i == 0) then
        if i == 4 or i == 5 then
          if math.random(10) == 5 then
            table.insert(arr, i)
            if hasMadeCount == -1 then
              hasMadeCount = 0
            end
          end
        else
          if hasMadeCount > 20 then
            hasMadeCount = -1
          elseif hasMadeCount ~= -1 then
            arr = tables.concat(arr, 4)
            hasMadeCount = hasMadeCount + 1
          else
            if math.random(2) == 1 then
              table.insert(arr, i)
            end
          end
        end
      end
    end
    return arr
  end

  frames = vars["time"] * 25
  for i=1, frames ,1 do
    self.instructions[i] = randomArr()
  end
  return self
end

generation = 0
aGame = Game:new()
bGame = Game:new()
ready = false

framesUpOne = 0
framesUpTwo = 0

parentALastFit = 0
parentBLastFit = 0
a = true
alreadySet = false
maxX = 0

framecount = 0
-- thanks diego pino
local function contains(table, val)
  if not (table == nil) then
     for i=1,#table do
        if table[i] == val then
           return true
        end
     end
     return false
  end
end


function doMovement()
  -- 0 left
  -- 1 up
  -- 2 right
  -- 3 down
  -- 4 c
  -- 5 x
  if a then
    action = aGame.instructions[framecount + 1]
    --print("[a#:" .. tostring(framecount) .. " ]")
    if(contains(action, 0)) then
      joypad.set(1, {left=1})
    elseif(contains(action, 1)) then
      joypad.set(1, {X=1})
    elseif(contains(action, 2)) then
      joypad.set(1, {right=1})
    elseif(contains(action, 3)) then
      joypad.set(1, {down=1})
    elseif(contains(action, 4)) then
      joypad.set(1, {B=1})
    elseif(contains(action, 5)) then
      joypad.set(1, {A=1})
    end
  else
    action = bGame.instructions[framecount + 1]
    --print("[b#:" .. tostring(framecount) .. " ]")
    if(contains(action, 0)) then
      joypad.set(1, {left=1})
    elseif(contains(action, 1)) then
      joypad.set(1, {X=1})
    elseif(contains(action, 2)) then
      joypad.set(1, {right=1})
    elseif(contains(action, 3)) then
      joypad.set(1, {down=1})
    elseif(contains(action, 4)) then
      joypad.set(1, {B=1})
    elseif(contains(action, 5)) then
      joypad.set(1, {A=1})
    end
  end
  framecount = framecount + 1
  --print(joypad.get(1))
end

-- emu.registerbefore(doMovement)

function draw()
  -- parents
  if a then
    gui.text(5, 197, "Parent A")
  else
    gui.text(5, 197, "Parent B")
  end
  -- gen
  gui.text(5, 204, "Generation: " .. tostring(generation))
  -- fit
  gui.text(5, 212, "Fitness: " .. math.max(0, Game:fit(Game:calcDist(), vars["time"], vars["score"])))


  --gui.text(5, 32, "A Last Fitness: " .. Game:fit(Game:calcDist(), vars["time"], vars["score"]))
  --gui.text(5, 40, "B Last Fitness: " .. Game:fit(Game:calcDist(), vars["time"], vars["score"]))


end

function loop()
  vars["mX"] = memory.readbytesigned(0x94)
  vars["mY"] = memory.readbytesigned(0x96)
  vars["sX"] = vars["mX"] - memory.readbytesigned(0x1A)
  vars["sY"] = vars["mY"] - memory.readbytesigned(0x1C)
  vars["score"] = (memory.readbytesigned(0xF34) * 10) or 0
  -- timers
  local hun = memory.readbytesigned(0xF31)
  local ten = memory.readbytesigned(0xF32)
  local one = memory.readbytesigned(0xF33)
  vars["time"] = (hun * 100) + (ten * 10) + one
  -- direction
  vars["dir"] = memory.readbytesigned(0x76)
  -- isDead
  vars["resettrigger"] = memory.readbytesigned(0xDD5)
  vars["reset"] = vars["resettrigger"] ~= 0

  if(vars["dir"] == 1) then
    if(vars["mX"] >= 0) then
      if(vars["mX"] == 0) then
        maxX = maxX + 1
      end
    elseif(vars["mX"] < 0) then
      if(vars["mX"] == -128) then
        maxX = maxX + 1
      end
    end
  else
    if(vars["mX"] < 0) then
      if(vars["mX"] == -128) then
        maxX = maxX - 1
      end
    elseif(vars["mX"] >= 0) then
      if(vars["mX"] == 0) then
        maxX = maxX - 1
      end
    end
  end
  --print(tostring(maxX) .. " | " .. tostring(vars["mX"]) .. " | " .. tostring(vars["dir"]))

  if vars["mX"] == lastMarioX then
    framesStuck = framesStuck + 1
  else
    framesStuck = 0
  end

  lastMarioX = vars["mX"]

  if(vars["reset"] and (not alreadySet)) then
    a = not a
    if a then
      aGame.deathIndex = framecount - frameSkipCount
    else
      bGame.deathIndex = framecount - frameSkipCount
    end
    if a then
      generation = generation + 1
      childA, childB = cross(aGame, bGame)
      aGame = childA
      bGame = childB
    end
    -- new generation !!
    alreadySet = true
    savestate.load(state)
    if a then
      aGame.dist = aGame.calcDist()
    else
      bGame.dist = bGame.calcDist()
    end
    maxX = 0
  elseif(alreadySet and vars["resettrigger"] == 0) then
    alreadySet = false
  end
  if framesStuck > 100 then
    joypad.set(1, {B=nil})

    -- print(framesStuck)

    if flipTimer < 45 then
      joypad.set(1, {right=1})
      joypad.set(1, {B=1})
      flipTimer = flipTimer + 1
    else
      joypad.set(1, {B=nil})
      flipTimer = 0
    end
  end
  draw()
end

emu.speedmode("turbo")

state = savestate.create(2)
savestate.save(state)

while(true) do
  if not (framesStuck > 100) and not (frameStuck == 154) and not (frameStuck == 191) then
    if contains(joypad.getdown(1),  A) and framesUpOne < 400 then
      joypad.set(1, {A=nil})
      framesUpOne = 0
    end
    joypad.set(1, {Y=1})
    if contains(joypad.getdown(1),  B) and framesUpTwo < 400 then
      joypad.set(1, {B=nil})
      framesUpTwo = 0
    end
    doMovement()
  end
  loop()
  emu.frameadvance()
end
