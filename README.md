# SubReveal
SubReveal is an all-in-one subdomain enumeration package for lazy hackers!  
It takes a text file containing a list of subdomains, and scans them with the following tools to find subdomains and combine the results:  
- Amass
- Subfinder
- Assetfinder  

The tool also checks the result of crt.sh, and parses the json output to extract subdomains. The result is sorted and unique, so no worries of duplicated results.
Lastly the liveliness of subdomains is checked using tomnomnom's httprobe and results are saved in a separate file.  
I have put the latest versions of the tools in the repo. In addition to having these tools in the current working directory, make sure to have
curl and jq packages installed in your linux, since they are used for communication with crt.sh.
# Usage
Get the script, get all the executables of tools (Amass, Subfinder, Assetfinder and Httprobe) and make sure all files are executable (use chmod +x command if necessary), and run the script:
```bash
./SubReveal.sh root_domains.txt
```  
There are three output files. "subsRevealed-raw.txt" containing combination of findings by 4 stages (Amass, Subfinder, Assetfinder, crt.sh). "subsRevealed-live.txt" contaning live subdomains determined by Httprobe. "ip-address.txt" containing ip address of each subdomain (you might want to port scan etc).
# Notes
SubReveal is an automation of well known tools, and credits go to the creators of Amass, Subfinder, Assetfinder and Httprobe. SubReveal executes the tools in this manner:
```bash
./tool [options]
```
Example:
```bash
./subfinder [options]
```
Therefor all of the executable files have to be in the current working directory and have execute permission.  
This tool is new, I plan to add more features and scan automations in near future. Feel free to share your ideas, or any bugs you encounter.
