
-- wget https://raw.githubusercontent.com/Zeruel13/gt_machineOS/master/setup.lua -f
local shell = require("shell")

local tarMan = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/usr/man/tar.man"
local tarBin = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/home/bin/tar.lua"

shell.setWorkingDirectory("/usr/man")
shell.execute("wget -fq " .. tarMan)
shell.setWorkingDirectory("/bin")
shell.execute("wget -fq " .. tarBin)

local gt_machineOS = "https://github.com/Zeruel13/gt_machineOS/releases/latest/download/gt_machineOS.tar"

shell.setWorkingDirectory("/home")
if not shell.resolve("/home/gt_machineOS") then
    shell.execute("mkdir gt_machineOS")
end

shell.setWorkingDirectory("/home/gt_machineOS")
print("\nUpdating gt_machineOS")
shell.execute("wget -fq " .. gt_machineOS .. " -f")
print("...")
shell.execute("tar -xf gt_machineOS.tar")
shell.execute("rm -f gt_machineOS.tar")

shell.setWorkingDirectory("/home/")
shell.execute("cp -r /home/test. /home/")
shell.execute("rm -f setup.lua")

print("Success!\n")
