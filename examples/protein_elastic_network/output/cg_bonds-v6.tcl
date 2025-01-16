
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                                                                           #
  #   --- DISCLAIMER (by Chris Brasnett, c.s.brasnett@rug.nl), June 2024      #
  #                                                                           #
  #   For ease of maintenance and to reflect the ways in which martini_vis    #
  #   now handles elements such as elastic networks, I removed some of the    #
  #   features of cg_bonds-v5.tcl that are no longer necessary. While this    #
  #   means this script has less functionality than its predecessors, I       #
  #   think it's easier to understand so it can be used in conjunction with   #
  #   other tools.                                                            #
  #                                                                           #
  #   --- DISCLAIMER (by Alex H. de Vries, A.H.de.Vries@rug.nl)               #
  #                                                                           #
  #   I made a small change for the gmxdump route, for use with in gromacs    #
  #   versions 5 and later, 2016, etc... Not tested extensively!              #
  #   -gmx flag needs to point to gmx executable, not gmxdump executable      #
  #                                                                           #
  #   --- DISCLAIMER (by Clement Arnarez, C.Arnarez@rug.nl):                  #
  #                                                                           #
  #   This script is largely inspired by the one written by Nicolas Sapay     #
  #   (hum... less and less true, after the recent complete refont of the     #
  #   code), available on the GROMACS website.                                #
  #                                                                           #
  #   Initially written to read Martini and ElNeDyn topologies, it seems to   #
  #   work for any couple of conformation/topology file (even for all atom    #
  #   systems apparently) generated with the GROMACS package.                 #
  #                                                                           #
  #   As always, you can modify, redistribute and make everything you want    #
  #   with these few lines of code; if you write major improvement, please    #
  #   let me know/test it!                                                    #
  #                                                                           #
  #                                                                           #
  #   --- ORIGINAL DISCLAIMER (by Nicolas Sapay):                             #
  #                                                                           #
  #   Somewhere in there...:                                                  #
  #   http://lists.gromacs.org/pipermail/gmx-users/2009-October/045935.html   #
  #   ... and there:                                                          #
  #   http://www.gromacs.org/Developer_Zone/Programming_Guide/VMD             #
  #                                                                           #
  #   TCL Script to visualize CG structures in VMD                  # # # # # #
  #   Version 3.0                                                   #       #
  #   Adapted from vmds                                             #     #
  #                                                                 #   #
  #                                                                 # #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

### ------------------------------------------------------------------------------------------------ USAGE

# shows usage
proc cg_bus { } { cg_bonds_usage }
proc cg_bonds_usage { } {
  puts ""
  puts " USAGE"
  puts "-------"
  puts ""
  puts "These few lines are given by the \"cg_bonds_usage\" command."
  puts ""
  puts "Draw bonds for specific molecules."
  puts "   cg_bonds \[OPTIONS\]"
  puts ""
  puts "Options and default values:"
  puts "   -top       topol.top            path to the system topology files (.top linking to .itp)"
  puts ""
  puts "Delete the Martini network:"
  puts "   cg_delete_martini_bonds \[OPTION\]"
  puts ""
  puts "Shortcut (delete everything, including bonds/constraints lists):"
  puts "   cg_delete_all \[OPTION\]"
  puts ""
}

# first load
cg_bonds_usage

###

### ------------------------------------------------------------------------------------------------ UTILS

# check if file exists
proc file_exists { file } { if { [file exists $file] } { return -code 0 } else { return -code 1 "\nError: file $file does not exist.\n" } }

# add bond/constraint to the list table
proc add_link { molecule_id first_bead second_bead LNK } {
  upvar $LNK links
  if { [info exists links($molecule_id,$first_bead)] } { lappend links($molecule_id,$first_bead) $second_bead } else { set links($molecule_id,$first_bead) $second_bead }
  if { [info exists links($molecule_id,$second_bead)] } { lappend links($molecule_id,$second_bead) $first_bead } else { set links($molecule_id,$second_bead) $first_bead }
}

# add list of beads linked to the current one
proc link_bead { total_occurences bead_numbers LNK  molecule_id start_at network } {
  upvar $LNK links
  for { set occurence 0 } { $occurence < $total_occurences } { incr occurence } {
    set bead_number [dict get $bead_numbers $molecule_id]
    for { set bead 0 } { $bead < $bead_number } { incr bead } {
      if { [info exists links($molecule_id,$bead)] } {
        set bead_index [expr $bead+$start_at+$occurence*$bead_number]
        set linked_beads {}
        foreach linked_bead $links($molecule_id,$bead) {
          set linked_bead_index [expr $linked_bead+$start_at+$occurence*$bead_number]
          if { [lsearch $linked_beads $linked_bead_index] == -1  } { lappend linked_beads $linked_bead_index }
        }
        lappend network $linked_beads
      } else {
        lappend network {}
      }
    }
  }
  return $network
}

