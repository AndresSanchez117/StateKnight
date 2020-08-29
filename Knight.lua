Knight = Class{}

require 'Animation'

-- Tabla de estado siguiente, se tienen los siguientes estados: (En Lua los indices comiezan en 1)
-- 1. Normal
-- 2. Debilitado
-- 3. Poderoso
-- 4. Quemado
-- 5. Congelado
-- 6. Mojado
-- 7. Envenedado
-- 8. Petrificado
-- 9. Electrocutado
-- 10. Herido
-- 11. Muerto

-- Entradas:
-- 1. Maldicion
-- 2. Corte
-- 3. Fuego
-- 4. Curacion
-- 5. Veneno
-- 6. Hielo
-- 7. Petrificacion
-- 8. Agua
-- 9. Electricidad
function Knight:tabla_f(estado, entrada)
    self.tablaEstadoSiguinte = {
        {2, 10, 4, 3, 7, 5, 8, 6, 9},
        {2, 11, 11, 1, 11, 11, 11, 6, 11},
        {1, 3, 1, 3, 1, 1, 1, 3, 1},
        {2, 10, 11, 1, 7, 1, 8, 1, 11},
        {2, 10, 1, 1, 7, 11, 8, 5, 9},
        {2, 10, 1, 3, 7, 5, 8, 6, 11},
        {2, 10, 4, 1, 11, 5, 8, 6, 9},
        {11, 8, 4, 1, 8, 5, 11, 6, 8},
        {2, 10, 11, 1, 7, 5, 8, 9, 11},
        {2, 11, 11, 1, 7, 5, 8, 6, 9},
        {11, 11, 11, 1, 11, 11, 11, 11, 11}
    }
    return self.tablaEstadoSiguinte[estado][entrada]
end

-- Salidas:
-- 1. Ser pequeño
-- 2. Ser rojo oscuro
-- 3. Ser rojo
-- 4. Ser grande
-- 5. Ser morado
-- 6. Ser azul claro
-- 7. Ser gris
-- 8. Ser azul oscuro
-- 9. Ser amarillo
-- 10. Tambalearse
-- 11. Caerse
-- 12. Celebrar
-- 13. Gritar
-- 14. Estar en el suelo
function Knight:tabla_g(estado, entrada)
    self.tablaSalida = {
        {1, 2, 3, 4, 5, 6, 7, 8, 9},
        {10, 11, 11, 12, 11, 11, 11, 8, 11},
        {13, 10, 13, 10, 13, 13, 13, 10, 13},
        {1, 2, 11, 12, 5, 12, 7, 12, 11},
        {1, 2, 13, 12, 5, 11, 7, 10, 9},
        {1, 2, 12, 4, 5, 6, 7, 10, 11},
        {1, 2, 3, 12, 11, 6, 7, 8, 9},
        {11, 10, 3, 12, 10, 6, 11, 8, 10},
        {1, 2, 11, 12, 5, 6, 7, 10, 11},
        {1, 11, 11, 12, 5, 6, 7, 8, 9},
        {14, 14, 14, 12, 14, 14, 14, 14, 14}
    }
    return self.tablaSalida[estado][entrada]
end

local SCALE_FACTOR = 0.08
local MOVE_SPEED = 80

