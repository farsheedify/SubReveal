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

sleep 1
printf "%s : Starting to Reveal Subdomains...\n" "$(date --rfc-3339=seconds)"
sleep 2

printf "%s : Let's run Subfinder First...\n" "$(date --rfc-3339=seconds)"
subfinder -dL $1 -all -config config.yaml -silent >> $subsraw
printf "%s : Subfinder Done!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Now we are going to do some certificate magic with crt.sh, certspotter, and cero...\n" "$(date --rfc-3339=seconds)"
# Loop through each line of domains.txt
while read domain; do
domain=$(echo "$domain" | tr -d '[:space:]') # Trim white spaces
# Run certspotter
curl -s -H "Authorization: Bearer k55404_f91UEMe6pTQZq882c8Vy" "https://api.certspotter.com/v1/issuances?domain=${domain}&include_subdomains=true&expand=dns_names" | jq -r '.[].dns_names[]' | grep ${domain} | sort -u >> certspotter.txt
# Run crt.sh with the domain as argument, parse the json to get subdomains, and append output to subsRevealed-raw.txt
curl -s https://crt.sh/?Identity=%.${domain} | grep ">*.${domain}" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*${domain}" | sort -u | awk 'NF' >> crt.txt
done < $1
# combining certificate analysis results
sort -u crt.txt certspotter.txt >> $subsraw && rm -rf crt.txt certspotter.txt
cat $1 | cero -d >> $subsraw
printf "%s : Cert Magic Done!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Starting github-subdomains...\n" "$(date --rfc-3339=seconds)"
while IFS= read -r domain; do
# Scan subdomains using github-subdomains
github-subdomains -d $domain -t github.tokens >/dev/null 2>&1
# Append subdomains to output file
cat "$domain.txt" >> $subsraw
rm -rf "$domain.txt"
done < $1
printf "%s : github-subdomains Done!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Last but not least, lets run Tomnomnom's Assetfinder...\n" "$(date --rfc-3339=seconds)"
while IFS= read -r domain; do
  # Scan subdomains using Assetfinder
  subdomain=$(assetfinder --subs-only $domain)
  # Append subdomains to output file
  echo "$subdomain" >> $subsraw
done < $1
printf "%s : Assetfinder Done!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Combining the results...\n" "$(date --rfc-3339=seconds)"
# sort and deduplicate results
sort $subsraw | uniq | sed '/^$/d' > tmp.txt
mv tmp.txt $subsraw

printf "%s : Let's see which subdomains are up using httpx...\n" "$(date --rfc-3339=seconds)"
httpx -l $subsraw -nc -t 10 -rl 25 -silent -title -status-code -tech-detect -location -oa -o $subslive
printf "%s : Live subs and related information about them are written to subslive  file\n" "$(date --rfc-3339=seconds)"
awk '$2 ~ /\[2[0-9][0-9]\]/' $subslive  > 2xx.txt
awk '$2 ~ /\[3[0-9][0-9]\]/' $subslive  > 3xx.txt
awk '$2 ~ /\[4[0-9][0-9]\]/' $subslive  > 4xx.txt
awk '$2 ~ /\[5[0-9][0-9]\]/' $subslive  > 5xx.txt
cut -d' ' -f1 $subslive > $subslive_all_clean
printf "%s : all urls with different status codes separated...\n" "$(date --rfc-3339=seconds)"
sleep 1

# take screenshot of live subdomains with gowitness
printf "%s : Finally, let's take the screenshot of the live subdomains, just in case!\n" "$(date --rfc-3339=seconds)"
gowitness file -f $subslive_all_clean > /dev/null

# extract ip address related to each subdomain
# Loop through each line of subsRevealed-raw.txt
printf "%s : We will now extract as many IP Addresses as we can!\n" "$(date --rfc-3339=seconds)"
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