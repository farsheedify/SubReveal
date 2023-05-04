# SubReveal
SubReveal is an all-in-one subdomain enumeration package for lazy hackers!
It takes a text file containing a list of subdomains, and scans them with the following tools to find subdomains and combine the results:
Amass
Subfinder
Assetfinder
The tool also checks the result of crt.sh, and parses the json output to extract subdomains.
The result is sorted and unique, so no wirries of duplicated results.
Lastly the liveliness of subdomains is checked using tomnomnom's httprobe and results are saved in a separate file.
I have put the latest versions of the tools in the repo. In addition to having these tools in the current working directory, make sure to have
curl and jq packages installed in your linux, since they are used for communication with crt.sh.
# Usage
Clone this repo, make sure all files are executable (use chmod +x command if necessary), and run the script.
```bash
./SubReveal.sh root_domains.txt
```
# Notes
This tool is an automation of well known tools, so credits goes to the creaters of Amass, Subfinder, Assetfinder and Httprobe.
The tool is new, I plan to add more features and scan automations in near future.
