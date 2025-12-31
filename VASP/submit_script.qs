#!/bin/bash -l
#
#SBATCH --nodes=2
#SBATCH --tasks-per-node=36
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G

export OMP_NUM_THREADS=1

# Fix base directory at the start
BASE_DIR=$(pwd)
cp "$BASE_DIR/POSCAR.hexagonal" POSCAR 2>/dev/null
cp "$BASE_DIR/POSCAR.hexagonal" CONTCAR 2>/dev/null

for j in {1..15}; do
    echo "=== Starting run $j ==="

    # Ensure required files exist before proceeding
    if [ ! -f "$BASE_DIR/INCAR" ] || [ ! -f "$BASE_DIR/CONTCAR" ]; then
        echo "Missing INCAR or CONTCAR in $BASE_DIR — exiting."
        exit 1
    fi

    # Rename or copy files (safer to copy if originals needed later)
    cp "$BASE_DIR/ML_ABN" ML_AB 2>/dev/null
    cp "$BASE_DIR/ML_FFN" ML_FF 2>/dev/null
    cp "$BASE_DIR/CONTCAR" POSCAR 2>/dev/null

    # Compute temperature range
    temp_beg=$((1 + 100 * (j - 1)))
    temp_end=$((1 + 100 * j))

    # Update INCAR parameters (match lines beginning with TEBEG/TEEND)
    sed -i "s/^[[:space:]]*TEBEG.*/TEBEG  = $temp_beg              ! temperature-start/" "$BASE_DIR/INCAR"
    sed -i "s/^[[:space:]]*TEEND.*/TEEND  = $temp_end              ! temperature-end/" "$BASE_DIR/INCAR"

    # Run VASP and save log
    echo "Running VASP for TEBEG=$temp_beg ? TEEND=$temp_end"
    mpirun vasp_std > "vasp_run_${j}.log" 2>&1

    # Create directory for this run and copy important files
    mkdir -p "$BASE_DIR/$j"
    cp XDATCAR OSZICAR POSCAR CONTCAR ML_AB ML_LOGFILE INCAR OUTCAR "$BASE_DIR/$j/" 2>/dev/null

    # Clean up working directory
    rm -f XDATCAR OSZICAR POSCAR ML_AB ML_FF ML_LOGFILE ML_HIS ML_REG OUTCAR \
          PCDAT REPORT DOSCAR EIGENVAL vaspout.h5

    echo "=== Completed run $j ==="
    echo
done