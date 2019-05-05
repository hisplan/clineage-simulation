#!/bin/bash

if [ ! -x "$(command -v qsub)" ]
then
    echo "qsub not found. Aborted."
    exit 1
fi

# default
max_running=50

# by default, run everything (tree simulation, genotyping, reconstruction)
run_flag='0 0 0';

# choose a default SGE queue based on hostname
hostname=`hostname -s`
if [ "$hostname" == "mcluster01" ]
then
    queue_name='all.q'
fi
if [ "$hostname" == "mcluster03" ]
then
    queue_name='all2.q'
fi

usage()
{
cat << EOF
USAGE: `basename $0` [options]

    -r  absolute path to simulation root where seed-* are placed
    -n  max number of jobs that can run in parallel
    -f  run flag (default: "${run_flag}")
    -q  queue name (default: "${queue_name}")

EOF
}

while getopts "r:q:n:f:h" OPTION
do
    case $OPTION in
        r) path_root=$OPTARG ;;
        q) queue_name=$OPTARG ;;
        n) max_running=$OPTARG ;;
        f) run_flag=$OPTARG ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$path_root" ]
then
    usage
    exit 1
fi


seeds=`find ${path_root} -maxdepth 1 -name "seed-*" -type d`

project_name=$(uuidgen)

echo ">>> Project Name: ${project_name}"

for path_project in $seeds
do

    cases=`cat ${path_project}/config.list`

    for case in $cases
    do

        while true
        do
            counter=`qstat -q ${queue_name} | tail -n +3 | wc -l`
            if [ $counter -le $max_running ] || [ $counter -eq $max_running ]
            then
                break
            fi
            sleep 60
            echo "waiting until the queue frees up..."
        done

        echo "${path_project}/${case}"
        ./sge-submit.sh \
            -n ${project_name} \
            -p ${path_project} \
            -q ${queue_name} \
            -c ${case} \
            -f "${run_flag}"

        # you need to wait until sge completes submission
        sleep 10

    done

done

echo "<<< Project Name: ${project_name}"
