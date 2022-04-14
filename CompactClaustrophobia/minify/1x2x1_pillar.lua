-- slots 1-4 should contain blocks for the top of the pillar
-- slots 5-8 should contain blocks for the bottom of the pillar
-- slot 16 should be catalyst items (dropped to minify)
-- leave enough empty slots for pickups (starting in slot 15)

local r = require('robot')
local s = require('shell')
local top_block = 0
local bottom_block = 0
local catalyst = 0
local resultSlot = 9
local errors = 0

local function refill_bottom()
    for i=6,8 do
        if r.count(i) > 0 then
            r.select(i)
            r.transferTo(5)
            r.select(5)
            return true
        end
    end
    return false
end

local function refill_top()
    for i=2,4 do
        if r.count(i) > 0 then
            r.select(i)
            r.transferTo(1)
            r.select(1)
            return true
        end
    end
    return false
end

local function put_top()
    r.select(1)
    if r.count(1) == 0 then
        if not refill_top() then
            errors = errors + 1
            print('Could not find top blocks!')
            print('Press enter...')
            io.read()
            return put_top()
        end
    end
    if not r.placeDown() then
        errors = errors + 1
        print('Could not place top block!')
        print('Press enter...')
        io.read()
        return put_top()
    end
end

local function put_bottom()
    r.select(5)
    if r.count(5) == 0 then
        if not refill_bottom() then
            errors = errors + 1
            print('Could not find bottom blocks!')
            print('Press enter...')
            io.read()
            return put_bottom()
        end
    end
    if not r.placeDown() then
        errors = errors + 1
        print('Could not place bottom block!')
        print('Press enter...')
        io.read()
        return put_bottom()
    end
end

local function refill_drop()
    for i=14,16 do
        if r.count(i) > 0 then
            r.select(i)
            r.transferTo(13)
            r.select(13)
            return true
        end
    end
    return false
end

local function drop()
    r.select(13)
    if r.count(13) == 0 then
        if not refill_drop() then
            errors = errors + 1
            print('Could not find catalyst!')
            print('Press enter...')
            io.read()
            return drop()
        end
    end
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
            resultSlot = resultSlot + 1
            r.select(resultSlot)
        until resultSlot > 12 or r.space(resultSlot) > 0
        if resultSlot > 12 then
            errors = errors + 1
            print('No space for pick-up!')
            print('Please press enter...')
            io.read()
            return loot()
        end
    end
    back()
    if not r.suckDown() then
        errors = errors + 1
        print('Could not pick up!')
        print('Please press enter')
        io.read()
        r.suckDown()
    end
    forward()
end

local function build_pillar()
    -- first layer
    put_bottom()

    -- second layer
    up()
    put_top()

    -- complete
    up()
    up()
    minify()
    down()
    down()
    down()
    loot()
end

local function get_set()
    forward()
    forward()
    forward()
    forward()
    r.turnLeft()
    forward()
    r.turnLeft()
    up()
end

local function finish()
    down()
    forward()
    forward()
    r.turnLeft()
    forward()
    r.turnRight()
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
    if top_block > 0
        and bottom_block >= top_block
        and catalyst >= top_block
        and r.count(resultSlot) == 0
    then
        -- step into position
        get_set()

        for i=1,top_block do
            build_pillar()
        end

        finish()
        print('Complated '..pluralS(math.floor(top_block), 'time')..'! :)') --, with '..pluralS(math.floor(errors), 'error')..'! :)')
    else
        if top_block == 0 then
            print('Missing top blocks!')
        end
        if bottom_block < top_block then
            print('Missing '..pluralS(math.floor(top_block-bottom_block), 'bottom block')..'!')
        end
        if catalyst < top_block then
            print('Missing '..pluralS(math.floor(top_block-catalyst), 'catalyst')..'!')
        end
        -- if freeSlots < math.ceil(top_block / 16) - (top_block / 3) or r.count(15) > 0 then
        if r.count(resultSlot) > 0 then
            print('Not enough free slots for pick-ups!')
        end
    end
end

local function init()
    s.execute('clear')

    -- shift things over if necessary
    refill_top()
    refill_bottom()
    refill_drop()

    for i=1,4 do
        top_block = top_block + r.count(i)
    end
    for i=5,8 do
        bottom_block = bottom_block + r.count(i)
    end
    catalyst = r.count(13)
    -- making sure slot 15 is free is enough because slots clear up
    -- for i=15,3,-1 do
    --     if r.count(i) == 0 then
    --         freeSlots = freeSlots + 1
    --     end
    -- end
end

local function main()
    s.execute('clear')
    print('Press enter to start building!')
    io.read()
    init()
    build()
end

main()
