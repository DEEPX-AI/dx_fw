# dx_fw
DEEPX FW Release

# Image Version Check

$ dxrt-cli -g ./m1/latest/${module (mdot2, h1, ...)}/fw.bin


# Image Update

$ systemctl stop dxrt.service

$ dxrt-cli -u ./m1/latest/${module (mdot2, h1, ...)}/fw.bin

$ systemctl start dxrt.service
