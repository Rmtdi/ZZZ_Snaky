Snake = Object:extend()

function Snake:new(h_x,h_y,sn)
    -- 初始化蛇头的坐标 body表第一位为蛇头，后为蛇身
    self.body = {}
    table.insert(self.body, 1, {x = h_x, y = h_y})

    self.sn = sn

    -- 蛇的长度
    self.length = 6

    -- 蛇身、蛇头图片
    self.body_image = love.graphics.newImage("snake_body.png")
    self.head_image = love.graphics.newImage("snake_head.png")

    -- 蛇头方向 默认不动
    self.direction = {"none"}
    -- 蛇头朝向 用来处理回头bug：在蛇尚未移动时，快速转头再快速反向，就可以达成原地转头
    self.face = {"Down"}

    -- 计时器
    self.move_timer = love.timer.getTime()
    self.food_timer = love.timer.getTime()

    -- 速度（sec/cell）默认0.2
    self.speed = 0.15

    -- 可移动 死亡判定
    self.canMove = true

    -- 存活判定
    self.alive = true

    self.move_Start = false

end

function Snake:update(dt)

    if self.alive then
        
        self:directionInput()

        -- 清理过期按键的代码在后面，这里实现第一次输入就改变方向
        if self.direction[1] == "none" then 
            table.insert(self.face, self.direction[#self.direction])
        elseif self.direction[1] ~= "none" then 
            self.move_Start = true
        end

        if love.keyboard.isDown("space") then -- 加速~~
            self.speed=0.1
        else
            self.speed=0.2
        end

        if #self.direction > 1 then -- 保留最新的方向
            for i = #self.direction-1 ,1 ,-1 do
                table.remove(self.direction, i)
            end
        end
        if #self.direction > 1 then -- 保留最新的朝向
            for i = #self.direction-1 ,1 ,-1 do
                table.remove(self.face, i)
            end
        end

        -- 朝蛇头方向运动
        if love.timer.getTime() - self.move_timer >= self.speed then
            self.move_timer = love.timer.getTime() -- 重置计时器

            self:Move()
        end

        

        -- 判断碰撞
        -- for index, pair in ipairs(self.body) do 
        --     if self.direction[1] ~= "none"
        --     and index ~= 1 
        --     and nextX == pair.x 
        --     and nextY == pair.y then 
        --         -- while love.timer.getTime() - self.move_timer <= 0.5 do 
        --         --     if (self.face[#self.face]=="Up" or self.face[#self.face]=="Down") 
        --         --     and (love.keyboard.isDown("Left")) then
        --         --         table.insert(self.direction, "Left")

        --         --     elseif (self.face[#self.face]=="Up" or self.face[#self.face]=="Down") 
        --         --     and (love.keyboard.isDown("Right")) then
        --         --         table.insert(self.direction, "Right")

        --         --     elseif(self.face[#self.face]=="Left" or self.face[#self.face]=="Down") 
        --         --     and (love.keyboard.isDown("Up")) then
        --         --         table.insert(self.direction, "Up")
        --         --     elseif(self.face[#self.face]=="Left" or self.face[#self.face]=="Down") 
        --         --     and (love.keyboard.isDown("Down")) then
        --         --         table.insert(self.direction, "Down")
        --         --     end
        --         --     local nX,nY = self:Move(self.direction, nowX, nowY)
                    
        --         --     for index, pair in ipairs(self.body) do 
        --         --         if index ~= 1 
        --         --         and nX == pair.x 
        --         --         and nY == pair.y then
        --         --             self.canMove = false 
        --         --         elseif nX ~= pair.x 
        --         --         and nY ~= pair.y then
        --         --             self.canMove = true
        --         --             nextX=nX
        --         --             nextY=nY
        --         --             break
        --         --         end
        --         --     end
        --         -- end
        --         self.canMove = false
        --         self.move_timer = love.timer.getTime()
        --     else
        --         table.insert(self.body, 1, {x = nextX, y = nextY}) -- 在蛇头要移动地方向生成蛇头
        --     end
        -- end
        

        
        if self.canMove then
            
            self:eatFood()
        elseif self.canMove == false then
            self.alive = false
        end
    else 
        SwitchScences("gameover")
    end
end

function Snake:draw()
    -- 绘制蛇
    local r = 0
    local h_width = self.head_image:getWidth()
    local h_height = self.head_image:getHeight()
    for i=#self.body, 1, -1 do
        if i == 1 then 
            if self.face[#self.face] == "Up" then
                r = math.pi
            elseif self.face[#self.face] == "Down" or self.face[#self.face] == "none" then 
                r = 0
            elseif self.face[#self.face] == "Left" then
                r = 0.5*math.pi
            elseif self.face[#self.face] == "Right" then 
                r = -0.5*math.pi
            end
            love.graphics.draw(self.head_image, self.body[1].x * 32 + 16, self.body[1].y * 32 +16, r,1,1, 16,16)
        else
            love.graphics.draw(self.body_image, self.body[i].x * 32, self.body[i].y * 32)
        end
    end

    for i=1,#self.direction do
        love.graphics.print("Direction: "..self.direction[i],10,i*10)
    end
    love.graphics.print("Face: "..self.face[#self.face],150,10)
    love.graphics.print("speed: "..self.speed,10,30)
    love.graphics.print("speed: "..self.face[#self.face],10,50)
    love.graphics.print("length: "..self.length.." score: "..scores[self.sn].snake,10,70)
end

function Snake:directionInput()
    --检测按键-控制方向
    if self.direction[#self.direction]~="Left" -- 不可加同向
    and self.direction[#self.direction]~="Right" -- 不可加反向
    and love.keyboard.isDown("left") then 
        table.insert(self.direction, "Left")
    elseif self.direction[#self.direction]~="Left" 
    and self.direction[#self.direction]~="Right" 
    and love.keyboard.isDown("right") then
        table.insert(self.direction, "Right")
    elseif self.direction[#self.direction]~="Up" 
    and self.direction[#self.direction]~="Down" 
    and love.keyboard.isDown("up") then
        table.insert(self.direction, "Up")
    elseif self.direction[#self.direction]~="Up" 
    and self.direction[#self.direction]~="Down" 
    and love.keyboard.isDown("down") then
        table.insert(self.direction, "Down")
    end
end 

function Snake:nextPosition(direction, X, Y) -- 计算蛇下一步移动在哪的函数 
    if direction[#direction] == "Left" then 
        if X - 1 == 0 then --实现环绕，以下同
            X = map_width
        else
            X = X-1
        end
    elseif direction[#direction] == "Right" then 
        if X + 1 == map_width+1 then
            X = 1
        else
            X = X+1
        end
    elseif direction[#direction] == "Up" then 
        if Y - 1 == 0 then
            Y = map_height
        else
            Y = Y-1
        end
    elseif direction[#direction] == "Down" then 
        if Y + 1 == map_height+1 then
            Y = 1
        else
            Y = Y+1
        end
    end
    return X,Y
end

function Snake:Move()
    -- 下一坐标以当前蛇头坐标为基准
    local nowX = self.body[1].x
    local nowY = self.body[1].y

    if self.move_Start -- face为上下时direction不能为上下，face为左右时direction不能为左右
    and not( (self.face[#self.face]=="Up" or self.face[#self.face]=="Down") and (self.direction[#self.direction]=="Up" or self.direction[#self.direction]=="Down") )
    and not( (self.face[#self.face]=="Left" or self.face[#self.face]=="Right") and (self.direction[#self.direction]=="Left" or self.direction[#self.direction]=="Right") ) 
    then
        nextX,nextY = self:nextPosition(self.direction, nowX, nowY)
        
        -- 检测碰撞
        self:isCollision(self.direction, nextX, nextY)

        -- 确认移动方向，将face更改为当前direction
        table.insert(self.face,self.direction[#self.direction])
    else
        nextX,nextY = self:nextPosition(self.face, nowX, nowY)

        -- 检测碰撞
        self:isCollision(self.direction, nextX, nextY)
    end

    -- 插入新蛇头
    table.insert(self.body, 1, {x = nextX, y = nextY}) 

    if #self.body > self.length then -- 清除多余的蛇身
        table.remove(self.body, #self.body)
    end
end

function Snake:isCollision(direction,X,Y) -- 碰撞检测
    if self.move_Start then 
        for i, pair in ipairs(self.body) do
            if i ~= 1
            and X == pair.x 
            and Y == pair.y then


                self.canMove = false 
            end 
        end
    end
end

function Snake:eatFood() -- 判断吃食物
    for i = #foods, 1, -1 do
        if nextX == foods[i].x 
        and nextY == foods[i].y then
            table.remove(foods, i)
            self.length = self.length + 1 
            scores[self.sn].snake = self.length
        end 
    end
end