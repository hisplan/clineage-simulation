#!/bin/bash

path_runs="examples/example-reproducible-b"

for i in {1..9}
do

  python simulator.py \
    --env config.math102-lx.env \
    --project ~/projects/clineage-simulation/examples/example-01/ \
    --config config.json

  mkdir -p ${path_runs}/example-01.${i}
  cp -r examples/example-01/outputs/* ${path_runs}/example-01.${i}/

done

python diff_results.py --runs ${path_runs}
