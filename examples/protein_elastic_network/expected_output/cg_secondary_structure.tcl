
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                                                                           #
  #   --- DISCLAIMER (by Chris Brasnett, c.s.brasnett@rug.nl), September 2024 #
  #                                                                           #
  #    Unlike the edits to cg_bonds, I haven't made any substantial edits     #
  #    for clarity or functionality. The most useful change is that I've      #
  #    removed the need for the La.tcl script to be additionally used for     #
  #    the matrix maths to get the direction that objects should be drawn     #
  #    in. This has been replaced by eigen.py instead.                        #
  #                                                                           #
  #    At some point, removing and simplifying some of these options might    #
  #    be a good idea.                                                        #
  #                                                                           #
  #   --- DISCLAIMER (by Clement Arnarez, C.Arnarez@rug.nl)                   #
  #                                                                           #
  #   Script largely inspired on the script written by Martti, with some      #
  #   more subroutines anyway. Helices and sheets can now be drawn using a    #
  #   ribbon-like representation.                                             #
  #                                                                           #
  #   This script needs the "La" package available here:                      #
  #   http://www.ks.uiuc.edu/Research/vmd/script_library/scripts/orient/      #
  #                                                                           #
  #   Some of the routines used in this script were extracted, without        #
  #   asking the permission, from the "Orient" package written by Paul        #
  #   Grayson, pgrayson@ks.uiuc.edu and available at the previous link. I     #
  #   did that to avoid multiple inclusion in the headers; if this            #
  #   problematic, please drop me a mail.                                     #
  #                                                                           #
  #   As always, you can modify, redistribute and make everything you want    #
  #   with these few lines of code; if you write major improvement, please    #
  #   let me know/test it!                                                    #
  #                                                                           #
  #                                                                           #
  #   --- ORIGINAL DISCLAIMER (by Martti Louhivuori, M.J.Louhivuori@rug.nl)   #
  #                                                                           #
  #   Calculate and draw CG helices as cylinders.                             #
  #                                                                           #
  #   The subroutine "compute_helix_director" calculates the director of a    #
  #   helix, i.e. the major eigenvector scaled-up to the length of the        #
  #   helix and centered at the center-of-mass of the helix. Takes the IDs    #
  #   of the first and the last residue in a list as input, and returns the   #
  #   start and end points of the director in a list.                         #
  #                                                                 # # # # # # 
  #   Version: 0.7 (08/06/2009)                                     #       #
  #   Revised by Clement (18/04/2011)                               #     #
  #                                                                 #   #
  #                                                                 # #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #



# packages included
# source la.tcl
namespace path ::tcl::mathfunc

# constant
global pi
set pi 3.14159265358979323846



# shows usage
proc cg_ssus { } { cg_secondary_structure_usage }
proc cg_secondary_structure_usage { } {
  puts ""
  puts "Before anything else, you have to download, extract and source the package (la.tcl) available here: http://www.hume.com/la/. This is a linear algebra package written by Hume Integration Software used in this script to compute principal axes of helices/sheets."
  puts ""
  puts " USAGE"
  puts "-------"
  puts ""
  puts "These few lines are given by the 'cg_secondary_structure_usage' command."
  puts ""
  puts "Draw HELICES for specific molecules."
  puts "   cg_helix {{first_residue last_residue} ...} \[OPTIONS\]"
  puts ""
  puts "Options and default values:"
  puts "   -molid       top             VMD-defined ID of the molecule to process"
  puts "   -ssdump      \"ssdump.dat\"    read topology from a do_dssp-formated file"
  puts "   -bbbname     \"B.*\"           backbone bead name"
  puts ""
  puts "   -hlxmethod   \"idealhelix\"    method to draw sheets (idealhelix|realhelix|cylinder)"
  puts "   -hlxcolor    \"red\"           color of helices"
  puts "   -hlxmat      \"Opaque\"        material"
  puts "   -hlxres      12              resolution"
  puts ""
  puts "   -hlxrad      2.0             radius of cylinders"
  puts "   -hlxsides    \"round\"         arrow sides (round|sharp)"
  puts "   -hlxfilled   \"yes\"           cylinders filled or not (yes|no)"
  puts ""
  puts "   -hlxstep     1.0             angle step size"
  puts "   -hlxthick    0.2             thickness of helix"
  puts "   -hlxwidth    2.0             width of helix"
  puts "   -hlxdirect   \"no\"            draw the director vector of the helix (or not)"
  puts "   -hlxdirrad   0.1             radius of the cylinder (director)"
  puts "   -hlxdirclen  0.3             length of the cone (showing direction of the director)"
  puts "   -hlxdircrad  0.2             cone radius"
  puts "   -hlxsecbprop 0.5             proportion of the preceding/following bond used as length for starting/ending flat cones"
  puts ""
  puts "Draw SHEETS for specific molecules. The \"bendedarrow\", which would be the closest to VMD atomistic drawings, doesn't work so well so far (try and see). Still working on it!"
  puts "   cg_sheet {{first_residue last_residue} ...} \[OPTIONS\]"
  puts ""
  puts "Options and default values:"
  puts "   -molid       top             VMD-defined ID of the molecule to process"
  puts "   -ssdump      \"ssdump.dat\"    read topology from a do_dssp-formated file"
  puts "   -bbbname     \"B.*\"           backbone bead name"
  puts ""
  puts "   -shtmethod   \"flatarrow\"   method to draw sheets (cylindarrow|flatarrow|bendedarrow|triangle)"
  puts "   -shtcolor    \"green\"         color of sheets"
  puts "   -shtmat      \"Opaque\"        material of sheets"
  puts "   -shtres      12              resolution"
  puts "   -shtsides    \"round\"         sheet sides (round|sharp)"
  puts ""
  puts "   -shtrad      0.4             radius of cylinders"
  puts "   -shtconrad   0.8             radius of arrow cones"
  puts "   -shtlencone  1.5             length of arrow cones"
  puts "   -shtfilled   \"yes\"           cylinder filled or not (yes|no)"
  puts ""
  puts "   -shtarrwidth 2.0             width of arrows"
  puts "   -shtheadsize 4.0             size of the arrow heads"
  puts "   -shtarrthick 1.0             thickness of arrows"
  puts ""
  puts "   -shtstep     0.1             distance step size"
  puts "   -shtthick    0.2             thickness of sheet"
  puts "   -shtwidth    2.0             width of sheet"
  puts "   -shtdirect   \"no\"            draw the director vector of the sheet (or not)"
  puts "   -shtdirrad   0.1             radius of the cylinder (director)"
  puts "   -shtdirclen  0.3             length of the cone (showing direction of the director)"
  puts "   -shtdircrad  0.2             cone radius"
  puts "   -shtsecbprop 0.5             proportion of the preceding/following bond used as length for starting/ending flat cones"
  puts ""
  puts "Draw helices AND sheets (using a do_dssp-formated file):"
  puts "   cg_ss \[OPTIONS\]"
  puts "   cg_secondary_structure \[OPTIONS\]"
  puts ""
  puts "This command takes all the options defined above; the do_dssp output file (option -ssdump) is mandatory."
  puts ""
  puts "Most of the options defined above for the 'cg_helix' and 'cg_sheet' routines were added afterwards, after (self-)discussion and (self-)brainstorming; I didn't re-test every single of them each time I modified the script. Please drop an email (C.Arnarez@rug.nl) if you find a bug."
  puts ""
  puts "Delete ALL the graphics drawn:"
  puts "   cg_dag \[OPTIONS\]"
  puts "   cg_delete_all_graphics \[OPTIONS\]"
  puts ""
  puts "Option and default value:"
  puts "   -molid    top                VMD-defined ID of the molecule to process"
  puts ""
  puts " EXAMPLES"
  puts "----------"
  puts ""
  puts "   cg_helix {{5 88} {120 146}} -hlxcolor \"lime\" -hlxrad 2.5 -hlxfilled \"yes\""
  puts "   cg_ss -hlxcolor \"green\" -shtmat \"AOChalky\" -ssdump protein.dat"
  puts "   cg_sheet {} -shtfilled no -ssdump protein.dat -shtarrowthick 0.4"
  puts "   cg_secondary_structure -molid 2 -ssdump ssdump.dat -shtmethod \"realbendedarrow\" -bbbname \"CA\""
  puts "   cg_dag -molid 2"
  puts ""
}



