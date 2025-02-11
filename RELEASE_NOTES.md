# RELEASE_NOTES

All notable changes to this project will be documented in this file.


## v1.5.9 / 2024-12-06
### 1. Changed
- update throttling logic (default off, added cooldown)
### 2. Fixed
- 
### 3. Added
- update throttling config by json file

## v1.5.9 / 2024-12-06
### 1. Changed
- Alert warning to host when NPU temperature reaches emergency threshold
- Alert Error to host when lpddr Link-ECC double-bit error occurs
### 2. Fixed
- Modify the state of inf_flow_mon to disabled
### 3. Added
- SMBUS slave mode for H1 board
- 

## v1.5.8 / 2024-11-22
### 1. Changed
- update pcie link-up logic (timeout 1s -> 5s)
- update throttling logic (default off, mode=step)
### 2. Fixed
- 
### 3. Added
- 
- 

## v1.5.7 / 2024-11-15
### 1. Changed
- Alert NPU error -> NPU event [error, notify] to host
### 2. Fixed
- 
### 3. Added
- NPU recovery concept
- Notify message about thermal throttling & emergency

## v1.5.6 / 2024-11-05
### 1. Changed
-
### 2. Fixed
- disable lpddr temperature interrupt
### 3. Added
- NPU Clock off by message 

## v1.5.4 / 2024-10-29
### 1. Changed
- reduce boot time
- LPDDR Enable duty train
### 2. Fixed
### 3. Added
- Support H1 (quattro) Board with 6.4GHz

## v1.5.3 / 2024-10-28
### 1. Changed
### 2. Fixed
- fix LPDDR low performance problem
### 3. Added

## v1.5.2 / 2024-10-28
### 1. Changed
- Improved function to pass status information to host when an error occurs
- update inference flow monitoring with process id
- pvt 2-point calibration
- ubbpdate pcie revision to support new memory map(0x00->0x01)
### 2. Fixed
- 
### 3. Added
- Idle Hook for Sleep Mode

## v1.5.1 / 2024-10-04
### 1. Changed
- Update lock mechanism for queue
### 2. Fixed
- 
### 3. Added
-

## v1.5.0 / 2024-09-20
### 1. Changed
- LPDDR5 Clock 5.5 GHz
- PCIE link-up logic
### 2. Fixed
- request Q. dequeue bug
### 3. Added
- Nor Flash Booting

## v1.4.7 / 2024-08-05
### 1. Changed
- remove app 'testcase'
### 2. Fixed
- 
### 3. Added
- 

## v1.4.6 / 2024-07-31
### 1. Changed
- fw: pcie link-up check logic
### 2. Fixed
- fw: timer overflow
### 3. Added
- 

## v1.4.5 / 2024-07-23
### 1. Changed
- pcie link-up check logic
### 2. Fixed
- get_timer API overflow
- UART RX Pull-Up for interrupt W/A
### 3. Added
- nor flash driver (by build option)
