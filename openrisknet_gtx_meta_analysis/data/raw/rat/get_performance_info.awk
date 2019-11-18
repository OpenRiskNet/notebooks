
BEGIN{
    OFS=FS="	";
    OFMT="%.4g";
}; 
/Accuracy/{arr[$1][1]=$3*100;}; 
/Sensitivity/{arr[$1][2]=$3*100;}; 
/Specificity/{arr[$1][3]=$3*100}; 
{arr[$1][4]=$1;};
END{
    print("Algorithm	Accuracy	Sensitivity	Specificty"); 
    for( i in arr){print(arr[i][4],arr[i][1], arr[i][2], arr[i][3])}
};
