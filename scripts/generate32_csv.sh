#!/bin/sh

# "gcc.sh" and "llvm.sh" originally written by mehrdad
# modifications and batch creation by moritz
# last modified: 2020-04-01 v2b

set -e

for dir in */; do
    fn="$dir/gcc.sh"
    echo "generating '$fn'" >&2
    cat > "$fn" <<EOF
#!/bin/bash

set -euo -pipefail
set -x

export PATH=/.../bin/:\$PATH


input_files="\$(ls | grep '\\.c\$')"
output_file="report_gcc.txt"
ctime_file="compiletime_gcc.txt"
TIMEFORMAT=\$'%R,%U,%S'

## declare array of architectures
declare -a ARCHS=("rv32i" "rv32if" "rv32im" "rv32ic" "rv32imc" "rv32ifc") 
declare -a OPTS=("s" "0" "1" "2" "3")

report="Table of different optimization level\\n"

# check if compiletime.txt already exists. Delete file if it is so, for new fresh data...
if [ -f \$ctime_file ] ; then
	rm -i \$ctime_file
fi

echo 'march,opt,run,real,user,sys' > \$ctime_file

for run in {1..100}; do
for march in "\${ARCHS[@]}"
do
	report+="\\n\$march architecture:\\n\\n"
        report+="run:\$run\\n"
	report+="Optimization\\n"
	report+="--------------------------------------------------\\n"
	for opt in "\${OPTS[@]}"
	do
		report+="\$opt:\\n"
		echo -n "\$march,\$opt,\$run," >> \$ctime_file
		mkdir -p "gcc/\$march"
		fn="gcc/\$march/\${march}_\$opt"
		{ time { {
			objs=""
			for input_file in \$input_files; do
				riscv32-unknown-elf-gcc -O"\$opt" -march="\$march" -c \$input_file
				objs="\$objs \${input_file%.c}.o"
			done
			riscv32-unknown-elf-gcc -O"\$opt" -march="\$march" -o "\$fn" \$objs
		} 2>&1 ; } ; } 2>> \$ctime_file
		report+=\$(size "\$fn")
		report+="\\n"
	done
	report+="\\n"
done

done

## print to file and show the report on the screen
echo -e \$report | tee \$output_file
EOF
    chmod a+x "$fn"

    fn="$dir/llvm.sh"
    echo "generating '$fn'" >&2
    cat > "$fn" <<EOF
#!/bin/bash

set -euo -pipefail
set -x

export PATH=/.../bin/:\$PATH
export PATH=/.../llvm10/bin/:\$PATH


input_files="\$(ls | grep '\\.c\$')"
output_file="report_llvm.txt"
ctime_file="compiletime_llvm.txt"
TIMEFORMAT=\$'%R,%U,%S'

## declare array of architectures
declare -a ARCHS=("rv32i" "rv32if" "rv32im" "rv32ic" "rv32imc" "rv32ifc")
declare -a OPTS=("s" "0" "1" "2" "3")

report="Table of different optimization level\\n"

if [ -f \$ctime_file ] ; then
	rm -i \$ctime_file
fi

echo 'march,opt,run,real,user,sys' > \$ctime_file

for run in {1..100}; do
for march in "\${ARCHS[@]}"
do
	report+="\\n\$march architecture:\\n\\n"
	report+="Optimization\\n"
	report+="--------------------------------------------------\\n"
	for opt in "\${OPTS[@]}"
	do
		report+="\$opt:\\n"
		echo -n "\$march,\$opt,\$run," >> \$ctime_file
		mkdir -p "llvm/\$march"
		fn="llvm/\$march/\${march}_\$opt"
		{ time { {
			objs=""
			for input_file in \$input_files; do
				clang-10 -c --target=riscv32-unknown-elf \$input_file -march="\$march" -O"\$opt"
				objs="\$objs \${input_file%.c}.o"
			done
			riscv32-unknown-elf-gcc -march="\$march" -O"\$opt" -o "\$fn" \$objs
		} 2>&1 ; } ; } 2>> \$ctime_file

		report+=\$(size "\$fn")
		report+="\\n"
	done
	report+="\\n"
done
done
## print to file and show the report on the screen
echo -e \$report | tee \$output_file
EOF
    chmod a+x "$fn"
done