# draw helices and sheets
proc cg_ss { args } { cg_secondary_structure $args }
proc cg_secondary_structure { args } {
  set args [join $args]
  set args [split $args]

  # parses arguments
  foreach { n m } $args {
    if { $n == "-ssdump" } {
      cg_helix {} $args
      cg_sheet {} $args
    }
  }

}



# draw each CG helices
proc cg_helix { termini args } {
  set args [join $args]
  set args [split $args]

  # default values
  set molid "top"
  set ssdump "False"
  set ssfile "ssdump.dat"
  set bbb "\"B.*\""

  set method "idealhelix"
  set color "red"
  set material "Opaque"
  set resolution 12

  set cylinder_radius 2.0
  set helix_sides "round"
  set filled "yes"

  set step_size 1.0
  set helix_thickness 0.1
  set helix_width 2.0
  set helix_director "no"
  set director_radius 0.1
  set director_cone 0.3
  set cone_radius 0.2
  set start_end_cone_bond_proportion 0.5

  # parses arguments
  foreach { n m } $args {
    if { $n == "-molid" } { set molid $m }
    if { $n == "-ssdump" } {
      set ssdump "True"
      set ssfile $m
    }
    if { $n == "-bbbname" } { set bbb $m }
    if { $n == "-hlxmethod" } { set method $m }
    if { $n == "-hlxcolor" } { set color $m }
    if { $n == "-hlxmat" } { set material $m }
    if { $n == "-hlxres" } { set resolution $m }
    if { $n == "-hlxrad" } { set cylinder_radius $m }
    if { $n == "-hlxsides" } { set helix_sides $m }
    if { $n == "-hlxfilled" } { set filled $m }
    if { $n == "-hlxstep" } { set step_size $m }
    if { $n == "-hlxthick" } { set helix_thickness $m }
    if { $n == "-hlxwidth" } { set helix_width $m }
    if { $n == "-hlxdirect" } { set helix_director $m }
    if { $n == "-hlxdirrad" } { set director_radius $m }
    if { $n == "-hlxdirclen" } { set director_cone $m }
    if { $n == "-hlxdircrad" } { set cone_radius $m }
    if { $n == "-hlxsecbprop" } { set start_end_cone_bond_proportion $m }
  }

  # if a file describing the secondary structure is provided, read and parse it
  if { $ssdump == "True" } { set termini [read_parse_ssdump $ssfile "helices"] }

  # draw helices
  graphics $molid color $color
  graphics $molid material $material
  foreach pair $termini {
    set orientation [compute_orientation $molid $bbb $pair]
    set start [lindex $orientation 0]
    set end [lindex $orientation 1]
    set vec [lindex $orientation 2]
    set vecnorm [vecnorm $vec]
    if { $method == "cylinder" } {
      graphics $molid cylinder $start $end radius $cylinder_radius resolution $resolution filled $filled
    } elseif { $method == "realhelix" || $method == "idealhelix" } {
      # helix itself
      if { [catch { set helix [helix_coordinates $molid $bbb $pair $start $end $vec $step_size $method] } error_message] } {
        puts "Error: not able to draw helix \{$pair\} with the \"$method\" method ($error_message)."
      } else {
        foreach point $helix {
          graphics $molid cylinder [vector $vecnorm $point [expr -$helix_width/2.0]] [vector $vecnorm $point [expr $helix_width/2.0]] radius $helix_thickness resolution $resolution filled $filled
          if { $helix_sides == "round" } {
            graphics $molid sphere [vector $vecnorm $point [expr -$helix_width/2.0]] radius $helix_thickness resolution $resolution
            graphics $molid sphere [vector $vecnorm $point [expr $helix_width/2.0]] radius $helix_thickness resolution $resolution
          }
        }
        # director
        if { $helix_director == "yes" } {
          set base [vector $vecnorm $end [expr -$director_cone]]
          graphics $molid cylinder $start $base radius $director_radius resolution $resolution filled $filled
          graphics $molid cone $base $end radius $cone_radius resolution $resolution
        }
        # starting "flat cone"
        # bond between the two previous residues
        set residue [bead_coordinates $molid $bbb [lindex $pair 0]]
        set previous_residue [bead_coordinates $molid $bbb [expr [lindex $pair 0]-1]]
        set bond_vector [vector $residue $previous_residue]
        # starting cone
        set flat_cone_start [lindex $helix 0]
        set flat_cone_end [vector [vecnorm $bond_vector] $residue [expr [veclength $bond_vector]*$start_end_cone_bond_proportion]]
        # draw the flat cone
       draw_flat_cone $molid [flat_cone $vecnorm $flat_cone_start $flat_cone_end $helix_width $helix_thickness] $helix_sides $helix_thickness $resolution $filled
       # starting "end cone"
       # bond between the two previous residues
       set residue [bead_coordinates $molid $bbb [lindex $pair 1]]
       set next_residue [bead_coordinates $molid $bbb [expr [lindex $pair 1]+1]]
       set bond_vector [vector $residue $next_residue]
       # starting cone
       set flat_cone_start [lindex $helix [expr [llength $helix]-1]]
       set flat_cone_end [vector [vecnorm $bond_vector] $residue [expr [veclength $bond_vector]*$start_end_cone_bond_proportion]]
       # draw the flat cone
       draw_flat_cone $molid [flat_cone $vecnorm $flat_cone_start $flat_cone_end $helix_width $helix_thickness] $helix_sides $helix_thickness $resolution $filled
      }
    }
  }

}



