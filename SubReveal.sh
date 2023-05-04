#!/bin/bash

echo "                   ****************************************"
echo "                   ****************************************"
echo "                   ****************************************"
echo "                            ## S u b R e v e a l ##"
echo "                   ****************************************"
echo "                   ****************************************"
echo "                   ****************************************"
sleep 1
echo "Starting to reveal subdomains..."
sleep 2

echo "First of all, let's do A Mass enumeration!"
./amass enum -df $1 -timeout 7 -silent -o subsRevealed-raw.txt
echo "Amass Done!"

echo "Let's run Subfinder to see if there are anything we missed!"
./subfinder -dL $1 -all -silent >> subsRevealed-raw.txt
echo "Subfinder Done!"

echo "Now we are going to do some magic with crt.sh..."
# Loop through each line of domains.txt
while read domain; do
# Run crt.sh with the domain as argument, parse the json to get subdomains, and append output to subsRevealed-raw.txt
curl -s "https://crt.sh/?q=${domain}&output=json" | jq -r ".[] | .name_value" >> subsRevealed-raw.txt
done < $1
echo "crt.sh Done!"

echo "Last but not least, lets run Tomnomnom's Assetfinder..."
while IFS= read -r domain; do
  # Scan subdomains using Assetfinder
  subdomain=$(./assetfinder --subs-only $domain)
  # Append subdomains to output file
  echo "$subdomain" >> subsRevealed-raw.txt
done < $1
echo "Assetfinder Done!"

# sort and deduplicate results
sort subsRevealed-raw.txt | uniq > tmp.txt
mv tmp.txt subsRevealed-raw.txt

echo "Let's see which subdomains are up..."
cat subsRevealed-raw.txt | ./httprobe -c 25 --prefer-https > subsRevealed-live.txt 
echo "Revealed subs are written to subsRevealed-live.txt file, enjoy!"

# extract ip address related to each subdomain
# Loop through each line of subsRevealed-raw.txt
echo "We will now extract as many IP Addresses as we can!"
while IFS= read -r domain; do
  ips=$(nslookup -type=A "$domain" | awk '/^Address: / {print $2}')
  echo "$ips" >> ip-address.txt
done < subsRevealed-raw.txt
echo "IP Addresses are ready! Take Care!"
# sort, deduplicate and remove any empty lines (including first line) of ip addresses file
sort ip-address.txt | uniq | sed '/^$/d' > temp.txt
mv temp.txt ip-address.txt
