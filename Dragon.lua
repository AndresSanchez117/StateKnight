Dragon = Class{}

require 'Animation'

local texture = love.graphics.newImage('Assets/Enemy/dragon/Idle1.png')
local fireTexture = love.graphics.newImage('Assets/Enemy/dragon/Fire_Attack1.png')

local idleFrames = {}
for i=1, 3 do
    idleFrames[i] = love.graphics.newImage('Assets/Enemy/dragon/Idle' .. i .. '.png')
end

local attackFrames = {}
for i=1, 4 do
    attackFrames[i] = love.graphics.newImage('Assets/Enemy/dragon/Attack' .. i .. '.png')
end

local fireFrames = {}
for i=1, 6 do
    fireFrames[i] = love.graphics.newImage('Assets/Enemy/dragon/Fire_Attack' .. i .. '.png')
end 

local dieFrames = {}
for i=1, 5 do
    dieFrames[i] = love.graphics.newImage('Assets/Enemy/dragon/Death' .. i .. '.png')
end

function Dragon:init()
    self.width = texture:getWidth()
    self.height = texture:getHeight()

    self.typeFont = love.graphics.newFont('Fonts/flappy.ttf', 14)
    self.attackFont = love.graphics.newFont('Fonts/flappy.ttf', 18)

    self.x = 200
    self.y = 0

    self.animations = {
        ['idle'] = Animation {
            texture = texture,
            frames = idleFrames,
            interval = 0.3
        },
        ['attack'] = Animation {
            texture = texture,
            frames = attackFrames,
            interval = 0.3
        },
        ['die'] = Animation {
            texture = texture,
            frames = dieFrames,
            interval = 0.2
        },
        ['fire'] = Animation {
            texture = texture,
            frames = fireFrames,
            interval = 0.25
        }
    }

    self.state = 'idle'
    self.animation = self.animations['idle']
    self.fireAnimation = self.animations['fire']
    self.dead = false

    self.behaviors = {
        ['idle'] = function(dt)

        end,
        ['attack'] = function(dt)
            if self.animation.currentFrame == 1 then
                sounds['fuego']:play()
            end
            if self.fireAnimation.currentFrame == 6 then
                self.state = 'idle'
                self.animation = self.animations['idle']
            end
        end,
        ['die'] = function(dt)
            if self.animation.currentFrame == 5 then
                self.dead = true
            end
        end
    }

    -- Generacion de tipo random
    self.generatedType = math.random(4)
    if self.generatedType == 1 then
        self.type = 'Fuego'
        self.tipoAtaque = 'Fuego'
    elseif self.generatedType == 2 then
        self.type = 'Electricidad'
        self.tipoAtaque = 'Electricidad'
    elseif self.generatedType == 3 then
        self.type = 'Hielo'
        self.tipoAtaque = 'Hielo'
    else
        self.type = 'Agua'
        self.tipoAtaque = 'Agua'
    end
end

function Dragon:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    --self.fireAnimation:update(dt)
    if self.state == 'attack' then
        self.fireAnimation:update(dt)
    end
end

function Dragon:render()
    -- Imprime tipo del dragon
    if self.dead == false then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setFont(self.typeFont)
        love.graphics.printf('Dragon de ' .. self.type, math.floor(self.x - self.width / 2 - 4), math.floor(self.y + 85), self.width * 2, 'center')
    end

    -- Si esta atacando imprime el tipo de ataque
    if self.state == 'attack' then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setFont(self.attackFont)
        love.graphics.printf('!' .. self.tipoAtaque .. '!', 0, 40, VIRTUAL_WIDTH, 'center')
    end

    -- Selecciona el color segun tipo
    if self.type == 'Fuego' then
        love.graphics.setColor(255, 255, 255, 255)
    elseif self.type == 'Electricidad' then
        love.graphics.setColor(205, 255, 0, 255)
    elseif self.type == 'Hielo' then
        love.graphics.setColor(9, 100, 240, 255)
    else -- Agua
        love.graphics.setColor(0, 0, 215, 255)
    end

    -- Dibuja el dragon mismo
    if self.dead == true then
        love.graphics.draw(dieFrames[5], math.floor(self.x), math.floor(self.y), 0, -1, 1, self.width, 0)
    elseif self.state == 'attack' then
        love.graphics.draw(self.animation:getCurrentFrame(), math.floor(self.x), math.floor(self.y), 0, -1, 1, self.width, 0)
        love.graphics.draw(self.fireAnimation:getCurrentFrame(), math.floor(self.x - 160), math.floor(self.y + 15), 0, -1, 1, self.width, 0)
    else
        love.graphics.draw(self.animation:getCurrentFrame(), math.floor(self.x), math.floor(self.y), 0, -1, 1, self.width, 0)
    end
end