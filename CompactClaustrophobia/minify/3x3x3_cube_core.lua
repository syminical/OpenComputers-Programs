-- slot 1 should be core blocks
-- slots 2-14 should be shell blocks
-- slot 16 should be catalyst items (dropped to minify)
-- leave enough empty slots for pickups (starting in slot 15)

local r = require 'robot'
local s = require 'shell'
local coreBlocks = 0
local shellBlocks = 0
local catalyst = 0
local resultSlot = 15
local errors = 0

local function init()
    s.execute('clear')
    coreBlocks = r.count(1)
    for i=2,14 do
        shellBlocks = shellBlocks + r.count(i)
    end
    catalyst = r.count(16)
    -- making sure slot 15 is free is enough because slots clear up
    -- for i=15,3,-1 do
    --     if r.count(i) == 0 then
    --         freeSlots = freeSlots + 1
    --     end
    -- end
end

local function putCore()
    r.select(1)
    if not r.placeDown() then
        errors = errors + 1
        print('Could not place core block!')
        print('Press enter...')
        io.read()
        return putCore()
    end
end

local function refill()
    for i=3,14 do
        if r.count(i) > 0 then
            r.select(i)
            r.transferTo(2)
            r.select(2)
            return true
        end
    end
    return false
end

local function putShell()
    r.select(2)
    if r.count(2) == 0 then
        if not refill() then
            errors = errors + 1
            print('Could not find shell blocks!')
            print('Press enter...')
            io.read()
            return putShell()
        end
    end
    if not r.placeDown() then
        errors = errors + 1
        print('Could not place shell block!')
        print('Press enter...')
        io.read()
        return putShell()
    end
end

local function drop()
    r.select(16)
    if not r.dropDown(1) then
        errors = errors + 1
        print('Could not drop catalyst!')
        print('Press enter...')
        io.read()
        return drop()
    end
end

local function forward()
    while not r.forward() do end
end

local function back()
    while not r.back() do end
end

local function up()
    while not r.up() do end
end

local function down()
    while not r.down() do end
end

local function minify()
    drop()
    os.sleep(1)
    if r.suckDown() then
        errors = errors + 1
        print('Minify failed!')
        print('Please fix the structure and press enter...')
        io.read()
        return minify()
    end
    -- os.sleep(9)
end

local function loot()
    r.select(resultSlot)
    if r.space(resultSlot) == 0 then
        repeat
            resultSlot = resultSlot - 1
            r.select(resultSlot)
        until resultSlot < 3 or r.space(resultSlot) > 0
        if resultSlot < 3 then
            errors = errors + 1
            print('No space for pick-up!')
            print('Please press enter...')
            io.read()
            return loot()
        end
    end
    back()
    if not r.suckDown() then
        forward()
        if not r.suckDown() then
            errors = errors + 1
            print('Could not pick up!')
            print('Please press enter')
            io.read()
            r.suckDown()
        end
    else
        forward()
    end
end

local function curlIn()
    -- right
    putShell()
    forward()
    putShell()
    forward()
    putShell()

    -- top
    r.turnLeft()
    forward()
    putShell()
    forward()
    putShell()

    -- left
    r.turnLeft()
    forward()
    putShell()
    forward()
    putShell()

    -- bottom
    r.turnLeft()
    forward()
    putShell()

    -- center
    r.turnLeft()
    forward()
    putShell()
end

local function curlOut()
    -- center
    putCore()

    -- top
    forward()
    putShell()
    r.turnLeft()
    forward()
    putShell()

    -- left
    r.turnLeft()
    forward()
    putShell()
    forward()
    putShell()

    -- bottom
    r.turnLeft()
    forward()
    putShell()
    forward()
    putShell()

    -- right
    r.turnLeft()
    forward()
    putShell()
    forward()
    putShell()
end

local function buildCube()
    -- step in
    up()
    forward()

    -- first layer
    curlIn()

    -- second layer
    up()
    curlOut()
    r.turnLeft()

    -- third layer
    up()
    curlIn()
    r.turnLeft()

    -- complete
    up()
    minify()
    down()
    down()
    down()
    loot()

    -- reset
    down()
    forward()
    forward()
    r.turnLeft()
    forward()
    r.turnLeft()
end

local function finish()
    r.turnAround()
    forward()
    forward()
    r.turnAround()
end

local function pluralS(n, s)
    if n == 1 then
        return ''..(n)..' '..(s)
    else
        return ''..(n)..' '..(s)..'s'
    end
end

local function build()
    if coreBlocks > 0
        and shellBlocks >= coreBlocks*26
        and catalyst >= coreBlocks
        -- and freeSlots >= math.ceil(coreBlocks / 16) - (coreBlocks / 3)
        and r.count(resultSlot) == 0
    then
        forward()
        forward()
        for i=1,coreBlocks do
            buildCube()
        end
        finish()
        print('Completed '..pluralS(math.floor(coreBlocks), 'time')..'! :)') --, with '..pluralS(math.floor(errors), 'error')..'! :)')
    else
        if coreBlocks == 0 then
            print('Missing core blocks!')
        end
        if shellBlocks < coreBlocks*26 then
            print('Missing '..pluralS(math.floor(coreBlocks*26-shellBlocks), 'shell block')..'!')
        end
        if catalyst < coreBlocks then
            print('Missing '..pluralS(math.floor(coreBlocks-catalyst), 'catalyst')..'!')
        end
        -- if freeSlots < math.ceil(coreBlocks / 16) - (coreBlocks / 3) or r.count(15) > 0 then
        if r.count(15) > 0 then
            print('Not enough free slots for pick-ups!')
        end
    end
end

local function main()
    s.execute('clear')
    print('Press enter to start building!')
    io.read()
    init()
    build()
end

main()
