#!/bin/bash
# https://stackoverflow.com/questions/45751117/bash-group-by-on-the-basis-of-n-number-of-columns

awk '
BEGIN { FS=OFS="|" }
{
    for(i=2;i<=NF;i++)                    # loop all data fields
        a[$1][i]+=$i                      # sum them up to related cells
    a[$1][1]=i                            # set field count to first cell
}
END {
    for(i in a) {
        for((j=2)&&b="";j<a[i][1];j++)    # buffer output
            b=b (b==""?"":OFS)a[i][j]
        print i,b                         # output
    }
}' /dev/stdin
