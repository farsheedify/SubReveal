#!/bin/bash

echo "
---------------------------------------
|                                     |
**********    SubReveal     ***********
|                       by Farsheedify|
---------------------------------------
	"
subsraw="subsraw_$(date +%Y-%m-%d).txt"
subslive="subslive_$(date +%Y-%m-%d)"
subslive_all_clean="subslive_all_clean_$(date +%Y-%m-%d).txt"
ipaddress="ipaddress_$(date +%Y-%m-%d).txt"
# Initialize variables to store the values of the flags
certspotter_token=""  # Optional: Stores the token provided with -t flag
list=""          # Mandatory: Stores the file path provided with -l flag
github_token_file=""    # Optional: GitHub token file

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -ct)  # Certspotter token flag
            if [[ -n $2 && $2 != -* ]]; then
                certspotter_token="$2"
                shift 2
            else
                echo "Error: -ct flag requires a valid token for CertSpotter."
                exit 1
            fi
            ;;
        -gt)  # GitHub token file flag
            if [[ -n $2 && $2 != -* ]]; then
                github_token_file="$2"
                shift 2
            else
                echo "Error: -gt flag requires a valid .token filename containing Github tokens."
                exit 1
            fi
            ;;
        -l)  # List file flag
            if [[ -n $2 && $2 != -* ]]; then
                list="$2"
                shift 2
            else
                echo "Error: -l flag requires a valid file containing root domains."
                exit 1
            fi
            ;;
        *)  # Handle unknown options
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Ensure the mandatory -l flag (list) is provided
if [[ -z $list ]]; then
    echo "Error: -l (list file) is required."
    exit 1  # Exit the script with an error code
fi

#cleaning the input
cat $list | tr -d '\r' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | grep -v '^[[:space:]]*$' > clean_list.txt

sleep 1
printf "%s : Starting to Reveal Subdomains...\n" "$(date --rfc-3339=seconds)"
sleep 2

printf "%s : Looking up Github first with github-subdomains...\n" "$(date --rfc-3339=seconds)"
while IFS= read -r domain; do
# Scan subdomains using github-subdomains
github-subdomains -d $domain -t ${github_token_file} >/dev/null 2>&1
# Append subdomains to output file
cat "$domain.txt" >> $subsraw
rm -rf "$domain.txt"
done < clean_list.txt
printf "%s : github-subdomains Done!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Now we are going to do some certificate magic with crt.sh, certspotter, and cero...\n" "$(date --rfc-3339=seconds)"
# Loop through each line of domains.txt
while read domain; do
# Run certspotter
curl -s -H "Authorization: Bearer ${certspotter_token}" "https://api.certspotter.com/v1/issuances?domain=${domain}&include_subdomains=true&expand=dns_names" | jq -r '.[].dns_names[]' | grep ${domain} | sort -u >> certspotter.txt
# Run crt.sh with the domain as argument, parse the json to get subdomains, and append output to subsRevealed-raw.txt
curl -s https://crt.sh/?Identity=%.${domain} | grep ">*.${domain}" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*${domain}" | sort -u | awk 'NF' >> crt.txt
done < clean_list.txt
# combining certificate analysis results
sort -u crt.txt certspotter.txt >> $subsraw && rm -rf crt.txt certspotter.txt
cat clean_list.txt | cero -d >> $subsraw
printf "%s : Cert Magic Done!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Let's cooldown for a couple of seconds before moving on.\n" "$(date --rfc-3339=seconds)"
sleep 10
printf "%s : Going to run Subfinder...\n" "$(date --rfc-3339=seconds)"
subfinder -dL clean_list.txt -duc -all -silent >> $subsraw
printf "%s : Subfinder Done!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Last but not least, lets run Tomnomnom's Assetfinder...\n" "$(date --rfc-3339=seconds)"
while IFS= read -r domain; do
  # Scan subdomains using Assetfinder
  subdomain=$(assetfinder --subs-only $domain)
  # Append subdomains to output file
  echo "$subdomain" >> $subsraw
done < clean_list.txt
printf "%s : Assetfinder Done!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Combining the results...\n" "$(date --rfc-3339=seconds)"
# sort and deduplicate results
sort $subsraw | uniq | sed '/^$/d' > tmp.txt
mv tmp.txt $subsraw
#remove the redundant clean_list file
rm -rf clean_list.txt

printf "%s : Let's see which subdomains are up, and take screenshots using httpx...\n" "$(date --rfc-3339=seconds)"
httpx -list $subsraw -screenshot -nc -t 10 -rl 25 -silent -cl -title -status-code -tech-detect -location -oa -o $subslive
printf "%s : Live subs and related information about them are written to subslive  file\n" "$(date --rfc-3339=seconds)"
awk '$2 ~ /\[2[0-9][0-9]\]/' $subslive  > 2xx.txt
awk '$2 ~ /\[3[0-9][0-9]\]/' $subslive  > 3xx.txt
awk '$2 ~ /\[4[0-9][0-9]\]/' $subslive  > 4xx.txt
awk '$2 ~ /\[5[0-9][0-9]\]/' $subslive  > 5xx.txt
cut -d' ' -f1 $subslive > $subslive_all_clean
sleep 1
printf "%s : All urls with different status codes separated...\n" "$(date --rfc-3339=seconds)"
sleep 1

# extract ip address related to each subdomain
# Loop through each line of subsRevealed-raw.txt
printf "%s : We will now extract as many IP Addresses as we can from the subdomains!\n" "$(date --rfc-3339=seconds)"
while IFS= read -r domain; do
  ips=$(nslookup -type=A "$domain" 2> /dev/null | awk '/^Address: / {print $2}')
  echo "$ips" >> $ipaddress
done < $subsraw
# sort, deduplicate and remove any empty lines (including first line) of ip addresses file
sort $ipaddress | uniq | sed '/^$/d' > temp.txt
mv temp.txt $ipaddress
printf "%s : That's it, IP addresses are ready!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Finally, let's do a passive portscan using Smap...\n" "$(date --rfc-3339=seconds)"
smap -iL $ipaddress -oS SmapResults
smap -iL $ipaddress -oA NmapResults
printf "%s : We are done.\nHack the Galaxy!" "$(date --rfc-3339=seconds)"
