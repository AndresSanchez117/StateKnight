Jinn = Class{}

require 'Animation'

local texture = love.graphics.newImage('Assets/Enemy/jinn/Idle1.png')

local idleFrames = {}
for i=1, 3 do
    idleFrames[i] = love.graphics.newImage('Assets/Enemy/jinn/Idle' .. i .. '.png')
end

local attackFrames = {}
for i=1, 4 do
    attackFrames[i] = love.graphics.newImage('Assets/Enemy/jinn/Attack' .. i .. '.png')
end

local dieFrames = {}
for i=1, 6 do
    dieFrames[i] = love.graphics.newImage('Assets/Enemy/jinn/Death' .. i .. '.png')
end

function Jinn:init()
    self.width = texture:getWidth()
    self.height = texture:getHeight()

    self.typeFont = love.graphics.newFont('Fonts/flappy.ttf', 14)
    self.attackFont = love.graphics.newFont('Fonts/flappy.ttf', 18)

    self.x = 224
    self.y = 75

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
        }
    }

    self.state = 'idle'
    self.animation = self.animations['idle']
    self.dead = false

    self.behaviors = {
        ['idle'] = function(dt)

        end,
        ['attack'] = function(dt)
            if self.animation.currentFrame == 1 then
                sounds['zap']:play()
            end
            if self.animation.currentFrame == 4 then
                self.state = 'idle'
                self.animation = self.animations['idle']
            end
        end,
        ['die'] = function(dt)
            if self.animation.currentFrame == 6 then
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

function Jinn:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
end

function Jinn:render()
    if self.dead == true then
        -- Nada, genio desaparece al morir
    else
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setFont(self.typeFont)
        love.graphics.printf('Genio de ' .. self.type, math.floor(self.x - self.width / 2 + 8), math.floor(self.y - 6), self.width * 2, 'center')

        -- Si esta atacando imprime el tipo de ataque
        if self.state == 'attack' then
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.setFont(self.attackFont)
            love.graphics.printf('!' .. self.tipoAtaque .. '!', 0, 40, VIRTUAL_WIDTH, 'center')
        end

        if self.type == 'Fuego' then
            love.graphics.setColor(255, 0, 0, 255)
        elseif self.type == 'Electricidad' then
            love.graphics.setColor(255, 225, 0, 255)
        elseif self.type == 'Hielo' then
            love.graphics.setColor(9, 210, 240, 255)
        else -- Agua
            love.graphics.setColor(255, 255, 255, 255)
        end

        love.graphics.draw(self.animation:getCurrentFrame(), math.floor(self.x), math.floor(self.y), 0, -1, 1, self.width, 0)
    end
end
