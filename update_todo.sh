#!/bin/bash

dt=$(date '+%d/%m/%Y %H:%M:%S')

echo -e "Filen updaterad $dt\n" > todo_list.txt

for file in ./Pong/Pong/*.asm
 do 
	echo -e $file": \n" >> todo_list.txt
	sed -n '/TODO:$/,/ENDTODO$/p;' $file >> todo_list.txt
	#echo -e "\n" >> todo_list.txt
 done

 sed -i 's/;//;s/ENDTODO//' todo_list.txt
 sed -i 's:./Pong/Pong/::' todo_list.txt
