function love.load()

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')
    
    WINDOW_WIDTH = love.graphics.getWidth()
    WINDOW_HEIGHT = love.graphics.getHeight()

    player = {}
    player.x = WINDOW_WIDTH / 2
    player.y = WINDOW_HEIGHT / 2
    player.speed = 200

    zombies = {}
    bullets = {}
    
end

function love.update(dt)
    -- move Right
    if love.keyboard.isDown('d') then
        player.x = player.x + player.speed * dt
    end
    -- move Left
    if love.keyboard.isDown('a') then
        player.x = player.x - player.speed * dt
    end

    -- move Up
    if love.keyboard.isDown('w') then
        player.y = player.y - player.speed * dt
    end
    -- move Down
    if love.keyboard.isDown('s') then
        player.y = player.y + player.speed * dt
    end

    -- IMPORTANT: make enemies follow the player
    for i,z in ipairs(zombies) do
        z.x = z.x + (math.cos(ZombiePlayerAngle(z)) * (z.speed * dt))
        z.y = z.y + (math.sin(ZombiePlayerAngle(z)) * (z.speed * dt))

        if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
            for i,z in ipairs(zombies) do
                zombies[i] = nil
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
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)
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
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        spawnBullet()
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
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = math.random(0, love.graphics.getHeight())
    zombie.speed = 125
    zombie.dead = false

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