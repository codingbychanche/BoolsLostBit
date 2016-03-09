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

mapx=20
mapy=20 

# Pos of the lost bit

bitx=2
bity=10

# Players inventory

water=5
fire=5

# Pos. of player on map 
#
# (W)est movement is realized by calling the 'increase' function
# (E)ast movement is realized by calling the 'decrease' function
# (N)orth movement is realized by: scene=scene-100
# (S)outh movement is realized by: scene=scene+100 

roomx=8
roomy=8
let "roomnumber=$roomx*$roomxy"

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
# Next screen (go west)
#

increase()
{
    calcbits
    let "temp=bit1^bit2^bit3^bit8"
    let "scene=255&((scene<<1)|temp)"
    return
}

#
# Previous screen (go east)
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
    fire=3
    
    clue=8

    # Exit switch
    # 0 indicates: No exit
    # 1 indicates: Exit available
    # 
    # These vars are used within the move routine to decide if 
    # move is alllowed

    dw=0
    de=0
    ds=0
    dn=0
    dl=0

    # Decode exits
    # North?

    echo Vissible exits are:
    let "d=$north&$scene"
    if [ $d -eq $north ]
    then
	echo North
	dn=1
    fi
    
    # South?

    let "d=$south&$scene"
    if [ $d -eq $south ]
    then
	echo South
	ds=1
    fi

    # West?

    let "d=$west&$scene"
    if [ $d -eq $west ]
    then
	echo West
	dw=1
    fi
    
    # East?

    let "d=$east&$scene"
    if [ $d -eq $east ]
    then
	echo East
	de=1
    fi

    # Ladder?

    let "d=$ladder&$scene"
    if [ $d -eq $ladder ]
    then
	echo There is a pit with a ladder
	dl=1
    fi

    # If the room has no exits, then build one to prevent the player
    # from running into deathends

    let "exits=$dn+$ds+$de+$dw+$dl"
    if [ $exits -eq 0 ]
    then	
	echo Found a hidden path running from north to south
	dn=1
	ds=1
    fi

    # Landscape

    let "d=$lake&$scene"
    if [ $d -eq $lake ]
    then
	echo I can see a lake. Water reffiled!
	water=5
    fi

    let "d=$fire&$scene"
    if [ $d -eq $fire ]
    then
	echo I can see a fireplace. Your torch burns brightly again!
	fire=5
    fi

    # A clue?

    let "d=$clue&$scene"
    if [ $d -eq $clue ]
    then
	echo A secret scroll is here. It is written that the lost bit is 
	
	let "dx=$roomx-$bitx"
	if [ $dx -lt 0 ]
	then
	    let "dx=dx * - 1"
	fi

	let "dy=$roomy-$bity"
	if [ $dy -lt 0 ]
	then
	    let "dy=dy * - 1"
	fi

	if [ $dx -lt 0 ]
	then 
	    dvx=east
	else
	    dvx=west
	fi

	if [ $dy -lt 0 ]
	then 
	    dvy=south
	else
	    dvy=north
	fi
   
	echo $dx steps $dvx from here and $dy steps $dvy of here
	echo Good luck!
    fi

    # Inventory

    echo Water: $water
    if [ $water -lt 3 ]
    then 
	echo You are thirsty
    fi

    echo Torch: $fire
    if [ $fire -lt 3 ]
    then
	echo Your torch seems to fade........
    fi

    
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
echo In this game you seek Bools lost bit which is hidden somewere on an $mapx x $mapy map
echo The upper left  map- square is room 0, located at 0/0
echo The lower right map- square is the last room located at $mapx/$mapy
echo Below the map is a dungeon which. You can access the dungeon through the pits 
echo
echo You, the brave player start at location $roomx/$roomy
echo
echo You move by telling me the desired direction which is either north or south, west or east 
echo If you can see a pit you can go up or down. Use the first letter of the direction you want to
echo travel: n,s,e,w,u or d
echo
echo To get a description of your room you can type: l
echo

# Descripe start room

descripe

##############################
# Main loop
#
# Player movement
##############################

while [ 1 ]
do
   
    # Lost bit found?
    
    if [ $roomx -eq $bitx ] && [ $roomy -eq $bity ] 
    then
	echo 
	echo Congratulations! You found the lost bit
	echo
	
	break
    fi
   
    # Prompt
    
    echo --------------Which way n/s/e/w ?
    read dir

    # Move
    
    # West look?

    if [ $dir = "l" ] 
    then
	echo Examining......
	descripe
    fi

    # West ok?

    if [ $dir = "w" ] 
    then
	if [ $roomx -gt 0 ]
	then
	    if [ $dw -eq 1 ] 
	    then
	    increase
	    let "roomx=roomx-1"
	    descripe
	    else
		echo West is blocked!
	    fi	
	fi
    fi
    
    # East ok?
    
    if [ $dir = "e" ] 
    then
	if [ $roomx -lt $mapx ]
	then
	    if [ $de -eq 1 ]
	    then
		decrease
		let "roomx=roomx+1"
		descripe
	    else
		echo East is blocked
	    fi
        fi
    fi
    
    # North ok?
    
    if [ $dir = "n" ] 
    then
	if [ $roomy -gt 0 ]
	then
	    if [ $dn -eq 1 ]
	    then
		let "scene=scene-1"
		let "roomy=roomy-1"
		descripe
	    else
		echo North is blocked!
	    fi
	fi	
     
    fi
    
    # South ok?
    
    if [ $dir = "s" ] 
    then
	if [ $roomy -lt $mapy ]
	then
	    if  [ $ds -eq 1 ]
	    then
		let "scene=scene+1"
		let "roomy=roomy+1"
		descripe
	    else
		echo South is blocked!
	    fi
	fi
    fi

    # Check inventory

    if [ $fire -ge 0 ]
    then
	let "fire=fire-1"
    fi

    if [ $water -gt 0 ]
    then
	let "water=water-1"
    else
	echo You run out of water! You are death! The lost bit is lost forever....
	break
    fi
done


    






