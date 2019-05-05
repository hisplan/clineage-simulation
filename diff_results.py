#!/bin/python

import itertools
import subprocess
import os
import argparse
import glob


def run_command(cmd):
    "run command"

    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

    # wait for the process to terminate
    stdout, stderr = process.communicate()

    stdout = stdout.decode('UTF-8').strip()
    stderr = stderr.decode('UTF-8').strip()

    return stdout, stderr, process.returncode


def diff_output(path_run_a, path_run_b):

    files = [
        "triplets-list.raw.txt",
        "triplets-list.id-name.csv",
        "reconstructed.newick",
        "scores.raw.out",
        "mutation_table.txt"
    ]

    for file in files:

        _, _, exit_code = run_command(
            [
                'diff',
                os.path.join(path_run_a, file),
                os.path.join(path_run_b, file)
            ]
        )

        if exit_code != 0:
            print(
                os.path.basename(path_run_a) + " ? " +
                os.path.basename(path_run_b)
            )
            print("{} DIFFERENT!".format(file))
            print()


def parse_arguments():

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--runs",
        action="store",
        dest="path_runs",
        required=True
    )

    # parse arguments
    params = parser.parse_args()

    return params


if __name__ == "__main__":

    params = parse_arguments()

    dirs = glob.glob(
        params.path_runs + "/*"
    )

    for path_run_a, path_run_b in itertools.combinations(dirs, 2):

        diff_output(path_run_a, path_run_b)

    print("DONE.")
