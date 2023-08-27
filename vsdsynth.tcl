#! /bin/env tclsh
#... check correct usage of vsdsyn...#
set enable_prelayout_timing 1
set working_dir [exec pwd]
set vsd_array_length [llength [split [lindex $argv 0] .]]
set input [lindex [split [lindex $argv 0] .] $vsd_array_length-1]
if {![regexp {^csv} $input] || $argc!=1} {
	puts "error in usage"
	exit
} else {
	puts " "
	puts "......convert .csv to matrix & create initial variables...."
	set filename [lindex $argv 0]
	package require csv
	package require struct::matrix
	struct::matrix m
	set f [open $filename]
	csv::read2matrix $f m , auto
	close $f
	set columns [m columns]
	m link my_arr
	set num_of_rows [m rows]
	set i 0
	while {$i < $num_of_rows} {
		puts "\nInfo:setting $my_arr(0,$i) as $my_arr(1,$i)"
		if {$i==0} {
			set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
		} else {
			set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
		}
		set i [expr {$i+1}]
	}
}
puts "\nInfo: Initial  variables and their values are:"
puts " "
puts "DesignName = $DesignName"
puts "OutputDirectory = $OutputDirectory"
puts "NetlistDirectory = $NetlistDirectory"
puts "EarlyLibraryPath = $EarlyLibraryPath"
puts "LateLibraryPath = $LateLibraryPath"
puts "ConstraintsFile = $ConstraintsFile"
puts " "
puts ".....check if the directories exists........"
if {! [file exists $EarlyLibraryPath]} {
	puts "\nError: Early Library file doesn't exist in path $EarlyLibraryPath...Exiting"
} else {
	puts "\nInfo: Early library file exists in path $EarlyLibraryPath"
}
if {! [file exists $LateLibraryPath]} {
        puts "\nError: late Library file doesn't exist in path $LateLibraryPath...Exiting"
} else {
        puts "\nInfo: late library file exists in path $LateLibraryPath"
}
if {! [file exists $ConstraintsFile]} {
        puts "\nError: constraints file doesn't exist in path $ConstraintsFile...Exiting"
} else {
        puts "\nInfo: constarints file exists in path $ConstraintsFile"
}
if {! [file isdirectory $OutputDirectory]} {
        puts "\nError: output directory doesn't exist in path $OutputDirectory..Creating it"
	file mkdir $OutputDirectory
} else {
        puts "\nInfo: output directory exists in path $OutputDirectory"
}
if {! [file isdirectory $NetlistDirectory]} {
        puts "\nError: netlist directory doesn't exist in path $NetlistDirectory..Exiting"
} else {
        puts "\nInfo: netlist directory exists in path $NetlistDirectory"
}
#creating constraints
puts "******creating constraints in SDC format for $DesignName**********"
::struct::matrix constraints 
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints , auto
close $chan 
set number_of_rows [constraints rows]
set number_of_columns [constraints columns]
puts "check row numbers for clocks & delays in .csv file"
set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0]
puts " "
puts "check row no for inputs & also outputs"
set input_ports_start [lindex [lindex [constraints search all INPUTS] 0] 1]
set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]
puts " "
puts "clock constraints for latency"
set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_rise_delay] 0] 0]
set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_fall_delay] 0] 0]
set clock_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_rise_delay] 0] 0]
set clock_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_fall_delay] 0] 0]
puts " "
puts "clock constraints for transition"
set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_rise_slew] 0] 0]
set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_fall_slew] 0] 0]
set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_rise_slew] 0] 0]
set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_fall_slew] 0] 0]
puts " "
puts "dumping constraints to SDC file"
set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start-1}]
puts "\nInfo: ***********writing clock-constraints************"
while {$i < $end_of_ports} {
puts -nonewline $sdc_file "\ncreate_clock- -name [constraints get cell 0 $i] -period [constraints get cell 1 $i] -waveform \{0 [expr {[constraints get cell 1 $i] * [constraints get cell 2 $i]/100}]\] \[get_ports [constraints get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [constraints get cell $clock_early_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i] \]"
puts -nonewline $sdc_file "\nset_clock_latency -source -early -fall [constraints get cell $clock_early_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i] \]"
puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise [constraints get cell $clock_late_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i] \]"
puts -nonewline $sdc_file "\nset_clock_latency -source -late -fall [constraints get cell $clock_late_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i] \]"
set i [expr {$i+1}]
}
#########creating input constarints#############
puts "create variables for input ports"
set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_rise_delay] 0] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_fall_delay] 0] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_rise_delay] 0] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_fall_delay] 0] 0]
puts "input constraints for transition"
set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_rise_slew] 0] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_fall_slew] 0] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_rise_slew] 0] 0]
set input_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_fall_slew] 0] 0]
puts " "
puts "#########creating input constarints#############"
set related_clock [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] clocks] 0] 0]
set i [expr {$input_ports_start+1}]
set end_of_ports [expr {$output_ports_start-1}]
puts " "
puts "\nInfo: differentiating ports as bits & buses"
while {$i < $end_of_ports} {
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
	set fd [open $f]
	puts "reading file $f"
	while {[gets $fd line] != -1} {
	set pattern1 " [constraints get cell 0 $i];"
	if {[regexp -all -- $pattern1 $line]} {
		puts "pattern1 \"$pattern1\" found & matching line in verilog file \"$f\" is \"$line\""
		set pattern2 [lindex [split $line ";"] 0]
		puts "creating pattern2 by splitting pattern1"
		puts  "\"$pattern2\""
		if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {
			puts "out of all patterns pattern2 has matching string input. preserve it & ignore others"
			set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
			puts " "
			puts "pritning first 3 elements of pattern2 as \"$s1\" using space delimiter"
			puts -nonewline $tmp_file "\n[regsub -all {\S+} $s1 " "]"
			puts "replaced multiple spaces in \"$s1\" by single space & reformatted as \"[regsub -all {\S+} $s1 " "]\""
		}
	}
}
close $fd
}
close $tmp_file
set tmp_file [open /tmp/1 r]
#######read, sort, join /tmp/1 contents##############
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts "count is [llength [read $tmp2_file]]"
set count [llength [read $tmp2_file]]
puts "split content of tmp2 using space 7 count no. of elements as $count"
if {$count > 2} {
	set inp_ports [concat [constraints get cell 0 $i] *]
	puts "bussed"
} else {
	set inp_ports [constraints get cell 0 $i]
	puts "single bit"
}
puts "input port name is $inp_ports since count is $count\n"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_slew_start $i] \[get_ports $inp_ports\]"
set i [expr {$i+1}]
}
close $tmp2_file
#############output port constraints#################
puts "create variables for output ports"
set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] early_rise_delay] 0] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] late_rise_delay] 0] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] early_fall_delay] 0] 0]
set output_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] late_fall_delay] 0] 0]
set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] load] 0] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] clocks] 0] 0]
set i [expr {$output_ports_start+1}]
set end_of_ports [expr {$number_of_rows}]
puts "******************output constraints**************************"


