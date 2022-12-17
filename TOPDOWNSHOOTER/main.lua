function love.load()
    math.randomseed(os.time())
    sprites ={}
    sprites.background= love.graphics.newImage('background.png')
    sprites.bullet= love.graphics.newImage('bullet.png')
    sprites.player= love.graphics.newImage('player.png')
    sprites.zombie= love.graphics.newImage('zombie.png')

    player={}
    player.x = love.graphics.getWidth()/2
    player.y = love.graphics.getHeight()/2
    player.speed =180
    gameFont = love.graphics.newFont(40)
    
    zombies = {}
    bullets = {}
    lives=2
    score=0
    gameState = 1
    maxTime =2
    timer = maxTime
end 

function love.update(dt)
    if gameState ==2 then
        if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
            player.x=player.x+player.speed*dt
        end
        if love.keyboard.isDown("a") and player.x >0 then
            player.x=player.x-player.speed*dt
        end
        if love.keyboard.isDown("w") and player.y >0 then
            player.y=player.y-player.speed*dt
        end
        if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
            player.y=player.y+player.speed*dt
        end
    end

    for i,z in  ipairs(zombies) do
        z.x = z.x + math.cos(zombiePlayerAngle(z)) * z.speed * dt

        z.y = z.y + math.sin(zombiePlayerAngle(z))* z.speed * dt
        if distanceBetween(z.x,z.y,player.x,player.y) < 30 then
            lives = lives -1
            
            if lives == 0 then
                for i,z in ipairs(zombies) do 
                    zombies[i]=nil
                end
                gameState=1
                player.x = love.graphics.getWidth()/2
                player.y = love.graphics.getHeight()/2
            else
                for i,z in ipairs(zombies) do 
                    zombies[i]=nil
                end
                player.x = love.graphics.getWidth()/2
                player.y = love.graphics.getHeight()/2
            end
        end
    end

    for i,b in ipairs(bullets) do 
        b.x = b.x + math.cos(b.direction)*b.speed*dt
        b.y= b.y + math.sin(b.direction)*b.speed*dt
    end

    for i=#bullets,1,-1 do
        local b = bullets[i]
        if b.x <0 or b.y<0 or b.x > love.graphics.getWidth() or b.y> love.graphics.getHeight() or b.dead == true then
            table.remove(bullets,i)
        end
        
    end

    for i,z in ipairs(zombies) do
        for j,b in ipairs(bullets) do
            if distanceBetween(z.x,z.y,b.x,b.y) <20 then
                z.dead=true
                b.dead=true
                score=score+1
            end
        end
    end

    for i=#zombies,1,-1 do
        local z = zombies[i]
        if z.dead == true then
            table.remove(zombies,i)
        end
    end

    if gameState == 2 then 
        timer = timer - dt
        if timer <=0 then
            spawnZombie()
            maxTime = 0.90 * maxTime
            timer =maxTime
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background,0,0)
    if gameState ==1 then
        love.graphics.setFont(gameFont)
        love.graphics.printf("Click anywhere to begin!",0,50,love.graphics.getWidth(),"center")
    end
    love.graphics.printf("Score : ".. score ,0,love.graphics.getHeight()-50,love.graphics.getWidth(),"left")
    love.graphics.printf("Lives left : ".. lives ,0,love.graphics.getHeight()-50,love.graphics.getWidth(),"right")
    if lives==1 then
        love.graphics.setColor(1,0,0)
        love.graphics.draw(sprites.player,player.x,player.y,playerMouseAngle(),nil ,nil,17.5,21.5)
    else
        love.graphics.draw(sprites.player,player.x,player.y,playerMouseAngle(),nil ,nil,17.5,21.5)
    end
    love.graphics.setColor(1,1,1)

    for i,z in ipairs(zombies) do 
        love.graphics.draw(sprites.zombie,z.x,z.y,zombiePlayerAngle(z),nil,nil,sprites.zombie:getWidth()/2,sprites.zombie:getHeight()/2)
    end
    
    for i,b in ipairs(bullets) do 
        love.graphics.draw(sprites.bullet,b.x,b.y,nil,0.4,0.4,sprites.bullet:getWidth()/2,sprites.bullet:getHeight()/2)
    end
    

end

function playerMouseAngle()
    return math.atan2(player.y - love.mouse.getY(),player.x - love.mouse.getX()) + math.pi
end

function spawnZombie()
    local zombie = {}
    local side = math.random(1,4)
    if side==1 then
        zombie.x =-30
        zombie.y =math.random(0,love.graphics.getHeight())
    end
    if side==2 then 
        zombie.x =love.graphics.getWidth()+30
        zombie.y =math.random(0,love.graphics.getHeight())
    end
    if side==3 then
        zombie.x =math.random(0,love.graphics.getWidth())
        zombie.y =-30
    end
    if side==4 then
        zombie.x =math.random(0,love.graphics.getWidth())
        zombie.y =love.graphics.getHeight()+30
    end
    zombie.speed =140
    table.insert(zombies,zombie)
end

function love.keypressed(key)
    if key == "space" then
        
        spawnZombie()
    end
end

function zombiePlayerAngle(enemy)
    return math.atan2(player.y - enemy.y,player.x - enemy.x) 
end

function distanceBetween(x1,y1,x2,y2)
    return math.sqrt( (x2-x1)^2 + (y2-y1)^2)
end


function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed =500
    bullet.direction = playerMouseAngle()
    table.insert(bullets,bullet)
end


function love.mousepressed(x,y,button)
    if button==1 and gameState==2 then 
        spawnBullet()
    elseif button==1 and gameState==1 then
        gameState=2
        maxTime=2
        timer=maxTime
        score=0
        lives=2

    end
end