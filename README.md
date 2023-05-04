# SubReveal
SubReveal is an all-in-one subdomain enumeration package for lazy hackers!
It takes a text file containing a list of subdomains, and scans them with the following tools to find subdomains and combine the results:
Amass
Subfinder
Assetfinder
The tool also checks the result of crt.sh, and parses the json output to extract subdomains.
The result is sorted and unique, so no wirries of duplicated results.
Lastly the liveliness of subdomains is checked using tomnomnom's httprobe and results are saved in a separate file.
# Usage
```bash
./subreveal root_domains.txt
```
# Notes
This tool is an automation of well known tools, so credits goes to the creaters of Amass, Subfinder, Assetfinder and Httprobe.
The tool is new, I plan to add more features and scan automations in near future.