# draw flat cone (start/end of helices/sheets)
proc draw_flat_cone { molid cone helix_sides helix_thickness resolution filled } {

  # coordinates of the points defining the cone
  set corner1 [lindex $cone 0]
  set corner2 [lindex $cone 1]
  set corner3 [lindex $cone 2]
  set corner1_minus_thickness [lindex $cone 3]
  set corner2_minus_thickness [lindex $cone 4]
  set corner3_minus_thickness [lindex $cone 5]
  set corner1_plus_thickness [lindex $cone 6]
  set corner2_plus_thickness [lindex $cone 7]
  set corner3_plus_thickness [lindex $cone 8]

  # finally draw the cone
  graphics $molid triangle $corner1_minus_thickness $corner2_minus_thickness $corner3_minus_thickness
  graphics $molid triangle $corner1_plus_thickness $corner2_plus_thickness $corner3_plus_thickness
  if { $helix_sides == "round" } {
    graphics $molid sphere $corner1 radius $helix_thickness resolution $resolution
    graphics $molid sphere $corner2 radius $helix_thickness resolution $resolution
    graphics $molid sphere $corner3 radius $helix_thickness resolution $resolution
    graphics $molid cylinder $corner1 $corner3 radius $helix_thickness resolution $resolution filled $filled
    graphics $molid cylinder $corner2 $corner3 radius $helix_thickness resolution $resolution filled $filled
  } else {
    graphics $molid triangle $corner1_minus_thickness $corner1_plus_thickness $corner3_minus_thickness
    graphics $molid triangle $corner1_plus_thickness $corner3_minus_thickness $corner3_plus_thickness
    graphics $molid triangle $corner2_minus_thickness $corner2_plus_thickness $corner3_minus_thickness
    graphics $molid triangle $corner2_plus_thickness $corner3_minus_thickness $corner3_plus_thickness
  }

}



