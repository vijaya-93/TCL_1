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

<img width="401" alt="shell_1" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/923241d6-af08-40c6-a1d2-312e8155226a">

_**(ii)**_ Passing a valid .csv file as an argument to shell script and also the tcl script "**vsdsynth.tcl**". 

**(iii)**_ Defining variables from the data provided in .csv file

<img width="541" alt="shell-2" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/aa02bb6c-4953-43e0-b8d1-ec7f0e39a930">


_**(iv)**_ Printing variable values on to screen and checking for the existance of directories present in the .csv file

<img width="554" alt="shell-3" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/8023770e-9ea3-43e5-a8ff-5c30c255608d">


**Step2:** Creating constraints from the .csv file in SDC form compatible with synthesis tool "**Yosys**"

_**(i)**_ creating clock constraints for latency and transition

_**(ii)**_ Identify the bus type ports from a list of input ports and add "*" to apply the constraints to all bits of a bus uniformly

_**(iii)**_ creating input constraints for latency and transition

_**(iv)**_ Identify the bus type ports from a list of output ports and add "*" to apply the constraints to all bits of a bus uniformly

_**(v)**_ creating output constraints for latency 

_**(vi)**_ creating constraints for load

_**(vii)**_ dumping the above created constraints for clock, input, output to .sdc file created in output directory

<img width="542" alt="shell-4" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/ef0cbcdd-4258-487e-a113-2ea2759a1c4f">

<img width="544" alt="shell-5" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/fc94b421-c7f6-465b-b570-84428865731b">

<img width="544" alt="shell-6" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/254b941b-fca5-4d83-91ff-6318ce50ece8">

<img width="542" alt="shell-7" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/48da35b9-211f-4ad6-a963-843c773c5eb5">

**Step3:** _**(i)**_ check hierarchy and identify the missing verilog modules and fix the issues related to submodule references

_**(ii)**_ generate the script required for synthesis using "**Yosys**" tool

_**(iii)**_ perform the synthesis using tool "**Yosys**" and observe the synthesized netlist generated in output directory

<img width="546" alt="shell-8" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/fd381b85-3b36-46b0-9543-d146ac9b37fe">

<img width="548" alt="shell-9 1" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/801b6000-ba8e-4b55-8184-34e2e0b0496a">

<img width="541" alt="shell-9" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/cc95d6b3-a6b8-4b63-8276-8ab88e923725">


<img width="360" alt="code-1" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/9c629851-528a-4c78-9e91-e83af735c3d0">

<img width="506" alt="shell-10" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/a8b81651-ff4f-4ea4-82d3-961d0e10a23b">

<img width="529" alt="code-2" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/838550c3-606c-4987-91fb-dd8b7426579d">

<img width="544" alt="c_hier_ys" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/da7bb490-51a6-46fd-9a08-ae3346dad12c">

<img width="543" alt="c_ys" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/523d4f3d-bd6b-4dfa-b171-64122768c60b">

<img width="533" alt="c_ys_1" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/d50e9c44-e2ad-4512-ae3e-5612eb965828">

<img width="546" alt="c_sdc" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/a3b1b1d9-fc4c-4303-92c5-5b3f80415b1e">

<img width="545" alt="c_synth_v" src="https://github.com/vijaya-93/TCL_workshop/assets/143013255/3db1984c-ecb9-4dcf-8457-793ba6d54539">

**Step4:** convert the inputs & SDC to a form compatible with STA engine "**OpenTimer**"




**step5:** generate output reports


