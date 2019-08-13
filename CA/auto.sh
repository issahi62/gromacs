#!/bin/bash

echo "Free energy home directory set to $FREE_ENERGY"

gmx editconf -f confg.gro -o confg_PBC.gro -c -bt cubic -d 1.0 

echo "done with protein boundary conditions"

sleep 10

#################################
# SOLVATION #
#################################


gmx solvate -cp confg_PBC.gro -cs spc216 -o protein_solv.gro -p topol.top

echo "how nice to be done with solvation:::: Team:: Mabel,Issah,Steven,Robert"

####################
# GENERATION OF IONS #
####################


#genions#

gmx grompp -f ions.mdp -c protein_solv.gro -p topol.top -o ions.tpr

echo "TEAM steven, Issah, Robert, Mabel"

sleep 5

gmx genion -s ion.tpr -o protein_ion.gro -p topol.top -neutral  

#################################
# ENERGY MINIMIZATION 1: STEEP  #
#################################
echo "Starting minimization for lambda = $LAMBDA..." 


# Iterative calls to grompp and mdrun to run the simulations#

gmx grompp -f minim.mdp -c protein_ion.gro -p topol.top -o em.tpr

gmx mdrun -nt 4 -deffnm em

sleep 10

#################################
# ENERGY MINIMIZATION 2: L-BFGS #
#################################

#cd ../
#mkdir EM_2
#cd EM_2

# We use -maxwarn 1 here because grompp incorrectly complains about use of a plain cutoff; this is a minor issue
# that will be fixed in a future version of Gromacs
#gmx grompp -f $MDP/EM/em_l-bfgs_$LAMBDA.mdp -c ../EM_1/min$LAMBDA.gro -p $FREE_ENERGY/5d7f/topol.top -o min$LAMBDA.tpr -imd min$LAMBDA.gro -maxwarn 1

# Run L-BFGS in serial (cannot be run in parallel)

#gmx mdrun -nt 1 -deffnm min$LAMBDA

#sleep 20

echo "Minimization complete."


#####################
# NVT EQUILIBRATION #
#####################
echo "Starting constant volume equilibration..."



gmx grompp -f nvt.mdp -c em.gro -p topol.top -o nvt.tpr

gmx mdrun -nt 4 -deffnm nvt 

sleep 10

echo "Constant volume equilibration complete."



#####################
# NPT EQUILIBRATION #
#####################
echo "Starting constant pressure equilibration..."



gmx grompp -f npt.mdp -c nvt.gro -p topol.top -t nvt.cpt -o npt.tpr

gmx mdrun -nt 4 -deffnm npt

sleep 10

gmx grompp -f md.mdp -c npt.gro -p topol.top -t npt.cpt -o md.tpr

gmx mdrun -v -nt 4 -deffnm md

sleep 20
echo "Production MD complete."

# End
echo "Ending. Job completed"



