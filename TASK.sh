#!/usr/bin/env bash

#SBATCH -p wacc --gres gpu:1
#SBATCH -o a.out -e a.err

module load cuda

#nvcc task.cu breaker.cu -Xcompiler -O3 -Xcompiler -Wall -Xptxas -O3 -o task

./task 1 1024 1c3bf3e22fa424473023adcb686dd576

# for (( i=10; i<=30; i++ ));
# do
#     result=$((1 << $i ))
#     ./task $result 1024
#     echo
# done

