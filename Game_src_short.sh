mapx=20;mapy=20 ;water=10;torch=5;steps=0;dir="n";level=0;roomx=8;roomy=8;let "$roomnumber=$roomx*$roomxy";calcbits(){
let "bit1=(scene & 1)/1";let "bit2=(scene & 2)/2";let "bit3=(scene & 4)/4";let "bit4=(scene & 8)/8";let "bit5=(scene & 16)/16";let "bit6=(scene & 32)/32";let "bit7=(scene & 64)/64";let "bit8=(scene & 128)/128";return
}
gameends(){
echo The adventure ends here brave $avatar;break
}
increase()
{
    calcbits;let "temp=bit1^bit2^bit3^bit8";let "scene=255&((scene<<1)|temp)";return
}
decrease ()
{
    calcbits;let "temp=bit2^bit3^bit4^bit1";let "temp=temp<<7";let "scene=255&((scene>>1)|temp)";return
}
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
    printf "\ec"   
    printf "\e[7m" 
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
    printf "\e[m"
    north=1
    south=2
    west=4
    east=6
    ladder=7
    lake=5
    fire=3
    clue=8
    trap=48    
    forest=32
    dw=0
    de=0
    ds=0
    dn=0
    dd=0
    let "d=$north&$scene"
    if [ $d -eq $north ]                  
    then                                   
	echo North
	dn=1
    fi
    let "d=$south&$scene"
    if [ $d -eq $south ]
    then
	echo South
	ds=1
    fi
    let "d=$west&$scene"
    if [ $d -eq $west ] 
    then
	echo West
	dw=1
    fi
    let "d=$east&$scene"
    if [ $d -eq $east ] 
    then
	echo East
	de=1
    fi
    let "d=$ladder&$scene"
    if [ $d -eq $ladder ]
    then
	echo There is a pit with a ladder
	dd=1
    fi
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
    if [ $level -eq 0 ]
    then
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
	let "d=$clue&$scene"
	if [ $d -eq $clue ]
	then
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
    fi
    if [ $level -eq 1 ]
    then
	let "d=$fire&$scene"
	if [ $d -eq $fire ]
	then
	    echo I can see a lantern. You light your torch. It burns brightly again
	    torch=5
	fi
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
    fi
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
printf "\ec"
echo Welcome to: 
echo 
printf "\e[32m"
echo ----------- Bools Lost Bit ----------
printf "\e[m"
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
printf "Choose your dungeon master!:"
read name
scene=$(java HashValue $name)
printf "And your avatars name is?"
read avatar
let "bitx=scene & 3"
let "bity=scene & 12"
printf "$name say's: Your fate is sealed $avatar. You may fight bravely but you will never win!"
printf "So let's $avatar's quest begin (press return)"
read ret
descripe
while [ 1 ]
do
    if [ $roomx -eq $bitx ] && [ $roomy -eq $bity ] &&  [ $level -eq 0 ]
    then
	echo 
	echo Congratulations! You found the lost bit
	echo
	gameends
    fi
    echo --------------Which way n/s/e/w u or d ?
    read dir
    let "steps=steps+1"
    if [ $dir = "l" ] 
    then
	echo Examining......
	descripe
    fi
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
    if [ $dir = "w" ] 
    then
	if [ $dw -eq 1 ]
	then
	    if [ $level -eq 0 ]
	    then
		increase
		let "roomx=roomx-1"
		descripe
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