# draw each CG sheets
proc cg_sheet { termini args } {
  set args [join $args]
  set args [split $args]

  global pi

  # default values
  set molid "top"
  set ssdump "False"
  set ssfile "ssdump.dat"
  set bbb "\"B.*\""

  set method "flatarrow"
  set color "green"
  set material "Opaque"
  set resolution 12
  set sheet_sides "round"

  set radius 0.4
  set cone_radius 0.8
  set cone_length 1.5
  set filled "yes"

  set arrow_width 2.0
  set head_size [expr 2.0*$arrow_width]
  set arrow_thickness 0.4

  set step_size 0.05
  set sheet_thickness 0.1
  set sheet_width 2.0
  set sheet_director "no"
  set director_radius 0.1
  set director_cone 0.3
  set cone_radius 0.2
  set start_end_cone_bond_proportion 0.5

  # parses arguments
  foreach { n m } $args {
    if { $n == "-molid" } { set molid $m }
    if { $n == "-ssdump" } {
      set ssdump "True"
      set ssfile $m
    }
    if { $n == "-bbbname" } { set bbb $m }
    if { $n == "-shtmethod" } { set method $m }
    if { $n == "-shtcolor" } { set color $m }
    if { $n == "-shtmat" } { set material $m }
    if { $n == "-shtres" } { set resolution $m }
    if { $n == "-shtsides" } { set sheet_sides $m }
    if { $n == "-shtrad" } { set radius $m }
    if { $n == "-shtconrad" } { set cone_radius $m }
    if { $n == "-shtlencone" } { set cone_length $m }
    if { $n == "-shtfilled" } { set filled $m }
    if { $n == "-shtarrwidth" } { set arrow_width $m }
    if { $n == "-shtheadsize" } { set head_size $m }
    if { $n == "-shtarrthick" } { set arrow_thickness $m }
    if { $n == "-shtstep" } { set step_size $m }
    if { $n == "-shtthick" } { set sheet_thickness $m }
    if { $n == "-shtwidth" } { set sheet_width $m }
    if { $n == "-shtdirect" } { set sheet_director $m }
    if { $n == "-shtdirrad" } { set director_radius $m }
    if { $n == "-shtdirclen" } { set director_cone $m }
    if { $n == "-shtdircrad" } { set cone_radius $m }
    if { $n == "-shtsecbprop" } { set start_end_cone_bond_proportion $m }
  }

  # if a file describing the secondary structure is provided, read and parse it
  if { $ssdump == "True" } { set termini [read_parse_ssdump $ssfile "sheets"] }

  # draw sheets
  graphics $molid color $color
  graphics $molid material $material
  # first methods (arrows)
  if { $method == "cylindarrow" || $method == "flatarrow" || $method == "bendedarrow" } {
    foreach pair $termini {
      if { [expr [lindex $pair 1]-[lindex $pair 0]] > 2 } {
        set orientation [compute_orientation $molid $bbb $pair]
        set start [lindex $orientation 0]
        set end [lindex $orientation 1]
        set vec [lindex $orientation 2]
        set vecnorm [vecnorm $vec]
        # first method (small lines, cylinder-like method)
        if { $method == "cylindarrow" } {
          # body
          set end [vector $vecnorm $end -$cone_length]
          graphics $molid cylinder $start $end radius $radius resolution $resolution filled $filled
          # head
          set base $end
          set tip [vector $vecnorm $end $cone_length]
          graphics $molid cone $base $tip radius $cone_radius resolution $resolution
        # second method (big arrow made of triangles)
        } elseif { $method == "flatarrow" } {
          set points [flat_arrow_coordinates $molid $bbb $pair $start $end $vecnorm $arrow_width $head_size $arrow_thickness]
          set points_over [lindex $points 1]
          set points_under [lindex $points 2]
          set points [lindex $points 0]
          # body: over...
          graphics $molid triangle [lindex $points_over 0] [lindex $points_over 1] [lindex $points_over 5]
          graphics $molid triangle [lindex $points_over 0] [lindex $points_over 5] [lindex $points_over 6]
          # ... under...
          graphics $molid triangle [lindex $points_under 0] [lindex $points_under 1] [lindex $points_under 5]
          graphics $molid triangle [lindex $points_under 0] [lindex $points_under 5] [lindex $points_under 6]
          # ... and sides
          graphics $molid triangle [lindex $points_under 0] [lindex $points_over 0] [lindex $points_over 6]
          graphics $molid triangle [lindex $points_under 0] [lindex $points_under 6] [lindex $points_over 6]
          graphics $molid triangle [lindex $points_under 0] [lindex $points_over 0] [lindex $points_over 1]
          graphics $molid triangle [lindex $points_under 0] [lindex $points_under 1] [lindex $points_over 1]
          graphics $molid triangle [lindex $points_under 6] [lindex $points_over 6] [lindex $points_over 5]
          graphics $molid triangle [lindex $points_under 6] [lindex $points_under 5] [lindex $points_over 5]
          # head: over...
          graphics $molid triangle [lindex $points_over 2] [lindex $points_over 4] [lindex $points_over 3]
          # ... under...
          graphics $molid triangle [lindex $points_under 2] [lindex $points_under 4] [lindex $points_under 3]
          # ... and sides
          graphics $molid triangle [lindex $points_under 2] [lindex $points_over 2] [lindex $points_over 4]
          graphics $molid triangle [lindex $points_under 2] [lindex $points_under 4] [lindex $points_over 4]
          graphics $molid triangle [lindex $points_under 2] [lindex $points_over 2] [lindex $points_over 3]
          graphics $molid triangle [lindex $points_under 2] [lindex $points_under 3] [lindex $points_over 3]
          graphics $molid triangle [lindex $points_under 3] [lindex $points_over 3] [lindex $points_over 4]
          graphics $molid triangle [lindex $points_under 3] [lindex $points_under 4] [lindex $points_over 4]
          # arrow sides
          if { $sheet_sides == "round" } {
            # body: sides
            graphics $molid cylinder [lindex $points 0] [lindex $points 6] radius [expr $arrow_thickness/3.0] resolution $resolution filled $filled
            graphics $molid cylinder [lindex $points 0] [lindex $points 1] radius [expr $arrow_thickness/3.0] resolution $resolution filled $filled
            graphics $molid cylinder [lindex $points 5] [lindex $points 6] radius [expr $arrow_thickness/3.0] resolution $resolution filled $filled
            # head: sides
            graphics $molid cylinder [lindex $points 2] [lindex $points 4] radius [expr $arrow_thickness/3.0] resolution $resolution filled $filled
            graphics $molid cylinder [lindex $points 2] [lindex $points 3] radius [expr $arrow_thickness/3.0] resolution $resolution filled $filled
            graphics $molid cylinder [lindex $points 3] [lindex $points 4] radius [expr $arrow_thickness/3.0] resolution $resolution filled $filled
            # corners
            foreach point $points { graphics $molid sphere $point radius [expr $arrow_thickness/3.0] resolution $resolution }
          }
        # third method (bended arrow, following the orientation of the sheet)
        } elseif { $method == "bendedarrow" } {
          set sheet [sheet_coordinates $molid $bbb $pair $start $end $vecnorm $step_size]
          set points [lindex $sheet 0]
          set sheet_vectors [lindex $sheet 1]
          for { set index 0 } { $index < [expr [llength $points]-1] } { incr index } {
            set point [lindex $points $index]
            set sheet_vector [lindex $sheet_vectors $index]
            graphics $molid cylinder [vector $sheet_vector $point [expr -$sheet_width/2.0]] [vector $sheet_vector $point [expr $sheet_width/2.0]] radius $sheet_thickness resolution $resolution filled $filled
            if { $sheet_sides == "round" } {
              graphics $molid sphere [vector $sheet_vector $point [expr -$sheet_width/2.0]] radius $sheet_thickness resolution $resolution
              graphics $molid sphere [vector $sheet_vector $point [expr $sheet_width/2.0]] radius $sheet_thickness resolution $resolution
            }
          }
          # director
          if { $sheet_director == "yes" } {
            set base [vector $vecnorm $end [expr -$director_cone]]
            graphics $molid cylinder $start $base radius $director_radius resolution $resolution filled $filled
            graphics $molid cone $base $end radius $cone_radius resolution $resolution
          }
         # starting "flat cone"
         # bond between the two previous residues
         set residue [bead_coordinates $molid $bbb [lindex $pair 0]]
         set next_residue [bead_coordinates $molid $bbb [expr [lindex $pair 0]-1]]
         set bond_vector [vector $residue $next_residue]
         # starting cone
         set flat_cone_start [lindex $points 0]
         set flat_cone_end [vector [vecnorm $bond_vector] $residue [expr [veclength $bond_vector]*$start_end_cone_bond_proportion]]
         # draw the flat cone
         draw_flat_cone $molid [flat_cone [vecnorm [lindex $sheet_vectors 0]] $flat_cone_start $flat_cone_end $sheet_width $sheet_thickness] $sheet_sides $sheet_thickness $resolution $filled
         # ending "flat cone"
         # bond between the two previous residues
         set residue [bead_coordinates $molid $bbb [lindex $pair 1]]
         set next_residue [bead_coordinates $molid $bbb [expr [lindex $pair 1]+1]]
         set bond_vector [vector $residue $next_residue]
         # starting cone
         set flat_cone_start [lindex $points [expr [llength $points]-1]]
         set flat_cone_end [vector [vecnorm $bond_vector] $residue [expr [veclength $bond_vector]*$start_end_cone_bond_proportion]]
         # draw the flat cone
         draw_flat_cone $molid [flat_cone [vecnorm [lindex $sheet_vectors [expr [llength $sheet_vectors]-1]]] $flat_cone_start $flat_cone_end $sheet_width $sheet_thickness] $sheet_sides $sheet_thickness $resolution $filled
        }
      }
    }
  # fourth method (triangles between alpha-carbon)
  } elseif { $method == "triangle" } {
    foreach pair $termini {
      if { [expr [lindex $pair 1]-[lindex $pair 0]] > 2 } {
        for { set residue [lindex $pair 0] } { $residue <= [expr [lindex $pair 1]-2] } { incr residue } {
          set res1 $residue
          set res2 [expr $residue+1]
          set res3 [expr $residue+2]
          set corner1 [bead_coordinates $molid $bbb $res1]
          set corner2 [bead_coordinates $molid $bbb $res2]
          set corner3 [bead_coordinates $molid $bbb $res3]
          set normal [vecnorm [veccross [vecnorm [vector $corner2 $corner1]] [vecnorm [vector $corner2 $corner3]]]]
          set corner1_minus_thickness [vector $normal $corner1 -$sheet_thickness]
          set corner2_minus_thickness [vector $normal $corner2 -$sheet_thickness]
          set corner3_minus_thickness [vector $normal $corner3 -$sheet_thickness]
          set corner1_plus_thickness [vector $normal $corner1 $sheet_thickness]
          set corner2_plus_thickness [vector $normal $corner2 $sheet_thickness]
          set corner3_plus_thickness [vector $normal $corner3 $sheet_thickness]
          # body
          graphics $molid triangle $corner1_minus_thickness $corner2_minus_thickness $corner3_minus_thickness
          graphics $molid triangle $corner1_plus_thickness $corner2_plus_thickness $corner3_plus_thickness
          # sides
          graphics $molid triangle $corner1_minus_thickness $corner1_plus_thickness $corner2_minus_thickness
          graphics $molid triangle $corner1_plus_thickness $corner2_plus_thickness $corner2_minus_thickness
          graphics $molid triangle $corner1_minus_thickness $corner1_plus_thickness $corner3_minus_thickness
          graphics $molid triangle $corner1_plus_thickness $corner3_plus_thickness $corner3_minus_thickness
          graphics $molid triangle $corner2_minus_thickness $corner2_plus_thickness $corner3_minus_thickness
          graphics $molid triangle $corner2_plus_thickness $corner3_plus_thickness $corner3_minus_thickness
          # rond sides
          if { $sheet_sides == "round" } {
            graphics $molid sphere $corner1 radius $sheet_thickness resolution $resolution
            graphics $molid sphere $corner2 radius $sheet_thickness resolution $resolution
            graphics $molid sphere $corner3 radius $sheet_thickness resolution $resolution
            graphics $molid cylinder $corner1 $corner2 radius $sheet_thickness resolution $resolution filled $filled
            graphics $molid cylinder $corner1 $corner3 radius $sheet_thickness resolution $resolution filled $filled
            graphics $molid cylinder $corner2 $corner3 radius $sheet_thickness resolution $resolution filled $filled
          }
        }
      }
    }
  }

}



