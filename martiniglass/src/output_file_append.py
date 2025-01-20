# Copyright 2024 University of Groningen
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

from pathlib import Path
from os import remove

def output_file_append(frame, trajectory, go=False, elastic=False):

    if isinstance(frame, Path):
        if go:
            extra_top = "go.top"

        if elastic:
            extra_top = "en.top"

        for fin in ['vis.vmd', 'proteins.vmd']:

            with open(fin) as f:
                lines = f.readlines()

            if isinstance(trajectory, Path):
                trajectory_line = f"mol addfile {trajectory} type xtc first 0 last -1 step 1 waitfor all molid 1\n"
            else:
                trajectory_line = " \n"

            extra = (f"mol new {frame} type gro first 0 last -1 step 1\n"
                     f"{trajectory_line}"
                     f"cg_bonds -top {extra_top}\n"
                     "mol modstyle 0 1 Bonds 0.300000 52.000000\n"
                     "mol modcolor 0 1 ColorID 16\n"
                     "mol modmaterial 0 1 AOChalky\n")

            lines_out = lines + [extra]

            remove(fin)

            with open(fin, "w") as fout:
                fout.writelines(lines_out)
