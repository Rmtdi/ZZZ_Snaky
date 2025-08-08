function love.update()
    if love.keyboard.isDown("space") then
        SwitchScences("game")
    end
end

function love.draw()
    a = scores
    for i = 1,#a do
        love.graphics.print("SCORE: "..a[1].snake,width/2,height/2)
    end
end