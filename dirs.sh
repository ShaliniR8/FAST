for year in ./mitre/*
do
	for month in ${year}/*
	do
		for files in ${month}
		do
			rm -rf ${files}/*
		done
	done
done