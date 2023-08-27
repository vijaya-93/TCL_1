# TCL_workshop
**Task:** **Generating a data sheet of prelayout STA results from the design information in .csv file using tcl & shell scripting**

  **Input:** .csv file with netlist, constraints file, library files, output directory information and constraints in .csv form

  **output:** Prelayout timing results

    **step 1:** create shellscript to pass .csv file to tcl script

    **step2:** convert all inputs to a form compatible with synthesis tool "**Yosys**"

   ** step3:** check hierarchy and identify the missing verilog modules and perform the synthesis using tool "**Yosys**"

    **step4:**  convert the inputs & SDC to a form compatible with STA engine "**OpenTimer**"

    **step5:** generate output reports

**Stepwise details and sample results:**

**Step1:** _**(i)**_ creating shell script "**vsdsynth.sh**" that can pass .csv file with design details to tcl script. Below is the message when shell script is executed without any argument (.csv file)

<img width="401" alt="shell_1" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/b260fdce-cff9-4a7b-b9f5-e45e9af8dd30">

_**(ii)**_ Passing a valid .csv file as an argument to shell script and also the tcl script "**vsdsynth.tcl**". 

**(iii)**_ Defining variables from the data provided in .csv file

<img width="541" alt="shell-2" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/bca3e804-dc59-4757-8176-b7c27b870468">

_**(iv)**_ Printing variable values on to screen and checking for the existance of directories present in the .csv file

<img width="554" alt="shell-3" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/2e0e3b3f-022a-42a9-8ce0-32027df42611">

**Step2:** Creating constraints from the .csv file in SDC form compatible with synthesis tool "**Yosys**"

_**(i)**_ creating clock constraints for latency and transition

_**(ii)**_ Identify the bus type ports from a list of input ports and add "*" to apply the constraints to all bits of a bus uniformly

_**(iii)**_ creating input constraints for latency and transition

_**(iv)**_ Identify the bus type ports from a list of output ports and add "*" to apply the constraints to all bits of a bus uniformly

_**(v)**_ creating output constraints for latency 

_**(vi)**_ creating constraints for load

_**(vii)**_ dumping the above created constraints for clock, input, output to .sdc file created in output directory

<img width="542" alt="shell-4" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/7b94e07b-faa1-4298-ad8c-4828bd5f5c77">


<img width="544" alt="shell-5" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/c82028b3-4a6e-404a-814d-37b2f8942c78">


<img width="544" alt="shell-6" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/c7cb921b-43e6-410e-992b-8bd29b7585b3">

<img width="542" alt="shell-7" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/4a9ddb82-6914-4588-9848-c95a2712353a">

**Step3:** _**(i)**_ check hierarchy and identify the missing verilog modules and fix the issues related to submodule references

_**(ii)**_ generate the script required for synthesis using "**Yosys**" tool

_**(iii)**_ perform the synthesis using tool "**Yosys**" and observe the synthesized netlist generated in output directory

<img width="546" alt="shell-8" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/1902dea7-7561-4510-b0ee-e5f24f698347">

<img width="548" alt="shell-9 1" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/8e5ab618-fd45-4bd5-b32d-8025a75f3295">

<img width="541" alt="shell-9" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/03cb5cb2-1ca0-4d6c-95f6-cec3f9e9954c">

<img width="506" alt="shell-10" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/16410327-aebc-4dab-814c-288eda4f7139">

**Step4:**  




<img width="544" alt="c_hier_ys" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/46f9d71c-02e5-4802-8610-70b195c0828b">



<img width="543" alt="c_ys" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/399bf92d-e1d3-4df7-a74a-b1a2d9f50079">




<img width="533" alt="c_ys_1" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/9ea6c23a-96cd-4602-af34-259584957938">




<img width="545" alt="c_synth_v" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/15c7a66f-c32f-4cfc-9299-77167ad952a6">




<img width="546" alt="c_sdc" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/25e10d4a-de42-4055-9204-27a1ebad3b7d">







