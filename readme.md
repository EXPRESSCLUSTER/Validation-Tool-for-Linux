# The Validation Tool for EXPRESSCLUSTER Linux Version

This tool can be used for validatation of EXPRESSCLUSTER configuration file(clp.conf).

## Supported OS 
RHEL 7.x
## How to use
1. put clp_validate.sh in your ECX system.
2. execute `chmod +x clp_validate.sh`
3. execute `./clp_validate.sh`

    If you have clp.conf of other system, you can supecify the file as below.
    
    e.g.) Put clp.conf under /tmp before execute this command.
    
    `./clp_validate.sh /tmp/clp.conf` 
