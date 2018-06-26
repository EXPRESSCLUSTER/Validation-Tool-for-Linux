# The Validation Tool for EXPRESSCLUSTER Linux Version

This tool can be used for validation of EXPRESSCLUSTER configuration file(clp.conf).
Checking items are here.
* Interconnect IP address check
* FIP address check
* Device existence check (disk, mirror disk, hybrid disk)

## Supported OS 
RHEL 7.x

## Limitation
* A individual setting by server is not supported currently.

## How to use
1. Put clp_validate.sh in your ECX system.
2. Execute `chmod +x clp_validate.sh`
3. Execute `./clp_validate.sh`

    If you have clp.conf of other system, you can supecify the file as below.
    
    e.g.) Put clp.conf under /tmp before execute this command.
    
    `./clp_validate.sh /tmp/clp.conf` 
