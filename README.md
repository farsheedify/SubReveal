# SubReveal
SubReveal is an all-in-one subdomain enumeration package for lazy hackers!  
It takes a text file containing a list of root domains (one or more root domains), and executes the following stages to find subdomains and combine the results:  
- Amass Passive Scan
- Amass Active Scan
- Subfinder Scan
- Retrieve Subdomains from Crt.sh
- Assetfinder Scan

The results are combined, sorted and unique, so no worries of duplicated entries. After subdomain enumeration, the following stages are performed:
- Scan the Subdomains Using HTTPX and Save the Results Based on Status Code (2xx, 3xx, 4xx and 5xx)
- Fetch Wayback Machine Results for All of Live Subdomains
- Extract IP Addresses of Subdomains Using Nslookup
- Scan Top 25 Ports Using NMAP on Extracted IP Address List in Previous Stage

# Usage
Get the script, get all binary files of the tools (Amass, Subfinder, Assetfinder and HTTPX) and make sure all files are executable (use chmod +x command if necessary), and run the script:
```bash
./SubReveal.sh root_domains.txt
```  
Curl and jq packages must be installed in your linux, since they are used for communication with crt.sh.
There are mainly four output files. "subsraw_${date}" containing combination of findings by 5 stages (Amass Active, Amass Passive, Subfinder, Assetfinder, crt.sh). "subslive_${date}" contaning live subdomains determined by HTTPX (all status codes). "ipaddress_${date}" containing ip address of each subdomain (you might want to port scan etc). "waybackresults.txt" containing result of wayback machine for all live subdomains. There are also 4 text files for different status codes determined by HTTPX scan. For example, "4xx.txt" file contains all subdomains with 404,401,403 status codes etc.
All formats of NMAP results are also saved with this lable "nmapresults".
For subfinder tool that runs with "-all" flag, you need to provide a config.yaml file in the current working directory.
Feel free to change flag values for any of the tools.
# Notes
SubReveal is an automation of well known tools, and credits go to the creators of Amass, Subfinder, Assetfinder, Httpx and WaybackUrl.  
SubReveal executes the tools in this manner:
```bash
./tool [options]
```
Example:
```bash
./subfinder [options]
```
Therefore all of the executable files have to be in the current working directory and have execute permission.  
Feel free to share your ideas, or any bugs you encounter.
