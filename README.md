# SubReveal

SubReveal is an automation pipeline for passive subdomain discovery. It processes a text file containing one or more root domains and performs the following stages to discover and consolidate subdomains:

## Subdomain Enumeration Stages

- **Github-subdomains Scan**
- **Certspotter Subdomain Retrieval**
- **Crt.sh Subdomain Retrieval**
- **Cero Scan**
- **Subfinder Scan**
- **Assetfinder Scan**

The results are combined, sorted, and deduplicated to ensure unique entries. Following subdomain enumeration, SubReveal executes these additional stages:

## Post-Enumeration Stages

- **HTTPX Scan**: Scans subdomains, captures screenshots and categorizes results based on status codes (2xx, 3xx, 4xx, 5xx).
- **NSlookup IP Extraction**: Extracts IP addresses of subdomains.
- **Smap Passive Scanning**: Passively scans the discovered IP addresses.

---

## Usage

To use SubReveal, pass a text file containing the root domains to the script using the `-l` flag and run it:
```bash
./SubReveal.sh -l roots.txt
```
---

## Configuration

- **Certspotter API Token**: For the Certspotter subdomain retrieval stage, ensure you provide a valid API token using the `-ct` flag.
- **GitHub Token File**: For the `github-subdomains` tool, provide a `.token` file using the `-gt` flag.
- **Subfinder Configuration**: Update the `provider-config.yaml` file in Subfinder's default configuration path to include API tokens for various services. This ensures Subfinder operates with full functionality.

Example usage providing necessary inputs:
```bash
./SubReveal.sh -l roots.txt -ct k11249_8zs380AYyTkJFvIS4wjZ -gt github.token
```

---

## Notes

SubReveal automates the use of several well-known tools. Interestingly, running different tools at different times can yield varying results. Therefore, it is highly beneficial to run all of them, and perhaps even multiple times! 

Full credit goes to the creators of Subfinder, Assetfinder, HTTPX, Github-subdomains, and Smap.

I welcome your ideas and feedback and encourage you to report any bugs you encounter.
