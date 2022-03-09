#!/bin/ksh
##################################################################
# All code in the project is provided under the terms specified in
# the file "Public Use.doc" (plaintext version in "Public Use.txt").
#
# If a copy of this license was not provided, please send email to
# haileris@cc.gatech.edu
##################################################################

##############################################################################
#
# USER MODIFICATION SECTION -- user specific files
#
##############################################################################
						######      Comments     #####
						##############################
						#
PRJ=`pwd`	# path to the current project
SCRIPTS_DIR=$PRJ/scripts			# location of scripts directory
						# for this project.
						#
UTIL_DIR=/gt2k/utils			# location of utils directory
						#
						#
VECTOR_LENGTH=16				# number of elements in your
						# feature vector. This is the
						# number of observations per
						# state for the HMMs.
						#
MIN_VARIANCE=1e-2				# don't let the
						# variance fall below
						# this value during
						# HMM training
HMM_TOPOLOGY_DIR=${PRJ}/hmmdefs

# general HMM_TOPOLOGIES
HMM_LOCATION=$HMM_TOPOLOGY_DIR/1state-16pca	#text hmm topology file
HMM_ALL=$HMM_LOCATION

# specific HMM_TOPLOGIES
#
SPECIFIC=no

HMM_TOKEN_A=$HMM_TOPOLOGY_DIR/submission_topologies/A
HMM_TOKEN_B=$HMM_TOPOLOGY_DIR/submission_topologies/B
HMM_TOKEN_C=$HMM_TOPOLOGY_DIR/submission_topologies/C
HMM_TOKEN_D=$HMM_TOPOLOGY_DIR/submission_topologies/D
HMM_TOKEN_E=$HMM_TOPOLOGY_DIR/submission_topologies/E
HMM_TOKEN_F=$HMM_TOPOLOGY_DIR/submission_topologies/F
HMM_TOKEN_G=$HMM_TOPOLOGY_DIR/submission_topologies/G
HMM_TOKEN_H=$HMM_TOPOLOGY_DIR/submission_topologies/H
HMM_TOKEN_I=$HMM_TOPOLOGY_DIR/submission_topologies/I
HMM_TOKEN_J=$HMM_TOPOLOGY_DIR/submission_topologies/J
HMM_TOKEN_K=$HMM_TOPOLOGY_DIR/submission_topologies/K
HMM_TOKEN_L=$HMM_TOPOLOGY_DIR/submission_topologies/L
HMM_TOKEN_M=$HMM_TOPOLOGY_DIR/submission_topologies/M
HMM_TOKEN_N=$HMM_TOPOLOGY_DIR/submission_topologies/N
HMM_TOKEN_O=$HMM_TOPOLOGY_DIR/submission_topologies/O
HMM_TOKEN_P=$HMM_TOPOLOGY_DIR/submission_topologies/P
HMM_TOKEN_Q=$HMM_TOPOLOGY_DIR/submission_topologies/Q
HMM_TOKEN_R=$HMM_TOPOLOGY_DIR/submission_topologies/R
HMM_TOKEN_S=$HMM_TOPOLOGY_DIR/submission_topologies/S
HMM_TOKEN_T=$HMM_TOPOLOGY_DIR/submission_topologies/T
HMM_TOKEN_U=$HMM_TOPOLOGY_DIR/submission_topologies/U
HMM_TOKEN_V=$HMM_TOPOLOGY_DIR/submission_topologies/V
HMM_TOKEN_W=$HMM_TOPOLOGY_DIR/submission_topologies/W
HMM_TOKEN_X=$HMM_TOPOLOGY_DIR/submission_topologies/X
HMM_TOKEN_Y=$HMM_TOPOLOGY_DIR/submission_topologies/Y
HMM_TOKEN_Z=$HMM_TOPOLOGY_DIR/submission_topologies/Z