# return coordinates of a bead
proc bead_coordinates { molid bbb index } { return [lindex [[atomselect $molid "resid $index and name $bbb"] get { x y z }] 0] }



# read and parse dssp-formated file
proc read_parse_ssdump { ssfile structure } {

  # initial values
  set residue_number 0
  set ss {}
  set termini {}

  # read the file
  set input [open $ssfile r]
  set counter 0
  while { [gets $input line] >= 0 } {
    if { $counter == 0 } { set residue_number $line } else { lappend ss $line }
    incr counter
  }
  close $input
  set ss [join $ss ""]

  # parse the secondary structure
  set first 0
  set last 0
  set pair {}
  for { set index 0 } { $index <= $residue_number } { incr index } {
    if { $structure == "helices" } {
      if { [string index $ss $index] == "G" || [string index $ss $index] == "H" || [string index $ss $index] == "I" } {
        if { $first == 0 } { set first [expr $index+1] } else { set last [expr $index+1] }
      } else {
        if { $first > 0 } {
          lappend termini [list $first $last]
          set first 0
        }
      }
    } else {
      if { [string index $ss $index] == "B" || [string index $ss $index] == "E" } {
        if { $first == 0 } { set first [expr $index+1] } else { set last [expr $index+1] }
      } else {
        if { $first > 0 } {
          lappend termini [list $first $last]
          set first 0
        }
      }
    }
  }

  # return list of first and last residues
  puts "\[$ssfile:$structure\] \{$termini\}"
  return $termini

}



