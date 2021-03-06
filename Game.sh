#!/bin/bash
#
# Bools Lost Bit V1.0
#
# A clasical adventure game where you have to find a mystical
# hidden object featuring a 2- level 2d map which is generated 
# from the players name.
#
# The algorithms are based on the technique used in the game 
# 'Pitfall 1'
#
# An in depth discusion about the LFSR used can be found at:
# http://meatfighter.com/pitfall/
#
# Needs Java(TM) SE Runtime Environment (build 1.8.0_66-b17) for:
# o Calculating a 8- bit hash value from the dungeon masters name (see line 540)
#
# Berthold Fritz 11/2016
# Version: In your shell type "git log" for a detailed change- log and version information.

# Map size

mapx=20
mapy=20 

# Players inventory

water=10
torch=5

# Step counter

steps=0

# Pre init prompt

dir="n"

# Pos. of player on map 
#
# (W)est movement is realized by calling the 'increase' function
# (E)ast movement is realized by calling the 'decrease' function
# (N)orth movement is realized by: scene=scene-100
# (S)outh movement is realized by: scene=scene+100 

level=0  # 0=Wilderness // 1=Dungeon
roomx=8
roomy=8

let "$roomnumber=$roomx*$roomxy"

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

gameends()
{
    echo The adventure ends here brave $avatar
    
    break
}


#
# Player movement on map
#
# This is achieved by shifting the LFSR.
# For left (West) and right (East) movement the LFSR is shifted once 
# either to the left ('<<') or to the right ('>>')
#
# For up (North) or down (South) movement we have to shift the LFSR
# multiple times to the left or to the right. Number of shifts equals
# the # of rows of the map.
#
# For up and down movement (entering and leaving a dungeon) the LFSR 
# is shifted equal to the map size (e.g. 10 x 10 map = 100 times).
# The result is a new map sized (in this example size=10 x 10).
# Remember: Map size is deffined by the 'mapx' and 'mapy' vars.
#

#
# Go west
#

increase()
{
    calcbits
    let "temp=bit1^bit2^bit3^bit8"
    let "scene=255&((scene<<1)|temp)"
    return
}

#
# Previous screen Go east
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
# Go north
#

north()
{
    c=0
    while [ $c -lt $mapx ]
    do 
	calcbits
	let "temp=bit1^bit2^bit3^bit8"
	let "scene=255&((scene<<1)|temp)"
	let "c=c+1"
    done
    return
}

#
# Go south
#

south()
{
    c=0
    while [ $c -lt $mapx ]
    do 
	calcbits
	let "temp=bit2^bit3^bit4^bit1"
	let "temp=temp<<7"
	let "scene=255&((scene>>1)|temp)"
	let "c=c+1"
    done
    return
}

#
# Down
#

down()
{
    c=0
    let "mapsize=$mapx*$mapy"
    while [ $c -lt $mapsize ]
    do 
	calcbits
	let "temp=bit1^bit2^bit3^bit8"
	let "scene=255&((scene<<1)|temp)"
	let "c=c+1"
    done
    return
}

#
# UP
#

up()
{
    c=0
    let "mapsize=$mapx*$mapy"
    while [ $c -lt $mapsize ]
    do 
	calcbits
	let "temp=bit2^bit3^bit4^bit1"
	let "temp=temp<<7"
	let "scene=255&((scene>>1)|temp)"
	let "c=c+1"
    done
    return
}

#
# Descripe room
#

