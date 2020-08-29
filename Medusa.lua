Medusa = Class{}

require 'Animation'

local texture = love.graphics.newImage('Assets/Enemy/medusa/Idle1.png')

local idleFrames = {}
for i=1, 3 do
    idleFrames[i] = love.graphics.newImage('Assets/Enemy/medusa/Idle' .. i .. '.png')
end

local attackFrames = {}
for i=1, 6 do
    attackFrames[i] = love.graphics.newImage('Assets/Enemy/medusa/Attack' .. i .. '.png')
end

local dieFrames = {}
for i=1, 6 do
    dieFrames[i] = love.graphics.newImage('Assets/Enemy/medusa/Death' .. i .. '.png')
end

function Medusa:init()
    self.width = texture:getWidth()
    self.height = texture:getHeight()

    self.typeFont = love.graphics.newFont('Fonts/flappy.ttf', 14)
    self.attackFont = love.graphics.newFont('Fonts/flappy.ttf', 18)

    self.x = 224
    self.y = 90

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
            if self.animation.currentFrame == 3 then
                sounds['grito']:play()
            end
            if self.animation.currentFrame == 6 then
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
    self.generatedType = math.random(2)
    if self.generatedType == 1 then
        self.type = 'Petrificadora'
        self.tipoAtaque = 'Petrificacion'
    else
        self.type = 'Venenosa'
        self.tipoAtaque = 'Veneno'
    end
end

function Medusa:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
end

function Medusa:render()
    -- Imprime titulo de la medusa
    if self.dead == false then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setFont(self.typeFont)
        love.graphics.printf('Medusa ' .. self.type, math.floor(self.x - self.width / 2 + 8), math.floor(self.y + 2), self.width * 2, 'center')
    end

    -- Si esta atacando imprime el tipo de ataque
    if self.state == 'attack' then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setFont(self.attackFont)
        love.graphics.printf('!' .. self.tipoAtaque .. '!', 0, 40, VIRTUAL_WIDTH, 'center')
    end

    -- Selecciona color segun tipo
    if self.type == 'Petrificadora' then
        love.graphics.setColor(255, 255, 255, 255)
    else -- Venenosa
        love.graphics.setColor(112, 23, 172, 255)
    end

    if self.dead == true then
        love.graphics.draw(dieFrames[6], math.floor(self.x), math.floor(self.y), 0, -1, 1, self.width, 0)
    else
        love.graphics.draw(self.animation:getCurrentFrame(), math.floor(self.x), math.floor(self.y), 0, -1, 1, self.width, 0)
    end
end