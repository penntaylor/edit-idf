#!/usr/bin/env ruby

# This program expands paramters from an input file to create output
# that can be pasted into an idf file for an exhaustive (discrete) search of 
# the parameter space

require './Extract_Parameters.rb'

inputFile = ARGV[0]

# Handle error conditions related to file's non-existence or lack of file
# argument
# ...

# Read inputFile in as an array of strings
input = File.readlines( inputFile )

# Use an Extract_Parameters object to parse the input and get back an array
# with the names of the parametric variables and a second array with all
# the values of each parameter
parser = Extract_Parameters.new(input)
*allParams = parser.all_parameters
names = parser.names


######### Exhaustive Search ######### 
# Form all possible permutations of the parameters for an exhaustive search
head, *rest = allParams
permutations = head.product(*rest)

# Turn the permutations into N arrays where N is the number of objects. each
# array will contain exactly the parameter sequence needed to form a proper
# idf paramater statement
allParams.clear
allParams = Array.new(names.count){Array.new(1)}
permutations.each do |perm|
  perm.each_with_index do |param,index|
    allParams[index].push(param)
  end
end

allParams.each_with_index do |obj,index|
  objStr = "Parameter:SetValueForRun,#{names[index]}#{obj.join(',')};"
  #puts objStr
end
######### End Exhaustive Search ######### 


######### Series of isolated parameters ######### 
# This block takes a set of N variables and outputs N files. Each file 
# explores only a single parameter dimension, and holds all other parameters 
# constant at their first setting.
filehash = {}
*allParams = parser.all_parameters
allParams.size.times do |count|
  newparams = []
  allParams.each_with_index do |ary,index|
    if index != count
      length = allParams[count].size
      newparams.push(Array.new(length,ary[0]))
    else
      newparams.push(ary)
    end
  end
  filehash.store(names[count],newparams)
end

filehash.each do |primary,params|
  puts primary + ':'
  output = String.new
  params.each do |pary|
    output += "Parameter:SetValueForRun,\n    "
    output += pary.join(",\n    ")
    output += ";\n\n"
  end
  puts output
end
######### End Series of isolated parameters #########