descripe()
{
    let "roomnumber=$roomx*$roomy"
    if [ $level -eq 0 ]
    then
	landscape=Wilderness
    else
	landscape=Dungeon
    fi

    echo
    echo
    printf "\ec"   # Clear terminal window
    printf "\e[7m" # Inv
    
    #
    # Check if player has run over the edges of the known world
    #

    if [ $roomx -gt 0 ] && [ $roomy -gt 0 ]
    then
	printf "******* You are in room x/y $roomx/$roomy\troom number:$roomnumber\tSteps made:$steps                 $landscape ******* \n"
    else
	if [ $level -eq 0 ]
	then
	    printf "******* You are lost in the forest\tSteps made:$steps\t                 $landscape ******* \n"
	else
	    printf "******* You are lost in the Dungeon\tSteps made:$steps\t                $landscape ******* \n"
    
	fi
    fi
    
    printf "\e[m" # Reset all escapes
    # echo Your room looks like:$scene

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
    # ---0---- Trap
    #   
    #     0    No trap
    #     1    Trap
    #
    # --1----  In an forest
    #
    #     0    Ouitside
    #     1    Inside

    north=1
    south=2
    west=4
    east=6
    ladder=7
    lake=5
    fire=3
    
    clue=8

    # Trap = 16(trap)+32(forest)
    # Traps are only in dark forests!

    trap=48    
    forest=32

    # Exit switch
    # 0 indicates: No exit
    # 1 indicates: Exit available
    # 
    # These vars are used within the move routine to decide if 
    # a move is alllowed

    dw=0
    de=0
    ds=0
    dn=0
    dd=0 # Down/ up movement possible?

    # Decode exits
    # Check current room

    # North?

    let "d=$north&$scene"
    if [ $d -eq $north ]                   # Map allows exit north!
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
	dd=1
    fi

    # If the room has no exits or only one, then build one to prevent the player
    # from running into deathends

    let "exits=$dn+$ds+$de+$dw+$dd"
    if [ $exits -eq 0 ]
    then	
	echo Found a hidden path running from north to south
	dn=1
	ds=1
    fi

    let "exits=$dn+$ds+$de+$dw+$dd"
    if [ $exits -lt 2 ]
    then	
	echo Found a hidden path running from east to west
	de=1
	dw=1
    fi

    # Check if we are in the wilderness
    # Room description differs between wilderness and dungeon level

    if [ $level -eq 0 ]
    then
	
       # Landscape

	let "d=$lake&$scene"
	if [ $d -eq $lake ]
	then
	    echo I can see a lake. Water reffiled!
	    water=10
	fi
	
	let "d=$fire&$scene"
	if [ $d -eq $fire ]
	then
	    echo I can see a fireplace. Your torch burns brightly again!
	    torch=5
	fi
	
        # Forest
	
	let "d=$forest&$scene"
	if [ $d -eq $forest ]
	then
	    if [ $torch -gt 0 ]
	    then
		echo You are in a small forest. The path is only dimly lit. At least your torch provides some light.
	    fi
	    
	    if [ $torch -eq 0 ]
	    then
		echo You are in an dark forest. You can barely see the path. be carefull! You might not see traps hidden in the dark!
	    fi
	fi
	
       # Trap?
       # Traps are only in forests
	
	let "d=$trap&$scene"
	if [ $d -eq $trap ]
	then
	    if [ $torch -gt 0 ]
	    then
		echo You see a trap. You are lucky that your torch still burns! You could not have
		echo seen it in the dark.
	    fi
	    
	    if [ $torch -eq 0 ]
	    then
		echo You run into a trap you could not see in the dark. You are death! The lost bit is lost forever
		break
	    fi
	fi
	
        # A clue?
	
	let "d=$clue&$scene"
	if [ $d -eq $clue ]
	then
	    
	    # Do not display message when player got lost in the wilderness

	    if [ $roomx -gt 0 ] && [ $roomy -gt 0 ]
	    then
		echo A secret scroll is here. It is written that the lost bit is 
	    
		let "dx=$roomx-$bitx"
				
	   
		let "dy=$roomy-$bity"
		
		
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

		if [ $dx -lt 0 ]
		then
		    let "dx=dx * - 1"
		fi

		if [ $dy -lt 0 ]
		then
		    let "dy=dy * - 1"
		fi

		echo $dx steps $dvx from here and $dy steps $dvy of here
		echo Good luck!
	    fi
	fi
    fi # End of Wilderness descrpition

    # Dungeon?

    if [ $level -eq 1 ]
    then
	let "d=$fire&$scene"
	if [ $d -eq $fire ]
	then
	    echo I can see a lantern. You light your torch. It burns brightly again
	    torch=5
	fi
	
	# I  the dungeon you need a torch to see!

	if [ $torch -gt 0 ]
	then
	    let "d=$lake&$scene"
	    if [ $d -eq $lake ]
	    then
		echo I can see water running down the wall. Water reffiled!
		water=10
	    fi
	    

	    let "d=$clue&$scene"
	    if [ $d -eq $clue ]
	    then
		echo You can hear footsteps! Seems someone very big and heavy follows you!
	    fi
	else
	    echo It is to dark to see anything. Better light your torch!
	fi

    fi # End of dungeon description
	
    # Inventory

    echo Water: $water
    if [ $water -lt 3 ]
    then 
	echo You are thirsty
    fi

    echo Torch: $torch
    if [ $torch -lt 3 ]
    then
	echo Your torch seems to fade........
    fi

    
}

# Start Screen

