#!/bin/bash

path_work="$HOME/projects/clineage-simulation/examples/example-reproducible"

function say_if_different() {
    if [ $? -ne 0 ]
    then
        echo "--> DIFFERENT!"
    fi
}

function diff_output() {
    file1="${path_work}/output-$1/n-000001/$2"
    file2="${path_work}/output-$1/n-000002/$2"
    echo "Comparing $1/$2:"
    diff -y --suppress-common-lines ${file1} ${file2} &>/dev/null
    # diff ${file1} ${file2}
    say_if_different
    echo
}

python simulator.py \
    --env config.math102-lx.env \
    --project ${path_work} \
    --config config.list

diff_output "biallelic" "triplets-list.raw.txt"

diff_output "biallelic" "triplets-list.id-name.csv"

diff_output "biallelic" "reconstructed.newick"

diff_output "biallelic" "scores.raw.out"

diff_output "biallelic" "mutation_table.txt"

diff_output "monoallelic" "triplets-list.raw.txt"

diff_output "monoallelic" "triplets-list.id-name.csv"

diff_output "monoallelic" "reconstructed.newick"

diff_output "monoallelic" "scores.raw.out"

diff_output "monoallelic" "mutation_table.txt"

echo "DONE"
