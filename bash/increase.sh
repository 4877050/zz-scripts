index=0
for ((index=0; index<25; ));
do  
    modIndex=$((index % 4 + 1))
    echo "modIndex = $modIndex    ----  index = $index"
    ((index=$index+1))
done
