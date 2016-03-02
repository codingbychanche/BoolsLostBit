#/bin/bash
#
# 2D Map generator.
# This generates an world map based on an 8 Bit LFSR.
# The algorithms are based on the technique used in the game 
# 'Pitfall 1'
#
# An in depth discusion about the LFSR used can be found at:
# http://meatfighter.com/pitfall/
#
# Translated to bash- shell by Berthold Fritz 2/2016

# This var stores all map squares within it's first 8 Bit

scene=2

# Map is 10x10 squares

mapx=10
mapy=10 

# Pos of the lost bit

bitx=2
bity=10

# Pos. of player on map 
#
# (W)est movement is realized by calling the 'increase' function
# (E)ast movement is realized by calling the 'decrease' function
# (N)orth movement is realized by: scene=scene-100
# (S)outh movement is realized by: scene=scene+100 

roomx=8
roomy=8

# Calc binary value of 'scene'
# Call this function before you do in-/ or decrease

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
    calcbits
    let "temp=bit1^bit2^bit3^bit8"
    let "scene=255&((scene<<1)|temp)"
    return
}

#
# Previous screen
#

decrease ()
{
    calcbits
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
# Descripe room
#

descripe()
{
    let "roomnumber=$roomx*$roomy"
    
    echo
    echo
    echo You are in room x/y $roomx/$roomy room number:$roomnumber 
    echo Your room looks like:$scene

    # 'scene', first 8- Bits:
    #
    # MSB  LSB
    #
    # -----000 Exits/ landscape
    #
    #      001 North
    #      010 South
    #      100 West
    #      110 East
    #      111 Ladder down/up
    #      101 Lake
    #      011 Stream
    #
    # ----0--- Clue
    #      
    #     0    No clue
    #     1    Clue  
    #

    north=1
    south=2
    west=4
    east=6
    ladder=7
    lake=5
    stream=3
    
    clue=8

    # Decode exits
    # North?

    echo Vissible exits are:
    let "d=$north&$scene"
    if [ $d -eq $north ]
    then
	echo North
    fi
    
    # South?

    let "d=$south&$scene"
    if [ $d -eq $south ]
    then
	echo South
    fi

    # West?

    let "d=$west&$scene"
    if [ $d -eq $west ]
    then
	echo West
    fi
    
    # East?

    let "d=$east&$scene"
    if [ $d -eq $east ]
    then
	echo South
    fi

    # Ladder?

    let "d=$ladder&$scene"
    if [ $d -eq $ladder ]
    then
	echo There is a pit with a ladder
    fi

    # Landscape

    let "d=$lake&$scene"
    if [ $d -eq $lake ]
    then
	echo I can see a lake
    fi

    let "d=$stream&$scene"
    if [ $d -eq $stream ]
    then
	echo I can see a stream
    fi

    # A clue?

    let "d=$clue&$scene"
    if [ $d -eq $clue ]
    then
	echo A secret scroll is here. It is written that the lost bit is 
	let "dx=$roomx-$bitx"
	let "dy=$roomy-$bity"
	echo $dx x Dir    $dy Dir
    fi
    
    # Prompt

    echo Which way n/s/e/w ?
    read dir
}

# Start Screen

echo
echo
echo
echo Welcome to: 
echo 
echo ----------- XOR- Dungeon, the Revenge of Bool -------------
echo
echo Version 1.0 // 2.3.2016 // Berthold Fritz aka. RetroZock
echo
echo In this game you seek bools lost bit which is hidden somewere on an $mapx x $mapy map
echo The upper left  map- square is room 0, located at 0/0
echo The lower right map- square is the last room located at $mapx/$mapy
echo Below the map is a dungeon which. You can access the through pits 
echo
echo You, the brave player start at location $roomx/$roomy
echo
echo You move by telling me the desiered direction which is either north or south, west or east 
echo If you can see a pit you can go up or down. Use the first letter of the direction you want to
echo travel: n,s,e,w,u or d
echo
echo In the dungeon you move two rooms at a time

##############################
# Main loop
#
# Player movement
##############################

while [ 1 ]
do    
    descripe

    if [ $dir == "w" ] 
    then
	if [ $roomx -gt 0 ]
	then
		increase
		let "roomx=roomx-1"
	fi
    fi
    
    if [ $dir == "e" ]
    then
	if [ $roomx -lt $mapx ]
	then
		decrease
		let "roomx=roomx+1"
	fi
    fi

    if [ $dir == "n" ]
    then
	if [ $roomy -gt 0 ]
	then
	    let "scene=scene-1"
	    let "roomy=roomy-1"
	fi
    fi

    if [ $dir == "s" ]
    then
	if [ $roomy -lt $mapy ]
	then
	    let "scene=scene+1"
	    let "roomy=roomy+1"
	fi
    fi
done


    






