#!/bin/tcsh -f
echo 
echo "*****tcl workshop during 23-08-2023 and 27-08-2023******"
echo
echo "****************LEARNING begins*****************"
echo
set my_work_dir = `pwd`
if ($#argv != 1) then
	echo "there are no inputs given"
        echo
       	echo "Info: provide csv file"
        exit 1
endif
if (! -f $argv[1] || $argv[1] == "-help") then
        if($argv[1] != "-help") then
                echo "Error:"
                exit 1
        else
                echo "USAGE:"
		exit 1
        endif
else
       echo "...reading the tcl file from shell script..."	
	tclsh vsdsynth.tcl $argv[1]
endif
