Class = require 'class'
push = require 'push'
require 'Knight'
require 'Dragon'
require 'Medusa'
require 'Jinn'
require 'Demon'
require 'Lizard'
require 'SmallDragon'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 455
VIRTUAL_HEIGHT = 256

BACKGROUND_SCALE = 0.24
local backgrounds = {}
for i=1, 4 do
    backgrounds[i] = love.graphics.newImage('Assets/Scene/Battleground' .. i .. '.png')
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    love.window.setTitle('State Knight')

    largeFont = love.graphics.newFont('Fonts/flappy.ttf', 14)

    -- Sonidos
    sounds = {
        -- https://freesound.org/people/Trebblofang/sounds/177830/
        ['background'] = love.audio.newSource('Sounds/backgroundSound.mp3', 'static'),
        ['saltar'] = love.audio.newSource('Sounds/Celebrar.wav', 'static'),
        ['crecer'] = love.audio.newSource('Sounds/Crecer.wav', 'static'),
        ['gritar'] = love.audio.newSource('Sounds/Gritar.wav', 'static'),
        ['tambalearse'] = love.audio.newSource('Sounds/Tambalearse.wav', 'static'),
        ['atacar'] = love.audio.newSource('Sounds/Atacar.wav', 'static'),
        ['fuego'] = love.audio.newSource('Sounds/fuego.wav', 'static'),
        ['zap'] = love.audio.newSource('Sounds/zap.wav', 'static'),
        -- "Fox, Vocal Cry, Distant, 01.wav" by InspectorJ (www.jshaw.co.uk) of Freesound.org
        ['grito'] = love.audio.newSource('Sounds/scream.wav', 'static')
    }

    -- Iniciar sonido de fondo
    sounds['background']:setLooping(true)
    sounds['background']:play()

    background = backgrounds[math.random(4)]

    knight = Knight()
    enemigosDerrotados = 0
    
    -- Generacion inicial de enemigo
    local enemyGenerated = math.random(6)
    if enemyGenerated == 1 then
        enemy = Medusa()
    elseif enemyGenerated == 2 then
        enemy = Jinn()
    elseif enemyGenerated == 3 then
        enemy = Demon()
    elseif enemyGenerated == 4 then
        enemy = Lizard()
    elseif enemyGenerated == 5 then
        enemy = SmallDragon()
    else
        enemy = Dragon()
    end

    if math.random(2) == 1 then
        gameState = 'playerMove'
    else
        gameState = 'enemyMove'
    end

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    knight:update(dt)

    enemy:update(dt)

    if gameState == 'enemyMove' then
        enemy.state = 'attack'
        enemy.animation = enemy.animations['attack']
        gameState = 'enemyOnAttack'
    elseif gameState == 'playerWalking' then
        if knight.x > VIRTUAL_WIDTH then
            -- Nuevo enemigo
            local enemyGenerated = math.random(6)
            if enemyGenerated == 1 then
                enemy = Medusa()
            elseif enemyGenerated == 2 then
                enemy = Jinn()
            elseif enemyGenerated == 3 then
                enemy = Demon()
            elseif enemyGenerated == 4 then
                enemy = Lizard()
            elseif enemyGenerated == 5 then
                enemy = SmallDragon()
            else
                enemy = Dragon()
            end

            enemy.state = 'idle'
            enemy.animation = enemy.animations['idle']
            background = backgrounds[math.random(4)]
        end
        if knight.state == 'idle' then
            if math.random(2) == 1 then
                gameState = 'playerMove'
            else
                gameState = 'enemyMove'
            end
        end
    elseif gameState == 'enemyOnAttack' then
        if enemy.state == 'idle' then
            -- Aqui ocurre la transicion de estados y se determina una salida
            local entrada = enemy.tipoAtaque
            if entrada == 'Maldicion' then -- 1
                entrada = 1
            elseif entrada == 'Corte' then -- 2
                entrada = 2
            elseif entrada == 'Fuego' then -- 3
                entrada = 3
            elseif entrada == 'Curacion' then -- 4
                entrada = 4
            elseif entrada == 'Veneno' then -- 5
                entrada = 5
            elseif entrada == 'Hielo' then -- 6
                entrada = 6
            elseif entrada == 'Petrificacion' then -- 7
                entrada = 7
            elseif entrada == 'Agua' then -- 8
                entrada = 8
            elseif entrada == 'Electricidad' then -- 9
                entrada = 9
            else
                print("Ha ocurrido un error") -- Error se imprime a la consola
                love.event.quit() -- Sale del juego
            end

            -- Se genera una salida según el estado actual y la entrada
            local salida = knight:tabla_g(knight.estado, entrada)

            if salida == 1 then
                knight.efectoVisual = 'pequeno'
            elseif salida == 2 then
                knight.efectoVisual = 'rojo oscuro'
            elseif salida == 3 then
                knight.efectoVisual = 'rojo'
            elseif salida == 4 then
                knight.efectoVisual = 'grande'
                sounds['crecer']:play()
            elseif salida == 5 then
                knight.efectoVisual = 'morado'
            elseif salida == 6 then
                knight.efectoVisual = 'azul claro'
            elseif salida == 7 then
                knight.efectoVisual = 'gris'
            elseif salida == 8 then
                knight.efectoVisual = 'azul oscuro'
            elseif salida == 9 then
                knight.efectoVisual = 'amarillo'
            elseif salida == 10 then
                knight.state = 'hurt'
                sounds['tambalearse']:play()
                knight.animation = knight.animations['hurt']
                knight.animation:restart()
            elseif salida == 11 then
                knight.state = 'die'
                knight.animation = knight.animations['die']
            elseif salida == 12 then
                knight.efectoVisual = 'normal'
                knight.state = 'jump'
                sounds['saltar']:play()
                knight.animation = knight.animations['jump']
                knight.animation:restart()
            elseif salida == 13 then
                knight.efectoVisual = 'normal'
                sounds['gritar']:play()
            elseif salida == 14 then
                -- Quedarse muerto
            end
            
            -- Se selecciona el siguiente estado según la entrada
            knight.estado = knight:tabla_f(knight.estado, entrada)
            if knight.estado == 11 then -- Si esta muerto, game over
                gameState = 'gameOver'
            else
                gameState = 'playerMove'
            end
        end
    else
        -- Nothing
    end
