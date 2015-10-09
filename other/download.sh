URL='https://w3layouts.com/page/'
preURL='https://w3layouts.com'
temp=.`echo -n temp | sha512sum`
list=.`echo -n list | sha512sum`
current=.`echo -n current | sha512sum`
testFile=.`echo -n testFile | sha512sum`
wget --quiet -O "$temp".html "https://w3layouts.com/"
totalPages=`cat "$temp".html  | grep page | grep Last | grep -o "Page 1 of [0-9]*" | rev | cut -d " " -f1  | rev`
echo 'From which page do you want to start'
read start
for i in `seq "$start" "$totalPages"`
do
	echo "Going for $URL$i"
	wget --quiet -O "$temp".html "$URL""$i" --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0'
	for j in ` cat "$temp".html  | grep -B 1 'https://w3layouts.com/wp-content/uploads/2015' | egrep -o "href=\"[^\"]+"  | cut -d "\"" -f2`
	do
		echo "Downloading $j"
		wget --quiet -O "$testFile".html "$j"	--user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0'
		postURL=`cat "$testFile".html  | grep 'Download Template' | egrep -o "href=\"[^\"]+"  | cut -d "\"" -f2`
		wget --quiet -O "$current".html "$preURL""$postURL" --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0' --referer="$j"
		final=`cat "$current".html  | egrep -o "https://w3layouts.com/\?sdmon=download[^\"]+true" | sort | uniq  | head -1`
		name=`echo "$final" | grep -o downloads.*zip | cut -d "/" -f2`
		wget --quiet -O "$name" "$final" --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0'
		echo "\"$name\" -- \"#final\"" "page number " "$i" "$j" >> "$list"
		echo "Done for \"$name\""
	done
	echo "Completed page $i"
	git add .
	git commit -m 'Keep going'
	git push newOne master
	sleep 1
	printf "\033c"
done