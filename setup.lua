-- wget https://raw.githubusercontent.com/Zeruel13/gt_MachineOS/master/setup.lua -f
local shell = require("shell")

-- Download and install tar utility
local tarMan = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/usr/man/tar.man"
local tarBin = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/home/bin/tar.lua"

shell.setWorkingDirectory("/usr/man")
shell.execute("wget -fq " .. tarMan)
shell.setWorkingDirectory("/bin")
shell.execute("wget -fq " .. tarBin)

-- Check if updating or installing for the first time
local isUpdating = false
if shell.resolve("gt_MachineOS") then
  print("Updating gt_MachineOS")
  isUpdating = true
else
  print("Installing gt_MachineOS for the first time")
  shell.execute("mkdir gt_MachineOS")
end

-- Download and extract gt_MachineOS
local gt_MachineOS = "https://github.com/Zeruel13/gt_MachineOS/releases/latest/download/gt_MachineOS.tar"
shell.setWorkingDirectory("/home")

shell.execute("wget -fq " .. gt_MachineOS)
print("...")

if isUpdating then
  -- Extract all files except those in the addressList directory
  shell.setWorkingDirectory("/home/gt_MachineOS")
  shell.execute("mkdir tmp")
  shell.execute("tar -xf gt_MachineOS.tar -C tmp")
  shell.execute("cp -r tmp/gt_MachineOS/* .")
  shell.execute("rm -rf tmp/gt_MachineOS/addressList")
  shell.execute("rm -f tmp/gt_MachineOS.tar")
  shell.execute("rmdir tmp")
else
  -- Extract all files
  shell.execute("tar -xf gt_MachineOS.tar -C gt_MachineOS")
end

-- Remove the downloaded tar file and setup script
shell.execute("rm -f gt_MachineOS.tar setup.lua")

print("Success!\n")
