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

wget https://files.rcsb.org/download/1ubq.pdb

grep "^ATOM" 1ubq.pdb > 1UBQ_clean.pdb

martinize2 -f 1UBQ_clean.pdb -o topol.top -x 1UBQ_cg.pdb -elastic

gmx editconf -f 1UBQ_cg.pdb -c -d 2 -o out.gro

martiniglass -p topol.top -f out.gro -cyl -vf -el

vmd out.gro -e vis.vmd

