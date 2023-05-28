#!/bin/bash

echo "
---------------------------------------
|                                     |
***********    SubReveal    ***********
|                           by tRoNsEc|
---------------------------------------
	"
subsraw="subsraw_$(date +%Y-%m-%d).txt"
subslive="subslive_$(date +%Y-%m-%d).txt"
ipaddress="ipaddress_$(date +%Y-%m-%d).txt"

sleep 1
printf "%s : Starting to Reveal Subdomains...\n" "$(date --rfc-3339=seconds)"
sleep 2

printf "%s : First of all, let's do A Mass enumeration!\n" "$(date --rfc-3339=seconds)"
./amass enum -passive -df $1 -timeout 30 -dns-qps 50 -silent -o amassP.txt
./amass enum -active -df $1 -timeout 60 -dns-qps 50 -silent -o amassA.txt
sort -u amassP.txt amassA.txt > $subsraw && rm -rf amassP.txt amassA.txt
printf "%s : Amass Done!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Let's run Subfinder to see if there are anything we missed\n" "$(date --rfc-3339=seconds)"
./subfinder -dL $1 -all -config config.yaml -silent >> $subsraw
printf "%s : Subfinder Done!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Now we are going to do some magic with crt.sh...\n" "$(date --rfc-3339=seconds)"
# Loop through each line of domains.txt
while read domain; do
domain=$(echo "$domain" | tr -d '[:space:]') # Trim white spaces
# Run crt.sh with the domain as argument, parse the json to get subdomains, and append output to subsRevealed-raw.txt
curl -s "https://crt.sh/?q=${domain}&output=json" | jq -r ".[] | .name_value" >> $subsraw 2> /dev/null
done < $1
printf "%s : crt.sh Done!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Last but not least, lets run Tomnomnom's Assetfinder...\n" "$(date --rfc-3339=seconds)"
while IFS= read -r domain; do
  # Scan subdomains using Assetfinder
  subdomain=$(./assetfinder --subs-only $domain)
  # Append subdomains to output file
  echo "$subdomain" >> $subsraw
done < $1
printf "%s : Assetfinder Done!\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Combining the results in subsRevealed-raw.txt file...\n" "$(date --rfc-3339=seconds)"
# sort and deduplicate results
sort $subsraw | uniq > tmp.txt
mv tmp.txt $subsraw

printf "%s : Let's see which subdomains are up...\n" "$(date --rfc-3339=seconds)"
./httpx -l $subsraw -nc -t 10 -rl 25 -silent -title -status-code -tech-detect -location > $subslive 
printf "%s : Live subs and related information about them are written to subslive  file\n" "$(date --rfc-3339=seconds)"
awk '$2 ~ /\[2[0-9][0-9]\]/' $subslive  > 2xx.txt
awk '$2 ~ /\[3[0-9][0-9]\]/' $subslive  > 3xx.txt
awk '$2 ~ /\[4[0-9][0-9]\]/' $subslive  > 4xx.txt
awk '$2 ~ /\[5[0-9][0-9]\]/' $subslive  > 5xx.txt
printf "%s : all urls with different status codes separated...\n" "$(date --rfc-3339=seconds)"
sleep 1

printf "%s : Fetching urls for live subdomains from WayBackMachine\n" "$(date --rfc-3339=seconds)"
cut -d' ' -f1 $subslive | ./waybackurls > waybackresults.txt
printf "%s : Waybackurl results are ready!\n" "$(date --rfc-3339=seconds)"
sleep 1

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

printf "%s : We are going to scan for top 25 open ports and possible services with NMAP!\n" "$(date --rfc-3339=seconds)"
nmap -sV -sC --top-ports 25 -iL $ipaddress -oA nmapresults
printf "%s : NMAP Done!\n" "$(date --rfc-3339=seconds)"
