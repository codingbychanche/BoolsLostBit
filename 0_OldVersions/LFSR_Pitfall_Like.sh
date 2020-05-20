#/bin/bash
#
# Pitfall 1 map generator.
#
# An in depth discusion about the LFSR used can be find at:
# http://meatfighter.com/pitfall/
#
# Translated to bash- shell by Berthold Fritz 2/2016

scene=196

calcbits()
{
    let "bit1=(scene & 1)/1"
    let "bit2=(scene & 2)/2"
    let "bit3=(scene & 4)/4"
    let "bit4=(scene & 8)/8"
    let "bit5=(scene & 16)/16"
    let "bit6=(scene & 32)/32"
    let "bit7=(scene & 64)/64"
    let "bit8=(scene & 128)/128"
    return
}

#
# Next screen
#

increase()
{
    let "temp=bit1^bit2^bit3^bit8"
    let "scene=255&((scene<<1)|temp)"
    return
}

#
# Previous screen
#

decrease ()
{
    let "temp=bit2^bit3^bit4^bit1"
    let "temp=temp<<7"
    let "scene=255&((scene>>1)|temp)"
    return
}

#
# Show start conditions
#

    calcbits
    echo $bit8 $bit7 $bit6 $bit5 $bit4 $bit3 $bit2 $bit1
    echo $scene

#
# Show first 14 screens
#
# The value calculated here for 'screen' is pseudo random.
# 

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14
do
    calcbits
    increase
    echo $scene
done

echo --------------------

#
# Prove that the above shown sequence for the first 14 screens
# can be reversed
#

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14
do
    calcbits
    decrease
    echo $scene
done

  