###

### ------------------------------------------------------------------------------------------------ PARSING FILES

# reads .top-related .itp files and extract bonds and constraints
proc parse_itp { itp topology_type bead_numbers BD CNSTR } {

  # bonds/constraints
  upvar $BD bonds
  upvar $CNSTR constraints
  # boolean
  set read_moleculetype "False"
  set read_atoms "False"
  set read_bonds "False"
  # molecules
  set molecule_id ""
  set previous_molecule_id ""
  set bead_number 0
  # current bond/constraint
  set first_bead 0
  set second_bead 0
  set previous_first_bead 0
  set previous_second_bead 0
  # type of bonds read
  set which_type_of_link 0

  # opens the .itp file
  set itp [open $itp "r"]
  while 1 {
    gets $itp line
    set line [string trim $line]
    if [eof $itp] break
    if { [string bytelength $line] > 0 && [string first ";" [string trim $line] 0] != 0 && [string first "#" [string trim $line] 0] != 0 } {

      # read nothing
      if { [string first "\[" $line 0] == 0 && [string first "angles" $line 0] > -1 } {
        set read_moleculetype "False"
        set read_atoms "False"
        set read_bonds "False"
      }

      # reads bonds
      if { $read_bonds == "True" } {
        # bead indexes
        regexp {(\d+)\s+(\d+)} $line 0 first_bead second_bead
        set first_bead [expr $first_bead-1]
        set second_bead [expr $second_bead-1]
        # boolean to know which bonds are read
        if { $first_bead < $previous_first_bead && $second_bead < $previous_second_bead } { incr which_type_of_link }
        # actual bond
        if { $topology_type == "martini" } { add_link $molecule_id $first_bead $second_bead bonds }
      }
      if { [string first "\[" $line 0] == 0 && [string first "bonds" $line 0] > -1 } {
        set read_moleculetype "False"
        set read_atoms "False"
        set read_bonds "True"
      }

      # reads atom number
      if { $read_atoms == "True" } { if { [regexp {(\d+)\s+(.*)\s+(\d+)} $line 0] } { incr bead_number } }
      if { [string first "\[" $line 0] == 0 && [string first "atoms" $line 0] > -1 } {
        set read_moleculetype "False"
        set read_atoms "True"
        set read_bonds "False"
        set read_constraints "False"
      }

      # reads molecule name
      if { $read_moleculetype == "True" } {
        regexp {(.*)\s+(\d+)} $line 0 molecule_id whatever
        set molecule_id [string tolower [string trim $molecule_id]]
      }
      if { [string first "\[" $line 0] == 0 && [string first "moleculetype" $line 0] > -1 } {
        # booleans
        set read_moleculetype "True"
        set read_atoms "False"
        set read_bonds "False"
        # current bond/constraint
        set first_bead 0
        set second_bead 0
        # type of bonds read
        set which_type_of_link 0
        # bead number
        if { $bead_number > 0 } { dict set bead_numbers $molecule_id $bead_number }
        set bead_number 0
      }

      # sets previous atom indexes (for later comparison)
      set previous_molecule_id $molecule_id
      set previous_first_bead $first_bead
      set previous_second_bead $second_bead

    }
  }

  # last molecule read
  dict set bead_numbers $molecule_id $bead_number

  # closes file
  close $itp

  # return results
  return $bead_numbers

}



# reads .top file
proc parse_top { molid top topology_type BD CNSTR } {

  # system topology
  set molecules {}
  set occurences {}
  set bead_numbers [dict create]
  # boolean (occurences)
  set read_molecules "False"

  # bonds/constraints
  upvar $BD bonds
  upvar $CNSTR constraints

  # path to the .top file
  set path [lreplace [split $top "/"] end end]
  # opens the .top file and read it
  set top [open $top "r"]
  while 1 {
    gets $top line
    set line [string trim $line]
    if [eof $top] break
     if { [string bytelength $line] > 0 && [string first ";" [string trim $line] 0] != 0 } {

      # reads include files
      if { [string first "#include" $line 0] > -1 } {
        set itp [string trim [lindex [split $line] 1] "\""]
        if { [string first "/" $line 0] > -1 } { file_exists "[join $path "/"]/$itp" } else { file_exists $itp }
        set bead_numbers [parse_itp $itp $topology_type $bead_numbers bonds constraints]
      }
 
      # reads system topology (occurences)
      if { $read_molecules == "True" } {
        regexp {(.*)\s+(\d+)} $line 0 molecule_id occurence
        lappend molecules [string tolower [string trim $molecule_id]]
        lappend occurences $occurence
      }
      if { [string first "\[" $line 0] == 0 && [string first "molecules" $line 0] > -1 } { set read_molecules "True" }
 
   }
  }

  # closes file
  close $top

  # return results
  return [list $molecules $occurences $bead_numbers]

}