end

function love.keypressed(key)
    -- love.keyboard.keysPressed[key] = true
    if key == 'escape' then
        love.event.quit()
    elseif key == 'a' then
        if gameState == 'playerMove' then
            sounds['atacar']:play()
            knight.state = 'attack'
            knight.animation = knight.animations['attack']
            knight.animation:restart()
            enemy.state = 'die'
            enemy.animation = enemy.animations['die']
            enemigosDerrotados = enemigosDerrotados + 1
            if enemigosDerrotados == 15 then
                gameState = 'win'
            else
                gameState = 'playerAdvance'
            end
        end
    elseif key == 's' then
        if gameState == 'playerAdvance' then
            knight.state = 'walking'
            knight.animation = knight.animations['walking']
            gameState = 'playerWalking'
        elseif gameState == 'gameOver' then
            -- Revivir
            knight.dead = false
            knight.efectoVisual = 'normal'
            knight.state = 'jump'
            sounds['saltar']:play()
            knight.animation = knight.animations['jump']
            knight.animation:restart()
            knight.estado = knight:tabla_f(knight.estado, 4)
            enemigosDerrotados = 0

            gameState = 'playerMove'
        end
    end
end

function love.draw()
    push:start()

    love.graphics.draw(background, 0, 0, 0, BACKGROUND_SCALE, BACKGROUND_SCALE)

    love.graphics.setFont(largeFont)

    if gameState == 'playerMove' then
        love.graphics.printf('Presiona A para atacar!', 0, 10, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'enemyOnAttack' then
        love.graphics.printf('Enemigo Ataca!', 0, 10, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'playerAdvance' then
        love.graphics.printf('Presiona S para avanzar!', 0, 10, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'gameOver' then
        love.graphics.printf('Juego Terminado. Presiona S si quieres revivir.', 0, 10, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'win' then
        love.graphics.printf('HAS GANADO!', 0, 10, VIRTUAL_WIDTH, 'center')
    end

    if gameState ~= 'playerWalking' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Derrotados: ' .. enemigosDerrotados .. "/15", 0, 30, VIRTUAL_WIDTH, 'right')
    end

    knight:render()

    enemy:render()

    push:finish()
end