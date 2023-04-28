-- wget https://raw.githubusercontent.com/Zeruel13/gt_MachineOS/master/setup.lua -f
local shell = require("shell")
local computer = require("computer")
local filesystem = require("filesystem")

local tarMan = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/usr/man/tar.man"
local tarBin = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/home/bin/tar.lua"

shell.setWorkingDirectory("/usr/man")
shell.execute("wget -fq " .. tarMan)
shell.setWorkingDirectory("/bin")
shell.execute("wget -fq " .. tarBin)

local gt_MachineOS = "https://github.com/Zeruel13/gt_MachineOS/releases/latest/download/gt_MachineOS.tar"

shell.setWorkingDirectory("/home")
print("Downloading gt_MachineOS...")
shell.execute("wget -fq " .. gt_MachineOS .. " -f")


shell.execute("mkdir tmp") --Making a tmp directory
shell.execute("mv gt_MachineOS.tar tmp/") --Moving gt_MachineOS to tmp
shell.setWorkingDirectory("/home/tmp") --setting work directory to /home/tmp
print("unpacking gt_MachineOS.tar...")
shell.execute("tar -xf gt_MachineOS.tar")
shell.execute("rm gt_MachineOS.tar") --deleting gt_MachineOS.ta

shell.execute("mv .shrc /home") --move .shrc to home. This will allow the computer to auto-run main.lua upon reboot. 
if not filesystem.exists("/home/gt_machineOS") then --if a folder called gt_MachineOS doesn't exist, users are installing for the first time
    print("Installing gt_MachineOS for the first time...")
	shell.execute("mkdir /home/gt_MachineOS") -- make the gt_MachineOS direcotry
    shell.execute("mv * /home/gt_MachineOS") -- move all files in tmp to /home/gt_MachineOS
else
    print("Updating gt_MachineOS...")
    shell.execute("mv *.lua /home/gt_MachineOS") -- move all lua files. If updating, we don't want to overwrite all their addresses in addressList
end

-- delete temporary files
print("Cleaning up...")
shell.setWorkingDirectory("/home")
shell.execute("rm -rf tmp")
shell.execute("rm -f setup.lua")

print("Success!\n")
print("Rebooting...")
os.sleep(2)
computer.shutdown(true)