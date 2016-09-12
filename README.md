# Self Advancing and Propagating System Exploit Algorithm (SAPSEA)
## Software requirements
[Ruby](https://www.ruby-lang.org/en/)  
[Nmap](https://nmap.org/)  


## Summary
Self propagating algorithm that will create actively monitor, fingerprint, servey and create exploit attacks to maximise chance of exploit success.

Creates exploit lists containing exploits that may work, exploit lists have three categories:  
1. Visability => Vulnerabilities with the least chance of detection are used first  
2. Speed => Exploits that are the quickest to complete are used first (useful for large exploit tests)  
3. Chance of success => Uses fingerprining data to guage exploits with highest chance of success for the desired outcome type (shell/remote execution)

## Other software that may be used in the code base
The number of exploits to be used can be selected via the command line arguments, as well as the desired outcome and when the list execution will stop (either at the first successful exploit, or when the selected exploit length has been reached)

## Software
Will probably use nmap for most of the fingerprinting information relating to the os and software.
Wireshark may be used for connected network analysis of the system and its connected networks.

## Overview plan
```
– Get command line arguments
    – Main arguments include

    – Options include
        – Exploit mode (Visability, Speed, Chance of success)
        – Number of exploits to try (Arbetrary value/ 1+, set to full list length by default)
        – Desired outcome (shell/remote execution)

– Fingerprinting
    – Identify os
        – Identify base type of kernel (windows/linux/linux)
        – Identify os distro
        – Identify os kernel version
        – Identify os distro version
    – Identify software
        – Identify software name
        – Identify software version
    – Identify connected networks
        – Identify any networks machine connects to via
            – Viewing network connections via things like wireshark
            – Spoofing addresses in network range to see if connection can be established

– Categorise and compare usable exploits
    – Find usable exploits
        – Contains list of all usable exploits
        – Categorises against software, kernel and distro.
        – Categorises against selected outcome (shell/remote execution)
    – Categorise exploits into three category lists (Visability, Speed, Chance of success)
        – Category list selected via command line
    – Create exploit order list
        – Contains list of all exploits copied from selected category list
        – Number selected from command line arguments

– Exploit software 
    – Run each exploit in the exploit list
    – Check after each exploit whether the desired outcome is achieved (shell/remote execution)

– Return results
    – Return summary of exploits tested
    – Return outcome (desired outcome obtained, desired outcome not obtained)
    – Return summary of attacked system
```