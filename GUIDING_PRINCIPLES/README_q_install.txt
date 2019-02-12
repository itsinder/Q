q_install.sh:
This script does all the installations(packages, libraries) required to run/use Q.

Usage of q_install.sh:
bash q_install.sh < |dbg|doc|qli|test>

Modes:
For now there are 5 modes in which Q can be installed:

Sr.no | Mode name     | Mode usage
-----------------------------------------
1.    | not specified | normal basic Q mode  #TODO: we can have mode-name as "basic/normal" instead of nil argument
2.    | dbg           | debugging mode
3.    | doc           | documenting mode
4.    | qli           | qcli mode
5.    | test          | testing mode

TODOs:
1. q_install can be supported with "all" mode, in which it will support all above 5 modes.
2. once penlight dependencies are removed from Q built files, it can be removed from q_required_packages.sh
