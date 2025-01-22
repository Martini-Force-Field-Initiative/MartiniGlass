## Multiple Go models

Input and output files for the tutorial on visualising systems containing multiple
proteins with go models with MartiniGlass.

Using the files in the [input](input) folder, the `generate_expected_files.sh` script should generate
the files found in the [output](output) folder. The script assumes there are installations of both
`martiniglass` and `martinize2` available. If your Python environment has the former installed, the
latter will also be.

This tutorial also assumes that a version of gromacs is both installed and sourced, to generate an 
initial configuration. For that reason, the file `vis.gro` in the [output](output) folder may not be 
exactly the same.


