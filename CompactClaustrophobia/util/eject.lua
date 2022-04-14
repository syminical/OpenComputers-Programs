c = require 'component'
drive_found, d = pcall(function()
    return c['disk_drive'] end)

if drive_found then
    d.eject()
else
    print("No disk drive found!")
end