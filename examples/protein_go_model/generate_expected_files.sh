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

source /your/martini_vis/venv/bin/activate

wget https://raw.githubusercontent.com/marrink-lab/martini-forcefields/main/martini_forcefields/regular/v3.0.0/gmx_files/martini_v3.0.0.itp -O martini.itp

wget https://files.rcsb.org/download/1ubq.pdb

grep "^ATOM" 1ubq.pdb > 1UBQ_clean.pdb

###
### Here need to upload file to Go server and obtain contact map
###

martinize2 -f 1UBQ_clean.pdb -o topol.top -x 1UBQ_cg.pbd -dssp  -p backbone -ff martini3001 -go contact_map.out -cys auto -maxwarn 1 -scfix

wget https://github.com/marrink-lab/martini-forcefields/blob/main/martini_forcefields/regular/v3.0.0/gmx_files/martini_v3.0.0.itp
mv martini_v3.0.0.itp martini.itp

martiniglass -p topol.top -go -gf go_nbparams.itp