printf "\ec"      # Clear terminal window
echo Welcome to: 
echo 
printf "\e[32m"   # Green text
echo ----------- Bools Lost Bit ----------
printf "\e[m" # Reset all escapes
echo
echo Version 1.0 // 26.11.2016 // Berthold Fritz aka. RetroZock
echo

echo In this game you seek Bools lost bit which is hidden somewere on an $mapx x $mapy map
echo The upper left  map- square is room 0, located at 0/0
echo The lower right map- square is the last room located at $mapx/$mapy
echo Below the map is a dungeon which can be accessed through pits you will find once in a while 
echo
echo You, the brave player start at location $roomx/$roomy
echo
echo You move by telling me the desiered direction which is either north or south, west or east 
echo If you can see a pit you can go up or down. Use the first letter of the direction you want to
echo travel: n,s,e,w,u or d
echo
echo To get a description of your room you can type: l
echo

# Get players name and calc hash- value which determines the map

printf "Choose your dungeon master!:"
read name
scene=$(java HashValue $name) # If you do not have jave installed, remove this line and replace with "scene=your 8- bit value"

printf "And your avatars name is?"
read avatar

# Bits 1 to 3 of 'scene' are the x pos of bools bit
# 128 64 32 16 8 4 2 1

let "bitx=scene & 3"

# Bits 4 to 7 of 'scene' are the y pos of bools bit

let "bity=scene & 12"

printf "$name say's: Your fate is sealed $avatar. You may fight bravely but you will never win!"
printf "So let's $avatar's quest begin (press return)"
# echo $bitx ---- $bity
read ret

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
    
    if [ $roomx -eq $bitx ] && [ $roomy -eq $bity ] &&  [ $level -eq 0 ]
    then
	echo 
	echo Congratulations! You found the lost bit
	echo
	
	gameends
    fi
   
    # Prompt
    
    
    echo --------------Which way n/s/e/w u or d ?
    read dir

    let "steps=steps+1"
    

    # Move
    
    # look?

    if [ $dir = "l" ] 
    then
	echo Examining......
	descripe
    fi
    
    # Up ok?

    if [ $dir = "u" ] 
    then
	if [ $dd -eq 1 ] 
	then
	    if [ $level -eq 1 ]
	    then
		up
		let "level=level-1"
		descripe
	    fi
	else
	    echo There is no way up
	fi		
    fi
    
    # Down ok?

    if [ $dir = "d" ] 
    then
	if [ $dd -eq 1 ] 
	then
	    if [ $level -eq 0 ]
	    then
		down
		let "level=level+1"
		descripe
	    fi
	else
	    echo There is no way down
	fi		
    fi

    # West ok?

    if [ $dir = "w" ] 
    then
	if [ $dw -eq 1 ]
	then
        # Check if in dungeon.
	
	    if [ $level -eq 0 ]
	    then
		increase
		let "roomx=roomx-1"
		descripe
	  
            # If in dungeon, we move 2- steps at a time
		    
	    else
		increase
		increase
		let "roomx=roomx-2"
		descripe
	    fi  
	else
	    echo West is blocked!
	fi
    fi	
    
    # East ok?
    
    if [ $dir = "e" ] 
    then
	if [ $de -eq 1 ]
	then
	    if [ $level -eq 0 ]
	    then
		decrease
		let "roomx=roomx+1"
		descripe
	    else
		decrease
		decrease
		let "roomx=roomx+2"
		descripe
	    fi
	else
	    echo East is blocked
	fi
    fi
    
    # North ok?
    
    if [ $dir = "n" ] 
    then

	if [ $dn -eq 1 ]
	then
	    if [ $level -eq 0 ]
	    then
		north
		let "roomy=roomy-1"
		descripe
	    else
		north
		north
		let "roomy=roomy-2"
		descripe
	    fi
	else
	    echo North is blocked!
	fi
    fi	
    
    # South ok?
    
    if [ $dir = "s" ] 
    then
	if  [ $ds -eq 1 ]
	then
	    if [ $level -eq 0 ]
	    then
		south
		let "roomy=roomy+1"
		descripe
	    else
		south
		south
		let "roomy=roomy+2"
		descripe
	    fi
	else
	    echo South is blocked!
	fi
    fi

    # Check inventory

    if [ $torch -ge 1 ]
    then
	let "torch=torch-1"
    fi

    if [ $water -gt 0 ]
    then
	let "water=water-1"
    else
	echo You run out of water! You are death! The lost bit is lost forever....
	gameends
    fi
done    