function Knight:init()
    -- ESTADO inicial del caballero, al inicio es normal
    self.estado = 1
    -- Efecto visual del caballero, generado segun salidas, (vease main)
    self.efectoVisual = 'normal'

    self.texture = love.graphics.newImage('Assets/Knight/_IDLE/_IDLE_000.png')

    self.stateFont = love.graphics.newFont('Fonts/flappy.ttf', 14)

    self.idleFrames = {}
    for i=0, 6 do
        self.idleFrames[i + 1] = love.graphics.newImage('Assets/Knight/_IDLE/_IDLE_00' .. i .. '.png')
    end

    self.walkFrames = {}
    for i=0, 6 do
        self.walkFrames[i + 1] = love.graphics.newImage('Assets/Knight/_WALK/_WALK_00' .. i .. '.png')
    end

    self.attackFrames = {}
    for i=0, 6 do
       self.attackFrames[i + 1] = love.graphics.newImage('Assets/Knight/_ATTACK/_ATTACK_00' .. i .. '.png')
    end

    self.hurtFrames = {}
    for i=0, 6 do
        self.hurtFrames[i + 1] = love.graphics.newImage('Assets/Knight/_HURT/_HURT_00' .. i .. '.png')
    end

    self.jumpFrames = {}
    for i=0, 6 do
        self.jumpFrames[i + 1] = love.graphics.newImage('Assets/Knight/_JUMP/_JUMP_00' .. i .. '.png')
    end

    self.dieFrames = {}
    for i=0, 6 do
        self.dieFrames[i + 1] = love.graphics.newImage('Assets/Knight/_DIE/_DIE_00' .. i .. '.png')
    end

    self.width = math.floor(self.texture:getWidth() * SCALE_FACTOR)
    self.height = math.floor(self.texture:getHeight() * SCALE_FACTOR)

    self.x = 100
    self.y = 110

    self.animations = {
        ['idle'] = Animation {
            texture = self.texture,
            frames = self.idleFrames,
            interval = 0.1
        },
        ['walking'] = Animation {
            texture = self.texture,
            frames = self.walkFrames,
            interval = 0.1
        },
        ['attack'] = Animation {
            texture = self.texture,
            frames = self.attackFrames,
            interval = 0.1
        },
        ['hurt'] = Animation {
            texture = self.texture,
            frames = self.hurtFrames,
            interval = 0.1
        },
        ['jump'] = Animation {
            texture = self.texture,
            frames = self.jumpFrames,
            interval = 0.1
        },
        ['die'] = Animation {
            texture = self.texture,
            frames = self.dieFrames,
            interval = 0.1
        }
    }

    self.state = 'idle'
    self.size = 1
    self.yOffset = 0
    self.dead = false
    self.animation = self.animations['idle']

    self.stop = false
    self.behaviors = {
        ['idle'] = function(dt)

        end,
        ['walking'] = function(dt)
            if self.x > VIRTUAL_WIDTH then
                self.x = 0 - self.width
                self.stop = true
            else
                self.x = self.x + MOVE_SPEED * dt
            end

            if self.x > 95 and self.x < 105 and self.stop == true then
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.stop = false
            end
        end,
        ['attack'] = function(dt)
            if self.animation.currentFrame == 6 then
                self.state = 'idle'
                self.animation = self.animations['idle']
            end
        end,
        ['hurt'] = function(dt)
            if self.animation.currentFrame == 6 then
                self.state = 'idle'
                self.animation = self.animations['idle']
            end
        end,
        ['jump'] = function(dt)
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
end

function Knight:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
end

function Knight:render()
    -- Determina el estado actual segun el numero de estado, esto para imprimirse sobre la figura del caballero
    local estadoActual = ''
    if self.estado == 1 then
        estadoActual = 'Normal'
    elseif self.estado == 2 then
        estadoActual = 'Debilitado'
    elseif self.estado == 3 then
        estadoActual = 'Poderoso'
    elseif self.estado == 4 then
        estadoActual = 'Quemado'
    elseif self.estado == 5 then
        estadoActual = 'Congelado'
    elseif self.estado == 6 then
        estadoActual = 'Mojado'
    elseif self.estado == 7 then
        estadoActual = 'Envenenado'
    elseif self.estado == 8 then
        estadoActual = 'Petrificado'
    elseif self.estado == 9 then
        estadoActual = 'Electrocutado'
    elseif self.estado == 10 then
        estadoActual = 'Herido'
    elseif self.estado == 11 then
        estadoActual = 'Muerto'
    end

    love.graphics.setFont(self.stateFont)
    love.graphics.printf('Estado: ' .. estadoActual, math.floor(self.x - self.width / 2 - 10), math.floor(self.y - 24 + self.yOffset), self.width * 2, 'center')

    -- Selecciona efecto visual
    if self.efectoVisual == 'normal' then
        self.size = 1
        self.yOffset = 0
        love.graphics.setColor(255, 255, 255, 255)
    elseif self.efectoVisual == 'pequeno' then
        love.graphics.setColor(255, 255, 255, 255)
        self.size = 0.5
        self.yOffset = self.width / 2 - 5
    elseif self.efectoVisual == 'rojo oscuro' then
        self.size = 1
        love.graphics.setColor(155, 0, 0, 255)
    elseif self.efectoVisual == 'rojo' then
        self.size = 1
        love.graphics.setColor(255, 0, 0, 255)
    elseif self.efectoVisual == 'grande' then
        love.graphics.setColor(255, 255, 255, 255)
        self.size = 2
        self.yOffset = -self.width / 2
    elseif self.efectoVisual == 'morado' then
        self.size = 1
        love.graphics.setColor(102, 0, 102, 255)
    elseif self.efectoVisual == 'azul claro' then
        self.size = 1
        love.graphics.setColor(0, 255, 255, 255)
    elseif self.efectoVisual == 'gris' then
        self.size = 1
        love.graphics.setColor(128, 128, 128, 255)
    elseif self.efectoVisual == 'azul oscuro' then
        self.size = 1
        love.graphics.setColor(0, 20, 255, 255)
    elseif self.efectoVisual == 'amarillo' then
        self.size = 1
        love.graphics.setColor(255, 255, 0, 255)
    end

    if self.dead == true then
        love.graphics.draw(self.dieFrames[7], math.floor(self.x), math.floor(self.y + self.yOffset), 0, SCALE_FACTOR * self.size, SCALE_FACTOR * self.size)
    else
        love.graphics.draw(self.animation:getCurrentFrame(), math.floor(self.x), math.floor(self.y + self.yOffset), 0, SCALE_FACTOR * self.size, SCALE_FACTOR * self.size)
    end
end