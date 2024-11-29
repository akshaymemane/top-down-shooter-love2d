function loadMovements(object, dt)
    if love.keyboard.isDown('d') and object.x < WINDOW_WIDTH then
        object.x = object.x + object.speed * dt
    end
    -- move Left
    if love.keyboard.isDown('a') and object.x > 0 then
        object.x = object.x - object.speed * dt
    end

    -- move Up
    if love.keyboard.isDown('w') and object.y > 0 then
        object.y = object.y - object.speed * dt
    end
    -- move Down
    if love.keyboard.isDown('s') and object.y < WINDOW_HEIGHT then
        object.y = object.y + object.speed * dt
    end
end