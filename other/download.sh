URL='https://w3layouts.com/page/'
preURL='https://w3layouts.com'
temp=.`echo -n temp | sha512sum`
list=.`echo -n list | sha512sum`
current=.`echo -n current | sha512sum`
testFile=.`echo -n testFile | sha512sum`
curl -L --user-agent 'Mozilla/5.0 (X11; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0' "https://w3layouts.com/" > "$temp".html 
totalPages=`cat "$temp".html  | grep page | grep Last | grep -o "Page 1 of [0-9]*" | rev | cut -d " " -f1  | rev`
echo 'From which page do you want to start'
read start
for i in `seq "$start" "$totalPages"`
do
	echo "Going for $URL$i"
	curl -L "$URL""$i" --user-agent 'Mozilla/5.0 (X11; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0' > "$temp".html 
	for j in ` cat "$temp".html  | grep -B 1 'https://w3layouts.com/wp-content/uploads/201' | egrep -o "href=\"[^\"]+"  | cut -d "\"" -f2`
	do
		echo "Downloading $j"
		curl -L  "$j" --user-agent 'Mozilla/5.0 (X11; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0'  >  "$testFile".html 
		postURL=`cat "$testFile".html  | grep 'Download Template' | egrep -o "href=\"[^\"]+"  | cut -d "\"" -f2`
		curl -L  "$preURL""$postURL" --user-agent 'Mozilla/5.0 (X11; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0' --referer "$j" > "$current".html 
		final=`cat "$current".html  | egrep -o "https://w3layouts.com/\?sdmon=download[^\"]+true" | sort | uniq  | head -1`
		name=`echo "$final" | grep -o downloads.*zip | cut -d "/" -f2`
		curl -L  "$final" --user-agent 'Mozilla/5.0 (X11; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0' > "$name"
		echo "\"$name\" -- \"#final\"" "page number " "$i" "$j" >> "$list"
		echo "Done for \"$name\""
	done
	echo "Completed page $i"
	# git add .
	# git commit -m 'Keep going'
	# git push newOne master
	# sleep 1
	# printf "\033c"
done