# draw a helix, ribbon-like representation
proc helix_coordinates { molid bbb pair start end vec step_size helix_type } {

  global pi

  set distances {}
  set basis {}
  for { set index [lindex $pair 0] } { $index <= [lindex $pair 1] } { incr index } {
    # vector between 'start' point and residue (hypotenuse of the triangle formed by the 'start' point, the 'projection' point and the residue itself)
    set residue [bead_coordinates $molid $bbb $index]
    set hypotenuse [vector $start $residue]
    # cosine of angle between the vector AB and AC
    set cosangle [vecdot [vecnorm $vec] [vecnorm $hypotenuse]]
    # distance between the 'start' point and the projection
    set distance [expr [veclength $hypotenuse]*$cosangle]
    # the 'projection' point
    set projection [vector [vecnorm $vec] $start $distance]
    lappend distances [list [veclength [vector $start $projection]] [veclength [vector $projection $residue]] $projection]
    # orthonormal basis at this point:
    # vector 'i' = vector colinear to the director of the helix
    # vector 'j' = vector linking the 'projection' point to the backbone of the residue
    # vector 'k' = vector perpendicular to the previous vectors (useless in helix case, but needed to draw sheets)
    lappend basis [orthonormal_basis 0 $bbb {} $vec [vector $projection $residue]]
  }

  set points {}
  if { $helix_type == "realhelix" } {
    for { set index 0 } { $index < [expr [llength $distances]-1] } { incr index } {
      # current/next basis
      set i [lindex [lindex $basis $index] 0]
      set j [vecinvert [lindex [lindex $basis $index] 1]]
      set next_j [vecinvert [lindex [lindex $basis [expr $index+1]] 1]]
      # current/next distances
      set distance_i [lindex [lindex $distances $index] 0]
      set distance_j [lindex [lindex $distances $index] 1]
      set next_distance_i [lindex [lindex $distances [expr $index+1]] 0]
      set next_distance_j [lindex [lindex $distances [expr $index+1]] 1]
      # coordinates of the projection (on vector 'i')
      set projection [lindex [lindex $distances $index] 2]
      # angle between two consecutive 'j' vectors
      set angle [expr acos([vecdot $j $next_j])*180.0/$pi]
      # define steps for each components
      set steps [expr round($angle/$step_size)+1]
      set angle_step [expr $angle/$steps]
      set distance_i_step [expr ($next_distance_i-$distance_i)/$steps]
      set distance_j_step [expr ($next_distance_j-$distance_j)/$steps]
      # let's draw!
      for { set step 0 } { $step < $steps } { incr step } {
        # set the new projection
        set new_projection [vector $i $start [expr $distance_i+($step*$distance_i_step)]]
        # set the new j
        set rotation_matrix_j [trans origin $new_projection axis $i [expr $step*$angle_step] deg]
        set new_j [vecnorm [vectrans $rotation_matrix_j $j]]
        # set the new point
        lappend points [vector $new_j $new_projection [expr $distance_j+($step*$distance_j_step)]]
      }
    }
  } elseif { $helix_type == "idealhelix" } {
    set average_radius 0.0
    set total_rotation 0.0
    for { set index 0 } { $index < [expr [llength $distances]-1] } { incr index } {
      # sum of radiuses
      set average_radius [expr $average_radius+[lindex [lindex $distances [expr $index+1]] 1]]
      # total rotation
      set j [vecinvert [lindex [lindex $basis $index] 1]]
      set next_j [vecinvert [lindex [lindex $basis [expr $index+1]] 1]]
      set total_rotation [expr $total_rotation+(acos([vecdot $j $next_j])*180.0/$pi)]
    }
    # set vectors
    set i [lindex [lindex $basis 0] 0]
    set j [vecinvert [lindex [lindex $basis 0] 1]]
    # average inner radius of the helix
    set average_radius [expr $average_radius/[llength $distances]]
    # define steps for each components
    set steps [expr round($total_rotation/$step_size)+1]
    set angle_step [expr $total_rotation/$steps]
    set distance_i_step [expr [veclength $vec]/$steps]
    # let's draw!
    for { set step 0 } { $step < $steps } { incr step } {
      # set the new projection
      set new_projection [vector $i $start [expr $step*$distance_i_step]]
      # set the new j
      set rotation_matrix_j [trans origin $new_projection axis $i [expr $step*$angle_step] deg]
      set new_j [vecnorm [vectrans $rotation_matrix_j $j]]
      # set the new point
      lappend points [vector $new_j $new_projection $average_radius]
    }
  }

  return $points

}



# compute and returns coordinates of an arrow
# 
# a flat arrow is defined by 7 points (14 points with thickness):
#
#                    2
#                    |`-
#  0-----------------1  `-
#  |                      `3
#  6-----------------5   -`
#                    | -`
#                    4`
#
# the initial vector (given in as argument) is linking the points
# half-way between 1 and 7 and 4
# 
proc flat_arrow_coordinates { molid bbb pair start end vec arrow_width head_size arrow_thickness } {

  global pi

  # small modifications of initial values
  set arrow_width [expr $arrow_width/2.0]
  set head_size [expr $head_size/2.0]
  set arrow_thickness [expr $arrow_thickness/2.0]
  set body_start $start
  set head_end $end
  # equilibrate the head size and remove the body from the head (explicit, isn't it?)
  set triangle_size [expr $head_size/sin($pi/3.0)]
  set body_end [vector $vec $end -$triangle_size]

  # points
  set points {}
  set points_over {}
  set points_under {}

  # basis
  set basis [orthonormal_basis $molid $bbb $pair $vec]
  set i [lindex $basis 0]
  set j [lindex $basis 1]
  set k [lindex $basis 2]

  # points, from 0 to 6
  lappend points [vector $j $body_start $arrow_width]
  lappend points [vector $j $body_end $arrow_width]
  lappend points [vector $j $body_end $head_size]
  lappend points $head_end
  lappend points [vector $j $body_end -$head_size]
  lappend points [vector $j $body_end -$arrow_width]
  lappend points [vector $j $body_start -$arrow_width]

  # points over and under (respectively)
  foreach point $points {
    lappend points_over [vector $k $point $arrow_thickness]
    lappend points_under [vector $k $point -$arrow_thickness]
  }

  return [list $points $points_over $points_under]

}



