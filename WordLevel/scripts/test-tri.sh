#!/bin/ksh
HVite -p 0 -t 0 -s 0 -A -T 1 -H /WordLevel/models/hmm0.19/newMacros -w /WordLevel/word.lattice -S /WordLevel/testsets/testing-extfiles0-walking -I /WordLevel/mlf/walking/labels.mlf_tri_internal -i /WordLevel/ext/result.mlf_letter0 /WordLevel/dict/dict_tri2letter /WordLevel/commands/commands_tri_internal
HResults -A -T 1 -t -I /WordLevel/mlf/walking/labels.mlf_letter -p /WordLevel/commands/commands_letter_isolated /WordLevel/ext/result.mlf_letter0 > hresults.log_walking_letter_tri

HVite -p 0 -s 0 -A -T 1 -H /WordLevel/models/hmm0.19/newMacros -w /WordLevel/word.lattice_word -S /WordLevel/testsets/testing-extfiles0-walking -I /WordLevel/mlf/walking/labels.mlf_tri_internal -i /WordLevel/ext/result.mlf_word0 -n 4 20 /WordLevel/dict/dict_letter2word /WordLevel/commands/commands_tri_internal 
HResults -A -T 1 -t -I /WordLevel/mlf/walking/labels.mlf_word /WordLevel/commands/commands_word_isolated /WordLevel/ext/result.mlf_word0 > hresults.log_walking_word_tri
