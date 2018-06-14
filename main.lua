math.randomseed(os.time())
local tiles = {
  empty = 0,
  wall = 1,
  floor = 2
}
local grid = {}
local placeSound = love.audio.newSource("place2.wav", "static")
placeSound:setVolume(.09)

function playSound()
  if placeSound:isPlaying() then
    placeSound:stop()
    placeSound:play()
  else
    placeSound:play()
  end
end

function setUpGrid(width, height)
  if width % 2 == 0 then width = width + 1 end
  if height % 2 == 0 then height = height + 1 end

  for y = 1, height do
    local temp = {}
    for x = 1, width do
      if y % 2 == 0 and x % 2 == 0 then
        temp[x] = tiles.empty
      else
        temp[x] = tiles.wall
      end
    end
    table.insert(grid, temp)
  end
end

local size = 8
function drawGrid()
  for y = 1, #grid do
    for x = 1, #grid[y] do
      if grid[y][x] == tiles.empty then
        love.graphics.setColor(0, 1, 1)
      elseif grid[y][x] == tiles.wall then
        love.graphics.setColor(.9, .9, .95)
      elseif grid[y][x] == tiles.floor then
        love.graphics.setColor(.64, .64, .64)
      end
      if grid[y][x] ~= tiles.floor then
        love.graphics.rectangle("fill", (x - 1) * size, (y - 1) * size,
          size, size)
      end
    end
  end
end

function validTile(x, y)
  return y>=1 and y<=#grid and x>=1 and x<=#grid[y]
end

function randShuffle(t)
  for i = #t, 1, -1 do
    local rand = math.random(#t)
    local temp = t[i]
    t[i] = t[rand]
    t[rand] = temp
  end
  return t 
end

local history = {}
function createPath(ci, ri)
  local curr = grid[ri][ci]
  local directions = {
    {0, -2}, {2, 0}, {0, 2}, {-2, 0}
  }
  randShuffle(directions)
  local dx, dy
  for i = 1, 4 do
    dx = ci + directions[i][1]
    dy = ri + directions[i][2]
    if validTile(dx, dy) then
      local tile = grid[dy][dx]
      if tile == tiles.empty then
        local ddx = ci + directions[i][1] / 2
        local ddy = ri + directions[i][2] / 2
        if validTile(ddx, ddy) then
          grid[dy][dx] = tiles.floor
          grid[ddx][ddy] = tiles.floor
          history[#history+1] = {ddy, ddx}
          history[#history+1] = {dy,  dx}
          createPath(dx, dy)
        end
      end
    end
  end
end

local maxTime = 0
local timer = maxTime
local historyPointer = 0
function updateTimer(dt)
  if historyPointer >= #history then return end
  timer = timer - dt
  if timer <= 0 then
    timer = maxTime
    historyPointer = historyPointer > #history and #history or historyPointer + 1
    playSound()
  end
end

function drawHistory()
  for i = 1, historyPointer do
    love.graphics.setColor(0, 0, .5)
    love.graphics.rectangle("fill", (history[i][1]-1) * size, (history[i][2]-1) * size,
      size, size)
  end
  if historyPointer > 0 then
    love.graphics.setColor(.75, .15, 0)
    love.graphics.rectangle("fill", (history[historyPointer][1]-1) * size,
      (history[historyPointer][2]-1) * size, size, size)
  end
end

function printGrid()
  for y = 1, #grid do
    local str = ""
    for x = 1, #grid[y] do
      str = str .. tostring(grid[y][x]) .. " "
    end
    print(str)
  end
end
   
function love.load()
  local n = 19 * 3 + 1
  love.graphics.setBackgroundColor(.9, .9, .95)
  love.window.setMode((n+1) * size, (n+1) * size)
  love.window.setTitle("Recursive Backtracker")
  setUpGrid(n, n)
  createPath(2, 2)
  --printGrid()
end

function love.update(dt)
  updateTimer(dt)
end

function love.draw()
  drawGrid()
  drawHistory()
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  if key == "r" then
    love.event.quit("restart")
  end
end