# draw a sheet, ribbon-like representation
proc sheet_coordinates { molid bbb pair start end vec step_size } {

  global pi

  set middles {}
  set basis {}
  for { set index [lindex $pair 0] } { $index <= [lindex $pair 1] } { incr index } {
    # middle of the vector linking the middle of two consecutive bonds
    set previous_residue [bead_coordinates $molid $bbb [expr $index-1]]
    set residue [bead_coordinates $molid $bbb $index]
    set next_residue [bead_coordinates $molid $bbb [expr $index+1]]
    set vec1 [vector $previous_residue $residue]
    set vec2 [vector $residue $next_residue]
    set previous_middle [vector [vecnorm $vec1] $previous_residue [expr [veclength $vec1]/2.0]]
    set next_middle [vector [vecnorm $vec2] $residue [expr [veclength $vec2]/2.0]]
    set vec3 [vector $previous_middle $next_middle]
    set middle [vector [vecnorm $vec3] $previous_middle [expr [veclength $vec3]/2.0]]
    # point
    lappend middles $middle
    # normal to the plane formed by the three beads
    set normal [veccross [vecnorm [vector $residue $previous_residue]] [vecnorm [vector $residue $next_residue]]]
    # normals with the same direction
    if { [expr ($index-[lindex $pair 0])%2] != 0 } { set normal [vecinvert $normal] }
    # basis
    lappend basis [orthonormal_basis 0 $bbb {} $vec3 $normal]
  }

  set sheet_vectors {}
  set points {}
  for { set index 0 } { $index < [expr [llength $middles]-1] } { incr index } {
    # current/next middles
    set middle [lindex $middles $index]
    set next_middle [lindex $middles [expr $index+1]]
    set vector [vecnorm [vector $middle $next_middle]]
    # distance
    set distance [veclength [vector $middle $next_middle]]
    # current/next basis
    set i [lindex [lindex $basis $index] 0]
    set j [lindex [lindex $basis $index] 2]
    set new_j $j
    set next_i [lindex [lindex $basis [expr $index+1]] 0]
    set next_j [lindex [lindex $basis [expr $index+1]] 2]
    # angle between two consecutive 'i' vectors
    set angle_i [expr acos([vecdot $i $next_i])*180.0/$pi]
    # angle between two consecutive 'j' vectors
    set angle_j [expr acos([vecdot $j $next_j])*180.0/$pi]
    # define steps for each components
    set steps [expr round($distance/$step_size)+1]
    set distance_step [expr $distance/$steps]
    set angle_i_step [expr $angle_i/$steps]
    set angle_j_step [expr $angle_j/$steps]
    # let's draw!
    for { set step 0 } { $step < $steps } { incr step } {
      # set the new point
      set new_middle [vector $vector $middle [expr $step*$distance_step]]
      lappend points $new_middle
      # set the new vector 'i'
      set rotation_matrix_i [trans origin $new_middle axis $new_j [expr $step*$angle_i_step] deg]
      set new_i [vecnorm [vectrans $rotation_matrix_i $i]]
# # angle step size for vector 'j'
# set angle_j [expr acos([vecdot $new_j $next_j])*180.0/$pi]
# set angle_j_step [expr $angle_j/($steps-$step)]
      # set the new vector 'j'
      set rotation_matrix_j [trans origin $new_middle axis $new_i [expr $step*$angle_j_step] deg]
      set new_j [vecnorm [vectrans $rotation_matrix_j $j]]
# set rotation_matrix_j [trans origin $new_middle axis $new_i $angle_j_step deg]
# set new_j [vecnorm [vectrans $rotation_matrix_j $new_j]]
      lappend sheet_vectors $new_j
    }
  }

  return [list $points $sheet_vectors]

}



# coordinates of starting/ending "flat cones"
proc flat_cone { vecnorm flat_cone_start flat_cone_end width thickness } {

  # totally flat cone (triangle)
  set corner1 [vector $vecnorm $flat_cone_start [expr -$width/2.0]]
  set corner2 [vector $vecnorm $flat_cone_start [expr $width/2.0]]
  set corner3 $flat_cone_end

  # normal to the plane formed by the previous points
  set normal [veccross [vecnorm [vector $corner1 $corner3]] [vecnorm [vector $corner2 $corner3]]]

  # scaled thickness of the cone
  set scaled_thickness [expr $thickness+($thickness/3.0)]

  # coordinates of a less flat cone :-)
  set points {}
  lappend points $corner1
  lappend points $corner2
  lappend points $corner3
  lappend points [vector $normal $corner1 -$scaled_thickness]
  lappend points [vector $normal $corner2 -$scaled_thickness]
  lappend points [vector $normal $corner3 -$scaled_thickness]
  lappend points [vector $normal $corner1 $scaled_thickness]
  lappend points [vector $normal $corner2 $scaled_thickness]
  lappend points [vector $normal $corner3 $scaled_thickness]

  # points
  return $points

}



# compute a vector from two points, with multiplier if provided: [vector $start $end (2.5) (1.4)]
# apply a vector to a point: [vector $vector $point (1.2) (1)]
proc vector { start end { a -1 } { b 1 } } {
  set u1 [expr $b*[lindex $end 0]+$a*[lindex $start 0]]
  set u2 [expr $b*[lindex $end 1]+$a*[lindex $start 1]]
  set u3 [expr $b*[lindex $end 2]+$a*[lindex $start 2]]
  return [list $u1 $u2 $u3]
}