puts "\nInfo: differentiating ports as bits & buses"
while {$i < $end_of_ports} {
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
        set fd [open $f]
        puts "reading file $f"
        while {[gets $fd line] != -1} {
        set pattern1 " [constraints get cell 0 $i];"
        if {[regexp -all -- $pattern1 $line]} {
                puts "pattern1 \"$pattern1\" found & matching line in verilog file \"$f\" is \"$line\""
                set pattern2 [lindex [split $line ";"] 0]
                puts "creating pattern2 by splitting pattern1"
                puts  "\"$pattern2\""
                if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {
                        puts "out of all patterns pattern2 has matching string input. preserve it & ignore others"
                        set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
                        puts " "
puts "pritning first 3 elements of pattern2 as \"$s1\" using space delimiter"
                        puts -nonewline $tmp_file "\n[regsub -all {\S+} $s1 " "]"
                        puts "replaced multiple spaces in \"$s1\" by single space & reformatted as \"[regsub -all {\S+} $s1     " "]\""
                }
        }
}
close $fd
}
close $tmp_file
set tmp_file [open /tmp/1 r]
#######read, sort, join /tmp/1 contents##############
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts "count is [llength [read $tmp2_file]]"
set count [llength [read $tmp2_file]]
puts "split content of tmp2 using space 7 count no. of elements as $count"
if {$count > 2} {
        set output_ports [concat [constraints get cell 0 $i] *]
        puts "bussed"
} else {
        set output_ports [constraints get cell 0 $i]
        puts "single bit"
}
puts "output port name is $output_ports since count is $count\n"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $output_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $output_late_rise_delay_start $i] \[get_ports $output_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $output_early_fall_delay_start $i] \[get_ports $output_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $output_late_fall_delay_start $i] \[get_ports $output_ports\]"
puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i] \[get_ports $output_ports\]"
set i [expr {$i+1}]
}
close $tmp2_file
close $sdc_file
puts "\nInfo: SDC created in path $OutputDirectory/$DesignName.sdc"
###########synthesis autmation using yosys tool######################
puts "**************Hierarchy check to identify missing modules*****************"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
puts "data is \"$data\""
set filename "$DesignName.hier.ys"
puts "filename is \"$filename\"" 
set fileid [open $OutputDirectory/$filename "w"]
puts -nonewline $fileid $data
set netlist [glob -dir $NetlistDirectory *.v]
puts "netlist is \"$netlist\""
foreach f $netlist {
	set data $f
	puts "data is \"$f\""
	puts -nonewline $fileid "\nread_verilog $f"
}
puts -nonewline $fileid "\nhierarchy -check"
close $fileid
puts "\nclose \"$OutputDirectory/$filename\"\n"
#############check hierarchy##############
puts "#############check hierarchy##############"
set my_err [catch {exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
puts "err flag is $my_err"
if {$my_err} {
	set filename "$OutputDirectory/$DesignName.hierarchy_check.log"
	puts "log file is $filename"
	set pattern {referenced in module}
	puts "pattern is $pattern"
	set count 0
	set fid [open $filename r]
	while {[gets $fid line] != -1} {
		incr count [regexp -all -- $pattern $line]
		if {[regexp -all -- $pattern $line]} {
			puts "\nError:module [lindex $line 2] is not a part of design $DesignName. Correct RTL in path $NetlistDirectory"
			puts "\nInfo:hiery check failed"
		}
	}
	close $fid
} else {
	puts "\nInfo: hierarchy check pass"
}
puts "\nInfo: hierarchy check details can be found in [file normalize $OutputDirectory/$DesignName.hierarchy_check.log]"
cd $working_dir
############main syn script##############
puts "\nInfo:creating main synthesis  script for yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
set fileid [open $OutputDirectory/$filename "w"]
puts -nonewline $fileid $data
set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
        set data $f
        puts -nonewline $fileid "\nread_verilog $f"
}
puts -nonewline $fileid "\nhierarchy -top $DesignName"
puts -nonewline $fileid "\nsynth -top $DesignName"
puts -nonewline $fileid "\nsplitnets -ports -format __\ndfflibmap -liberty ${LateLibraryPath}\nopt"
puts -nonewline $fileid "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileid "\nflatten"
puts -nonewline $fileid "\nclean -purge\niopadmap -outpad BUFX2 A:Y -bits\nopt\nclean"
puts -nonewline $fileid "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileid
puts "\nInfo:synth script created & accessible from path $OutputDirectory/$DesignName.ys"
puts "............Runnung synthesis..............."
if {[catch {exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/DesignName.synthesis.log} msg]} {
	puts "\nError: synthesis failed ref to log $OutputDirectory/$DesignName.synthesis.log"
	exit
} else {
	puts "\nInfo:synthesis finished "
}
puts "\nInfo:ref to log $OutputDirectory/$DesignName.synthesis.log"
######edit synth.v to be usable by opentimer #################
set fileid [open /tmp/1 "w"]
puts -nonewline $fileid [exec grep -V -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileid
set output [open $OutputDirectory/$DesignName.final.synth.v "w"]
set filename "/tmp/1"
set fid [open $filename r]
while {[gets $fid line] != -1} {
	puts -nonewline $output [string map {"\\" ""} $line]
	puts -nonewline $output "\n"
}
close $fid
close $output
puts "\nInfo:synthesized netlist for $DesignName is available now"
puts " "
#########################STA using opentimer#############
puts "\nInfo:timing analysis started & initializing no.of threads, libraries, sdc, verilog netlist path"
source /home/vsduser/vsdsynth/procs/reopenStdout.proc
source /home/vsduser/vsdsynth/procs/set_num_threads.proc
reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 4
source /home/vsduser/vsdsynth/procs/read_lib.proc
read_lib -early /home/vsduser/vsdsynth/osu018_stdcells.lib
read_lib -late /home/vsduser/vsdsynth/osu018_stdcells.lib
source /home/vsduser/vsdsynth/procs/read_verilog.proc
read_verilog $OutputDirectory/$DesignName.final.synth.v
source /home/vsduser/vsdsynth/procs/read_sdc.proc
read_sdc $OutputDirectory/$DesignName.sdc
reopenStdout /dev/tty
if{$enable_prelayout_timing == 1} {
	puts "\nInfo:enable_prelayout_timing=$enable_prelayout_timing & enabling zero-wire load parasitics"
	set spef_file [open $OutputDirectory/$DesignName.spef w]
	puts $spef_file "*SPEF \"IEEE 1481-1998\""
	puts $spef_file "*DESIGN \"$DesignName\""
	puts $spef_file "VENDOR \"TAU 2015 Contest\""
	puts $spef_file "*PROGRAM \"Benchmark parasitic generator\""
	puts $spef_file "*VERSIOn \"0.0\""
	puts $spef_file "*DESIGN_FLOW \"NETLIST_TYPE_VERILOG\""
	puts $spef_file "*DIVIDER/"
	puts $spef_file "*DELIMITER :"
	puts $spef_file "*BUS_DELIMITER [ ]"
	puts $spef_file "*T_UNIT 1PS"
	puts $spef_file "*C_UNIT 1FF"
	puts $spef_file "*R_UNIT 1KOHM"
	puts $spef_file "*L_unit 1UH"
}
close $spef_file
set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer"
puts $conf_file "report_timer"
puts $conf_file "report_wns"
puts $conf_file "report_worst_paths -numPaths 100000"
close $conf_file
set tcl_precision 3
set time_elapsed_in_us [time {exec /home/vsduser/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results} 1]
puts "time_elapsed_in_us is $time_elapsed_in_us"
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}]sec"
puts "time_elapsed_in_sec is $time_elapsed_in_us"
puts "\nInfo:STA finished $time_elapsed_in_sec seconds"
puts "\nInfo:ref to $OutputDirectory/$DesignName.results for warnings and errors"
############QoR generation#############
#####.............find worst output vilation...........##############
set worst_RAT_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
puts "report_file is $OutputDirectory/$DesignName.results"
set pattern {RAT}
puts "pattern is $pattern"
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		puts "pattern \"$pattern\" found in \"line\""
		puts "old worst RAT slack is $worst_RAT_slack"
		set worst_RAT_slack "[expr {[lindex $line 3]/1000}]ns"
		puts "part1 is [lindex $line 3]"
		puts "new worst RAT slack is $worst_RAT_slack"
		puts "breaking"
		break
	} else {
		continue
	}
}
close $report_file
###########find no of output vilation##############
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
puts "initial count is $count"
puts "begin_count"
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set number_output_violations $count
puts "number of output violations is $number_output_violations'
close $report_file
#####.............find worst setup vilation...........##############
set worst_negative_setup_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
#puts "report_file is $OutputDirectory/$DesignName.results"
set pattern {Setup}
#puts "pattern is $pattern"
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                #puts "pattern \"$pattern\" found in \"line\""
                #puts "old worst RAT slack is $worst_RAT_slack"
                set worst_negative_setup_slack "[expr {[lindex $line 3]/1000}]ns"
                #puts "part1 is [lindex $line 3]"
                #puts "new worst RAT slack is $worst_RAT_slack"
                #puts "breaking"
                break
        } else {
                continue
        }
}
close $report_file
###########find no of setup vilation##############
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
#puts "initial count is $count"
#puts "begin_count"
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}
set number_of_setup_violations $count
#puts "number of output violations is $number_output_violations'
close $report_file
#####.............find worst hold vilation...........##############
set worst_negative_hold_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
#puts "report_file is $OutputDirectory/$DesignName.results"
set pattern {Hold}
#puts "pattern is $pattern"
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                #puts "pattern \"$pattern\" found in \"line\""
                #puts "old worst RAT slack is $worst_RAT_slack"
                set worst_negative_hold_slack "[expr {[lindex $line 3]/1000}]ns"
                #puts "part1 is [lindex $line 3]"
                #puts "new worst RAT slack is $worst_RAT_slack"
                #puts "breaking"
                break
        } else {
                continue
        }
}
close $report_file
###########find no of hold vilation##############
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
#puts "initial count is $count"
#puts "begin_count"
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}
set number_of_hold_violations $count
#puts "number of output violations is $number_output_violations'
close $report_file
###########find no of instances##############
set pattern {num of gates}
set report_file [open $OutputDirectory/$DesignName.results r]
#set count 0
#puts "initial count is $count"
#puts "begin_count"
while {[gets $report_file line] != -1} {
        if {[regexp -all -- $pattern $line]} {
		set instance_count [lindex [join $line " "] 4]
		puts "pattern \"$pattern\" found at line \"$line\""
		break
	} else {
		continue
	}
}
close $report_file
puts "esign name is \{$DesignName\}"
puts "instance count is \{$instance_count\}"
puts "worst neg setup slack is \{$worst_negative_setup_slack\}"
puts "no of setup violations is \{$number_of_setup_violations\}"
puts "worst neg hold  slack is \{$worst_negative_hold_slack\}"
puts "no of hold violations is \{$number_of_hold_violations\}"
puts "worst output violation is \{$worst_RAT_slack\}"
puts "no of output violations is \{$number_output_violations\}"
puts "\n"
puts "            ********PRELAYOUT TIMING RESULTS***********            "
set formatstr {%15s%15s%15s%15s%15s%15s%15s%15s%15s}
puts [format $formatstr "....." "....." "....." "....." "....." "....." "....." "....." "....."]
puts [format $formatstr "designname" "runtime" "instance_count" "WNS_setup" "FEP_setup" "WNS_hold" "FEP_hold" "WNS_RAT" "FEP_RAT"]
puts [format $formatstr "....." "....." "....." "....." "....." "....." "....." "....." "....."]
foreach design_name $DesignName runtime $time_elapsed_in_sec instance_count $instance_count WNS setup $worst_negative_setup_slack FEP setup $number_of_setup_violations WNS hold $worst_negative_hold_slack FEP hold $number_of_hold_violations WNS RAT $worst_RAT_slack FEP RAT $number_output_violations {
       puts [format $formatstr $design_name $runtime $instance_count $WNS_setup $FEP_setup $WNS_hold $FEP_hold $WNS_RAT $FEP_RAT]	
}
puts [format $formatstr "....." "....." "....." "....." "....." "....." "....." "....." "....."]
puts "\n"
