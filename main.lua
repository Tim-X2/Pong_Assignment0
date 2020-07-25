-- This is my pong project with different classes and sounds from the lecture.

push = require 'push'

Class = require 'class'

require 'ball'

require 'paddle'

window_width = 1200
window_height = 750

virtual_width = 406
virtual_height = 255

paddle_speed = 180

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')

  love.window.setTitle('PONG')

  math.randomseed(os.time())

  smallFont = love.graphics.newFont('font.ttf', 8)
  scoreFont = love.graphics.newFont('font.ttf', 32)
  largeFont = love.graphics.newFont('font.ttf', 40)

  sounds = {
    ['Paddle_Hit'] = love.audio.newSource('Sounds/Paddle_Hit.wav', 'static'),
    ['Score'] = love.audio.newSource('Sounds/Score.wav', 'static'),
    ['Wall_Bounce'] = love.audio.newSource('Sounds/Wall_Bounce.wav', 'static')
  }

  love.graphics.setFont(smallFont)
  love.graphics.setFont(scoreFont)

  push:setupScreen(virtual_width, virtual_height, window_width, window_height, {
    fullscreen = false,
    resizable = true,
    vsync = true
  })

  player1Score = 0
  player2Score = 0

  servingPlayer = 1

  player1 = paddle(10, 30, 5, 20)
  player2 = paddle(virtual_width - 15, virtual_height - 50, 5, 20)

  ball = ball(virtual_width / 2 - 2, virtual_height / 2 - 2, 4, 4)

  gameState = 'start'
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt)
  if gameState == 'serve' then
      ball.dy = math.random(-50, 50)
    if servingPlayer == 1  then
      ball.dx = math.random(140, 200)
    else
      ball.dx = -math.random(140, 200)
    end
  elseif gameState == 'play' then
    if ball:collides(player1) then
        ball.dx = -ball.dx * 1.03
        ball.x = player1.x + 5

        if ball.dy < 0 then
          ball.dy = -math.random(10, 150)
        else
          ball.dy = math.random(10, 150)
        end

        sounds['Paddle_Hit']:play()
    end

    if ball:collides(player2) then
      ball.dx = -ball.dx * 1.03
      ball.x = player2.x - 4

      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end

      sounds['Paddle_Hit']:play()
    end

    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
      sounds['Wall_Bounce']:play()
    end

    if ball.y >= virtual_height - 4 then
      ball.y = virtual_height - 4
      ball.dy = -ball.dy
      sounds['Wall_Bounce']:play()
    end

  -- past the left hand side
  if ball.x < -4 then
    servingPlayer = 1
    player2Score = player2Score + 1
    if player2Score == 10 then
      winningPlayer = 2
      gameState = 'done'
    else
      gameState = 'serve'
      ball:reset()
      sounds['Score']:play()
    end
  end

  -- past the right hand side
  if ball.x > virtual_width then
    servingPlayer = 2
    player1Score = player1Score + 1
    if player1Score == 10 then
      winningPlayer = 1
      gameState = 'done'
    else
      gameState = 'serve'
      ball:reset()
      sounds['Score']:play()
    end
  end
end

  -- Player 1 is AI controlled.
  if player1:moveUp() then
    player1.dy = -paddle_speed + 60
  elseif player1:moveDown() then
    player1.dy = paddle_speed + 60
  else
    player1.dy = 0
  end

   -- player 2 movement
  if love.keyboard.isDown('up') then
    player2.dy = -paddle_speed
  elseif love.keyboard.isDown('down') then
    player2.dy = paddle_speed
  else
   player2.dy = 0
  end

  if gameState == 'play' then
    ball:update(dt)
  end

  player1:update(dt)
  player2:update(dt)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
      gameState = 'serve'
    elseif gameState == 'serve' then
      gameState = 'play'
    elseif gameState == 'done' then
      gameState = 'serve'
      ball:reset()

      player1Score = 0
      player2Score = 0

      if winningPlayer == 1 then
        servingPlayer = 2
      else
        servingPlayer = 1
      end
    end
  end
end

function love.draw()
  push:apply('start')
    love.graphics.clear(0.1569, 0.1765, 0.2039, 1)

    love.graphics.setFont(smallFont)
    displayScore()

    if gameState == 'start' then
      love.graphics.setFont(smallFont)
      love.graphics.printf('Press enter to start', 0, 10, virtual_width, 'center')
    elseif gameState == 'serve' then
      love.graphics.setFont(smallFont)
      love.graphics.printf('Player' .. tostring(servingPlayer) .. "'s serve!", 0, 10, virtual_width, 'center')
    elseif gameState == 'play' then

    elseif gameState == 'done' then
      love.graphics.setFont(largeFont)
      love.graphics.printf('Player' .. tostring(winningPlayer) .. 'wins!', 0, 10, virtual_width, 'center')
      love.graphics.setFont(smallFont)
      love.graphics.printf('Press enter to restart', 0, 70, virtual_width, 'center')
    end



    player1:render()
    player2:render()

    ball:render()

    displayFPS()
  push:apply('end')
end

function displayFPS()
  love.graphics.setFont(smallFont)
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(player1Score), virtual_width / 2 - 50, virtual_height / 3)
  love.graphics.print(tostring(player2Score), virtual_width / 2 + 30, virtual_height / 3)
end