# compute orthonormal basis
proc orthonormal_basis { molid bbb pair i { j "False" } } {

  # i
  set i [vecnorm $i]

  # j (not orthogonal to i)
  if { $j == "False" } {
    set res1 [lindex $pair 0]
    set res2 [expr $res1+1]
    set res4 [lindex $pair 1]
    set res3 [expr $res4-1]
    set atom1 [bead_coordinates $molid $bbb $res1]
    set atom2 [bead_coordinates $molid $bbb $res2]
    set atom3 [bead_coordinates $molid $bbb $res3]
    set atom4 [bead_coordinates $molid $bbb $res4]
    set u1 [expr [lindex $atom2 0]-[lindex $atom1 0]]
    set u2 [expr [lindex $atom2 1]-[lindex $atom1 1]]
    set u3 [expr [lindex $atom2 2]-[lindex $atom1 2]]
    set v1 [expr [lindex $atom4 0]-[lindex $atom3 0]]
    set v2 [expr [lindex $atom4 1]-[lindex $atom3 1]]
    set v3 [expr [lindex $atom4 2]-[lindex $atom3 2]]
    set j [list [expr $u1+$v1] [expr $u2+$v2] [expr $u3+$v3]]
    set j [vecnorm $j]
  # j (orthogonal to i)
  } else {
    set j [vecnorm $j]
  }

  # k (orthogonal to i and j)
  set k [veccross $i $j]

  # j (orthogonal to i and k)
  set j [veccross $i $k]

  # return basis
  return [list $i $j $k]

}



# calculate the principal axes of an object (a bead selection corresponding to a helix/sheet)
# initially written by Martti, modified by Clement to add routines from Paul's "Orient" package
proc compute_orientation { molid bbb pair } {

  # select involved residues
  set start [lindex $pair 0]
  set end [lindex $pair 1]
  set residues [atomselect $molid "resid >= $start and resid <= $end and name $bbb"]
  set selXs [$residues get x]
  set selYs [$residues get y]
  set selZs [$residues get z]
  set masses [$residues get mass]

  ### BEGIN of stuff extracted from the package "Orient" ###

  # center of mass (geometrical barycenter)
  set com [list 0.0 0.0 0.0]
  set total_mass 0.0
  foreach x $selXs y $selYs z $selZs mass $masses {
    set com [list [expr [lindex $com 0]+$mass*$x] [expr [lindex $com 1]+$mass*$y] [expr [lindex $com 2]+$mass*$z]]
    set total_mass [expr $total_mass+$mass]
  }
  set com [list [expr [lindex $com 0]/$total_mass] [expr [lindex $com 1]/$total_mass] [expr [lindex $com 2]/$total_mass]]

  # orientation matrix
  set xx 0.0
  set xy 0.0
  set xz 0.0
  set yy 0.0
  set yz 0.0
  set zz 0.0
  foreach x $selXs y $selYs z $selZs mass $masses {
    set x [expr $x-[lindex $com 0]]
    set y [expr $y-[lindex $com 1]]
    set z [expr $z-[lindex $com 2]]
    set xx [expr $xx+$mass*($y*$y+$z*$z)]
    set xy [expr $xy-$mass*($x*$y)]
    set xz [expr $xz-$mass*($x*$z)]
    set yy [expr $yy+$mass*($x*$x+$z*$z)]
    set yz [expr $yz-$mass*($y*$z)]
    set zz [expr $zz+$mass*($x*$x+$y*$y)]
  }
  set inmatrix [list 2 3 3 $xx $xy $xz $xy $yy $yz $xz $yz $zz]
  # calculate eigenvectors
  set matrix [exec python3 eigen.py $inmatrix]

  set eigenvectors [list [list [lindex $matrix 3] [lindex $matrix 6] [lindex $matrix 9]] [list [lindex $matrix 4] [lindex $matrix 7] [lindex $matrix 10]] [list [lindex $matrix 5] [lindex $matrix 8] [lindex $matrix 11]]]

  ### END of stuff extracted from the package "Orient" ###

  # determine parallel eigenvector
  set coordinates [$residues get { x y z }]
  set n [$residues num]
  set a [lindex $coordinates 0]
  set b [lindex $coordinates [expr $n-1]]
  set q [vecsub $a $b]
  set l1 [vecdot $q [lindex $eigenvectors 0]]
  set l2 [vecdot $q [lindex $eigenvectors 1]]
  set l3 [vecdot $q [lindex $eigenvectors 2]]
  if {[expr abs($l1)] > [expr abs($l2)]} {
    if {[expr abs($l1)] > [expr abs($l3)]} {
      set index 0
    } else {
      set index 2
    }
  } else {
    if {[expr abs($l2)] > [expr abs($l3)]} {
      set index 1
    } else {
      set index 2
    }
  }
  set ev [vecnorm [lindex $eigenvectors $index]]
  set ls [list $l1 $l2 $l3]
  if { [lindex $ls $index] < 0} { set ev [vecscale -1 $ev] }

  # scale parallel unitvector to half length
  set l [veclength $q]
  set l [expr $l/2]

  # calculate termini of the director
  set r [vecscale $ev $l]
  set start [vecadd $com $r]
  set end [vecsub $com $r]

  # calculate vector of the director
  set vec [vector $start $end]
  
  return [list $start $end $vec]

}



# deletes all graphics
proc cg_dag { args } { cg_delete_all_graphics $args }
proc cg_delete_all_graphics { args } {
  set args [join $args]
  set args [split $args]

  # parses argument
  set molid "top"
  foreach { n m } $args { if { $n == "-molid" } { set molid $m } }

  # deletes cylinders
  graphics $molid delete all

  # update display
  display update

}



# first load
cg_secondary_structure_usage
