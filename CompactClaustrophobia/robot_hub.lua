local S = require('shell')
local drive_short_code = '1fa' -- edit this to match the start of your floppy's ID
local wd = '/mnt/'..drive_short_code..'/'
local menu =
    '  1. - 3x3x3 Cube With Core\n' ..
    '  2. - 1x2x1 Pillar\n'
local programs = {
    '3x3x3_cube_core',
    '1x2x1_pillar'
}

local function prompt()
    S.execute('clear')
    print('Enter a number to select a routine below:')
    print(menu)
    io.write('    > ')
    local _ = io.read()
    print()
    return _
end

local function stall()
    print('\nPress enter to continue...')
    io.read()
end

local function main()
    local input = prompt()
    local num_form = tonumber(string.sub(input,1,1))
    if num_form
            and num_form > 0
            and num_form < 3 then
        S.execute(wd..programs[num_form])
        stall()
    else
        print('Please select one of the items on the menu!')
        stall()
    end
    return main()
end

main()
