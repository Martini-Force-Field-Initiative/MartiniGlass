# MartiniGlass: seeing your martini is believing

MartiniGlass uses [vermouth](https://github.com/marrink-lab/vermouth-martinize) to stably rewrite your input topology files as ones that can be used for 
visualisation in VMD. Although much of the functionality is focused on proteins, and the program has a particular 
focus on being able to visualise protein secondary/tertiary structure networks, MartiniGlass can in fact 
be used to reconstruct bonded networks of **any** Martini molecule!

If you can't view your system as expected, please open an [issue](https://github.com/Martini-Force-Field-Initiative/MartiniGlass/issues) 
if it is related to the code itself, or a [discussion](https://github.com/Martini-Force-Field-Initiative/MartiniGlass/discussions) for 
any other issues in the workflow of the code.

## Documentation

Documentation for MartiniGlass is available on the [readthedocs](https://martiniglass.readthedocs.io/en/latest) site.
The documentation covers multiple use cases and runs through the tutorials in the [examples](examples) folder
step by step.

## Installation

MartiniGlass v1.1.0 is available via pip:

```commandline
python3 -m venv venv && source venv/bin/activate # Not required, but often convenient.
pip install martiniglass
```

Alternatively, to benefit from the latest added features, install from the repository source:

```commandline
python3 -m venv venv && source venv/bin/activate # Not required, but often convenient.
pip install git+https://github.com/Martini-Force-Field-Initiative/MartiniGlass
```

## Citation
If you use MartiniGlass to visualise your system in a publication, please cite the following 
[paper](https://pubs.acs.org/doi/10.1021/acs.jcim.4c02277):
```
@article{Brasnett2025MartiniGlass,
    author = {Brasnett, Christopher and Marrink, Siewert J.},
    title = {MartiniGlass: a Tool for Enabling Visualization of Coarse-Grained Martini Topologies},
    journal = {Journal of Chemical Information and Modeling},
    volume = {65},
    number = {7},
    pages = {3137-3141},
    year = {2025},
    doi = {10.1021/acs.jcim.4c02277}
}
```

## Basic Usage

Ideally, MartiniGlass can generate all the visualisable topology files for a system with a single command:

```
martiniglass -p topol.top
```


However, if the system contains proteins with complex tertiary structure networks that are also needed, 
extra options may be requried. More comprehensive documentation and tutorials are available on the
[readthedocs](https://martiniglass.readthedocs.io/en/latest) site. If you think something is broken or have a
feature request, please open an [issue](https://github.com/Martini-Force-Field-Initiative/MartiniGlass/issues).


## Gallery 

For a practical example of how MartiniGlass can be used to generate visualisable topologies, and see the expected 
output, there is an example of the 1UBQ system shown below in the [examples](examples) folder. Here are some 
illustrations of how MartiniGlass can be used to visualise your molecules

![Martinizing a protein (Ubiquitin, PBD: 1UBQ) and visualising its elastic network.
left to right: atomistic representation of the protein. 
Martini representation of the protein overlaid on the atomistic one, showing the direct backbone and side chain.
Martini representation of the protein overlaid on the atomistic one, showing all bonds, with the elastic network in 
black. Martini representation of the protein, 
showing all bonds.](https://github.com/user-attachments/assets/09fe7a4f-bdd7-4302-a819-88e1c1040e0a)
**Martinizing a protein (Ubiquitin, PBD: 1UBQ) and visualising its elastic network.**
Left to right: atomistic representation of the protein. 
Martini representation of the protein overlaid on the atomistic one, showing the direct backbone and side chain.
Martini representation of the protein overlaid on the atomistic one, showing all bonds, with the elastic network in 
black. Martini representation of the protein, showing all bonds.

![img](https://github.com/user-attachments/assets/dec7dbb5-9c88-4742-9104-299df8a901ba)

**Non-protein systems.** Left: the molecular motor of [Vainikka and Marrink](https://doi.org/10.1021/acs.jctc.2c00796),
a synthetic molecule with complex topology, showing how the beads are connected using the CPK mode in VMD. Right: 
Several molecular motors together with a lipid bilayer of several different lipid types. 

