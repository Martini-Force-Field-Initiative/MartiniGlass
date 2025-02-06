#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

wget https://github.com/Martini-Force-Field-Initiative/MartiniGlass/tree/main/examples/martini.itp

# martinize the first protein
martinize2 -f prot0_clean.pdb -x prot0_cg.pdb -o prot0_topol.top -go prot0_contact_map.out -name prot0
mv go_nbparams.itp prot0_go_nbparams.itp
mv go_atomtypes.itp prot0_go_atomtypes.itp

# martinize the second protein
martinize2 -f prot1_clean.pdb -x prot1_cg.pdb -o prot1_topol.top -go prot1_contact_map.out -name prot1
mv go_atomtypes.itp prot1_go_atomtypes.itp
mv go_nbparams.itp prot1_go_nbparams.itp

# concatenate the files together
cat prot0_go_nbparams.itp prot1_go_nbparams.itp > go_nbparams.itp
cat prot0_go_atomtypes.itp prot1_go_atomtypes.itp > go_atomtypes.itp

# make the box with multiple copies of each molecule using gromacs
gmx insert-molecules -ci prot0_cg.pdb -nmol 5 -box 20 20 20 -o newbox.gro
gmx insert-molecules -ci prot1_cg.pdb -nmol 3 -f newbox.gro  -o vis.gro
rm newbox.gro

# run martiniglass.py
martiniglass -p topol.top -go -gf go_nbparams.itp -vf -f vis.gro

# open vmd
vmd vis.gro -e vis.vmd
