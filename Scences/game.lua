-- 生成蛇
snakes = {}
    table.insert(snakes, Snake(5,5,1))
-- 计分
scores = {}
    for i=1,#snakes do
        table.insert(scores,{snake = snakes[i].length})
    end

function love.load()

    foods = {}
    food_timer = love.timer.getTime()

    wall = love.graphics.newImage("wall.png")
    floor = love.graphics.newImage("floor.png")
    map = love.graphics.newImage("map.png")

end

function love.update(dt)

    for i=1,#snakes do    
        snakes[i]:update(dt)
    end 

    -- 生成食物
    if #foods == 0 then 
        food_timer = love.timer.getTime()
        CreateFood()
    end
    if love.timer.getTime() - food_timer >= 8 then
        food_timer = love.timer.getTime()
        CreateFood()
    end
end


function love.draw()

    -- 画地图
    love.graphics.draw(map, 0, 0)

    -- 画食物
    if #foods > 0 then
        for i = 1, #foods do
            love.graphics.circle("fill",foods[i].x*32+16,foods[i].y*32+16,16)
        end
    end
    
    -- 画蛇
    for i=1,#snakes do 
        snakes[i]:draw()
    end 
end

function CreateFood ()

    local foodPosition = {}

	-- 遍历整个窗口，将可生成食物的位置记录在foodPosition表里
	for i = 1, map_width do
		for j = 1, map_height do
			local possible = true

			-- 是否与蛇身冲突
			for index, pair in ipairs (snakes[1].body) do
				if i == pair.x and j == pair.y then
					possible = false
				end
			end

			if possible then
				table.insert (foodPosition, { x = i, y = j })
			end
		end
	end

	-- 生成随机食物位置
	local index = love.math.random (#foodPosition)
	table.insert(foods,{x = foodPosition[index].x, y = foodPosition[index].y})
end