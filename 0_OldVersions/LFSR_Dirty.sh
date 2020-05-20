#!/bin/bash
#
# This is the first test of an LFSR- register.
# it generates 9 pseudo random numbers.
#

a=5

# This delivers 8 (seemingly) random numbers.
# If the sequence is called 9 times the numbers repeat

advance()
{
    
    let "a=a&255"
    let "preva=a"    
    let "temp=a"
    let "carry=a&128"
    let "a=a<<1"

    let "a=a^temp"
    echo $a
}

# This reverses the 'advance' sequnce
# Works only for the last number in abn sequence

goback()
{
    let "a=a^preva"
    let "a=a>>1"
    let "a=a|carry"
    echo $a
}


advance
advance
goback
goback