###





### ------------------------------------------------------------------------------------------------ GENERATES AND DRAWS NETWORKS

# generates bond lists
proc generate_bond_lists { molecules occurences bead_numbers BD CNSTR bonds_and_or_constraints } {

  # real indexes of molecules
  set start_at 0
  # martini networks
  set martini_network {}

  # bonds/constraints
  upvar $BD bonds
  upvar $CNSTR constraints
  array unset bonds_constraints

  # joins bonds/constraints tables, when needed
  for { set molecule 0 } { $molecule < [llength $molecules] } { incr molecule } {
    set molecule_id [lindex $molecules $molecule]
    for { set bead 0 } { $bead < [dict get $bead_numbers $molecule_id] } { incr bead } {
      if { [info exists bonds($molecule_id,$bead)] && ($bonds_and_or_constraints == "bonds" || $bonds_and_or_constraints == "both") } { set bonds_constraints($molecule_id,$bead) $bonds($molecule_id,$bead) }
      if { [info exists constraints($molecule_id,$bead)] && ($bonds_and_or_constraints == "constraints" || $bonds_and_or_constraints == "both") } {
        if { [info exists bonds_constraints($molecule_id,$bead)] } { set bonds_constraints($molecule_id,$bead) [concat $bonds_constraints($molecule_id,$bead) $constraints($molecule_id,$bead)] } else { set bonds_constraints($molecule_id,$bead) $constraints($molecule_id,$bead) }
      }
    }
  }

  # generates list of vmd bonds
  for { set molecule 0 } { $molecule < [llength $molecules] } { incr molecule } {
    set molecule_id [lindex $molecules $molecule]
    set occurence [lindex $occurences $molecule]
    set martini_network [link_bead $occurence $bead_numbers bonds_constraints $molecule_id $start_at $martini_network]
    set start_at [expr $start_at+($occurence*[dict get $bead_numbers $molecule_id])]
  }

  # return results
  return [list $martini_network]

}



# generates and draws network
proc cg_bonds { args } {
  set args [join $args]
  set args [split $args]

  # default values
  set molid "top"
  set use_top "False"
  set top "topol.top"
  set topology_type "martini"
  set network "martini"
  set bonds_and_or_constraints "both"
  # parses arguments
  foreach { n m } $args {
    if { $n == "-molid" } { set molid $m }
    if { $n == "-top" } {
      file_exists $m
      set use_tpr "False"
      set tpr ""
      set use_top "True"
      set top $m
    }
    if { $n == "-net" } { set network $m }
  }

  # bonds/constraints 
  array unset bonds
  array unset constraints

  # parses chosen files, return topologies
  if { $use_top == "True" } { lassign [parse_top $molid $top $topology_type bonds constraints] molecules occurences bead_numbers }
  # generates bond lists for given molecule and cutoff
  lassign [generate_bond_lists $molecules $occurences $bead_numbers bonds constraints $bonds_and_or_constraints] martini_network

  # draws martini network...
  if { $network == "martini" } { [atomselect $molid "all" frame 0] setbonds $martini_network }

}

###





### ------------------------------------------------------------------------------------------------ DELETES MARTINI/ELNEDYN NETWORKS

# deletes all martini bonds
proc cg_dmb { args } { cg_delete_martini_bonds $args }
proc cg_delete_martini_bonds { args } {
  set args [join $args]
  set args [split $args]

  # parses argument
  set molid "top"
  foreach { n m } $args { if { $n == "-molid" } { set molid $m } }

  # total number of beads
  set bead_number [molinfo $molid get numatoms]

  # creates the bond list
  set bond_list {}
  for { set index 0 } { $index < $bead_number } { incr index } { lappend bond_list {} }

  # draws an empty list of bonds
  set all [atomselect $molid all frame 0]
  $all setbonds $bond_list

}

# deletes all generated stuffs
proc cg_dab { args } { cg_delete_all $args }
proc cg_delete_all { args } {
  set args [join $args]
  set args [split $args]

  # parses argument
  set molid "top"
  foreach { n m } $args { if { $n == "-molid" } { set molid $m } }

  # deletes martini network
  cg_delete_martini_bonds $molid

}

###
