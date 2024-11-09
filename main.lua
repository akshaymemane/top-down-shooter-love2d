function love.load()
    math.randomseed(os.time())

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')
    
    WINDOW_WIDTH = love.graphics.getWidth()
    WINDOW_HEIGHT = love.graphics.getHeight()

    menuFont = love.graphics.newFont(30)

    player = {}
    player.x = WINDOW_WIDTH / 2
    player.y = WINDOW_HEIGHT / 2
    player.speed = 200

    zombies = {}
    bullets = {}

    gameState = 1
    score = 0
    maxTime = 2
    timer = maxTime
    
end

function love.update(dt)
    if gameState == 2 then
        -- move Right
        if love.keyboard.isDown('d') and player.x < WINDOW_WIDTH then
            player.x = player.x + player.speed * dt
        end
        -- move Left
        if love.keyboard.isDown('a') and player.x > 0 then
            player.x = player.x - player.speed * dt
        end

        -- move Up
        if love.keyboard.isDown('w') and player.y > 0 then
            player.y = player.y - player.speed * dt
        end
        -- move Down
        if love.keyboard.isDown('s') and player.y < WINDOW_HEIGHT then
            player.y = player.y + player.speed * dt
        end
    end

    -- IMPORTANT: make enemies follow the player and detect collision
    for i,z in ipairs(zombies) do
        z.x = z.x + (math.cos(ZombiePlayerAngle(z)) * (z.speed * dt))
        z.y = z.y + (math.sin(ZombiePlayerAngle(z)) * (z.speed * dt))

        if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
            for i,z in ipairs(zombies) do
                zombies[i] = nil
                gameState = 1
                player.x = WINDOW_WIDTH/2
                player.y = WINDOW_HEIGHT/2
            end
        end
    end

    for i,b in ipairs(bullets) do
        b.x = b.x + (math.cos(b.direction) * (b.speed * dt))
        b.y = b.y + (math.sin(b.direction) * (b.speed * dt))
    end

    for i=#bullets, 1, -1 do
        if bullets[i].x < 0 or bullets[i].x > WINDOW_WIDTH or bullets[i].y < 0 or bullets[i].y > WINDOW_HEIGHT then
            table.remove(bullets, i)
        end
    end

    -- mark zombies dead and bullets dead if they are hit
    for i,z in ipairs(zombies) do
        for j,b in ipairs(bullets) do
            if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
                z.dead = true
                b.dead = true
                score = score + 1
            end
        end
    end

    for i=#zombies, 1, -1 do
        if zombies[i].dead then
            table.remove(zombies, i)
        end
    end

    for i=#bullets, 1, -1 do
        if bullets[i].dead then
            table.remove(bullets, i)
        end
    end

    if gameState == 2 then
        timer = timer - dt

        if timer < 0 then
            spawnZombie()
            maxTime = 0.95 * maxTime    -- increase enemy spawnTime
            timer = maxTime
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)

    if gameState == 1 then
        love.graphics.setFont(menuFont)
        love.graphics.printf('Click anywhere to begin!', 0, 50, WINDOW_WIDTH, 'center')
    end

    love.graphics.printf('Score: ' .. score, 0, WINDOW_HEIGHT - 100, WINDOW_WIDTH, 'center')
    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

    for i, z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x, z.y, ZombiePlayerAngle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
    end

    for i,b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, nil, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    end

end

function love.keypressed(key)
    if key == 'space' then
        spawnZombie()
    elseif key == 'escape' then
        love.quit()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and gameState == 2 then
        spawnBullet()
    elseif button == 1 and gameState == 1 then
        gameState = 2
        maxTime = 2
        timer = maxTime
        score = 0
    end
end

function playerMouseAngle()
    return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function ZombiePlayerAngle(enemy)
    return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function spawnZombie()

    
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = 125
    zombie.dead = false
    
    local side = math.random(1, 4)      -- sides 1,2,3,4
    if side == 1 then
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 2 then
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 3 then
        zombie.x = math.random(0, love.graphics.getHeight())
        zombie.y = -30
    elseif side == 4 then
        zombie.x = math.random(0, love.graphics.getHeight())
        zombie.y = love.graphics.getHeight() + 30
    end

    table.insert(zombies, zombie)
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.direction = playerMouseAngle()
    bullet.dead = false

    table.insert(bullets, bullet)
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end