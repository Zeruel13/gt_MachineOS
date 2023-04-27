-- wget https://raw.githubusercontent.com/Zeruel13/gt_MachineOS/master/setup.lua -f
local shell = require("shell")

-- Download and install tar utility
local tarMan = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/usr/man/tar.man"
local tarBin = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/home/bin/tar.lua"

shell.setWorkingDirectory("/usr/man")
shell.execute("wget -fq " .. tarMan)
shell.setWorkingDirectory("/bin")
shell.execute("wget -fq " .. tarBin)

-- Download and extract gt_MachineOS
local gt_MachineOS = "https://github.com/Zeruel13/gt_MachineOS/releases/latest/download/gt_MachineOS.tar"

shell.setWorkingDirectory("/home")
if not shell.resolve("gt_MachineOS") then
    shell.execute("mkdir gt_MachineOS")
end

shell.setWorkingDirectory("/home/gt_MachineOS")
print("\nUpdating gt_MachineOS")
shell.execute("wget -fq " .. gt_MachineOS)
print("...")
if not shell.resolve("main.lua") then
    -- Extract all files
    shell.execute("tar -xf gt_MachineOS.tar")
else
    -- Extract all files except those in the addressList directory
    shell.execute("mkdir tmp")
    shell.execute("tar -xf gt_MachineOS.tar -C tmp")
    shell.execute("cp -r tmp/gt_MachineOS/* .")
    shell.execute("rm -rf tmp/gt_MachineOS")
    shell.execute("rm -f tmp/gt_MachineOS.tar")
    shell.execute("rmdir tmp")
end

shell.setWorkingDirectory("/home")
shell.execute("rm -f setup.lua")

print("Success!\n")
