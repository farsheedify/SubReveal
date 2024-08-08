# SubReveal
SubReveal is an all-in-one, passive subdomain enumeration package for lazy hackers. It processes a text file containing one or more root domains and performs the following stages to discover and consolidate subdomains:

Subdomain Enumeration Stages

•  Subfinder Scan

•  Certspotter Subdomain Retrieval

•  Crt.sh Subdomain Retrieval

•  Cero Scan

•  Github-subdomains Scan

•  Assetfinder Scan

The results are combined, sorted, and deduplicated to ensure unique entries. Following subdomain enumeration, SubReveal executes these additional stages:

Post-Enumeration Stages

•  HTTPX Scan: Scans subdomains and categorizes results based on status codes (2xx, 3xx, 4xx, 5xx).

•  Gowitness Screenshots: Captures screenshots of live webpages.

•  NSlookup IP Extraction: Extracts IP addresses of subdomains.

•  Smap Passive Scanning: Passively scans the discovered IP addresses.

# Usage
To use SubReveal, pass the text file containing the root domains to the script and run it:
```bash
./SubReveal.sh root_domains.txt
```
Additional Requirements

•  Certspotter API Token: Provide a valid API token and replace {YOUR_CERTSPOTTER_TOKEN} in the 29th line of the code.

•  Subfinder Configuration: Ensure a config.yaml file is present in the current working directory for the Subfinder tool running with the -all flag.

Feel free to adjust the flag values for any of the tools as needed.

# Notes
SubReveal automates the use of several well-known tools. Interestingly, running different tools at different times can yield varying results. Therefore, it is highly beneficial to run all of them, and perhaps even multiple times! Full credit goes to the creators of Subfinder, Assetfinder, HTTPX, Gowitness, Github-subdomains, and Smap.

I welcome your ideas and feedback, and encourage you to report any bugs you encounter.
