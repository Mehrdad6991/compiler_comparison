# compiler_comparison

From the repository scripts, run the generate32_csv.sh script:

   $ ./generate32_csv.sh

This will create the gcc.sh and llvm.sh inside each benchmark directory. Please change the compiler path before.

Copy the compiler_timing_execute.sh to the root directory where benchmarks existing and run it.

   $ ./compiler_timing_execute.sh

This will compile all benchmarks with all different configurations In addition by running this command all elf files, code sizes and compile times results will be stored in each benchmark directory.

Then by running the collect_data.sh which is copied to the root directory beside all two previous commands, all data will be seperated into different txt files in order to prepare them for better statistical analysis and ploting.

   $ ./collect_data.sh
   
   
Next step is to execute the benchmark on the platform or count the number of executed instructions on the platform using spike. please copy the openocd-genesys2.cfg, program_fpga.tcl, pulpissimo_genesys2.bit, and spike.cfg before running these scripts.

   $ ./init

   $ ./openocd

   $ ./execute_benchmark