# whether or not to initialize the starting model in a generic way:
INITIALIZE_HMM=yes				# if you have a good initial
						# guess at your model as your
						# starting HMM, say no here.
						# otherwise, it is better
						# to let HTK initialize for you

						#
GEN_TRAIN_TEST=no				# whether or not to generate
						# new test/train sets. if
						# you have made your own
						# or wish to reuse old sets,
						# set this to no.  otherwise
						# yes.

TRAIN_TEST_VALIDATION="K_FOLD"   		# "CROSS" or "LEAVE_ONE_OUT"
#TRAIN_TEST_VALIDATION="LEAVE_ONE_OUT"		# type of training/testing to
					    	# perform: cross-validation or
						# leave_one_out validation
VALIDATION_ITERATIONS=4			    	#
MLF_LOCATION_ORIGINAL=${PRJ}/labels.mlf 


DATAFILES_LIST=${PRJ}/datafiles			# list of all data files
GRAMMARFILE=${PRJ}/grammar			# the grammar definition
DICTFILE=${PRJ}/dict
TOKENS=${PRJ}/commands				# list of grammar tokens
						#
						#
MLF_LOCATION=${PRJ}/labels.mlf			# master label file
						#
						#
GEN_EXT_FILES=no				# yes or no: generate .ext data
						# files (say yes unless they
						# have already been generated!

PREPARE_DATA=${UTIL_DIR}/prepare		# program for creating HTK-
						# readable data from text

EXT_DIR=${PRJ}/ext				# This is where HTK will put
						# .ext files it generates
						#
GEN_GRAMMAR=yes				# yes or no: generate grammar
						# and dict files using the
						# specified GRAMMAR_PROG program

GRAMMAR_PROG=${UTIL_DIR}/create_grammar.pl      # program to create a simple 
						# grammar and dict from a list
						# of commands

OUTPUT_MLF=${EXT_DIR}/result.mlf		# where HTK stores results
						# must be in the same dir as
						# .ext files
LOG_RESULTS=${PRJ}/hresults.log
						#
AUTO_ESTIMATE=yes				# Allow HTK to estimate gesture
						# boundaries for data with
						# multiple gestures per file.
						# Turning this off speeds up
						# training.
NUM_HMM_DIR=8					# number of hmm dirs to
						# generate, has a direct
						# relation to number of times
						# HERest is called
						#
HMM_TEMP_DIR=${PRJ}/models			# directory for storing
						# intermediate models during
						# iterations of training

HMM_TRAINING=${HMM_TEMP_DIR}/hmm		# base name for iterations of
						# HMM training.  will be a 
						# a directory with .# appended
						# to it where # is the
						# iteration of HERest 
						#
# WARNING: files in directory with this		#
# 	   basename will be erased!!		#
#
#  rm -f $TRAINING_BASENAME*
TRAINING_DIR=${PRJ}/trainsets
TRAINING_BASENAME="${TRAINING_DIR}/training-extfiles"	# all lists of training files
						# will be named this with an
					    	# index number appended to it.
# WARNING: files in directory with this		#
# 	   basename will be erased!!		#
#
#  rm -f $TEST_BASENAME*
TESTING_DIR=${PRJ}/testsets
TESTING_BASENAME="${TESTING_DIR}/testing-extfiles"	# all lists of testing files
						# will be named this with an
					    	# index number appended to it.
						#
TRACE_LEVEL=1					# level of debugging
						#
${HTKBIN=}					# check to see if the path of
	#example:  ${HTKBIN=/usr/local/bin/}	# HTK is set as an environment
    						# variable if not, then use the
						# specified location.  
					    	# now it is set to NULL which
						# means that it will look in 
				   		# your path if left this way.
						# Be sure to include the 
						# trailing slash!
						#
PROMPT_B4_RM="yes"				# Prompt before removing files
						# that exist.  can be "yes",
						# "no", or "".  if the value
						# is "no" or "" then files will
						# overwritten without checking

