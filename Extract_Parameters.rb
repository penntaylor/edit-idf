
# Class that parses array of strings passed in the constructor to 
# extract information about Parameter objects. After parsing, the
# names member will contain the names of the parameter variables,
# and the all_parameters member will contain a two-dimensional array
# of all parameter values. The index into the names array matches the
# index into the all_parameters array.
class Extract_Parameters

  attr_accessor :names
  attr_accessor :all_parameters

  # Strip out all comments from the input
  def strip_comments(ary)
    ary.each do |line|
      comment = line.index('!-')
      line.slice!(comment,line.length) if comment
      line.strip!
    end
  end
  
  # Remove all blank lines
  def remove_blank_lines(ary)
    ary.delete_if do |line|
      line.empty?
    end
  end
  
  # Join all lines and then split on semicolons, which represent
  # object boundaries
  def form_object_lines(ary)  
    oneline = ary.join
    return oneline.split(';')
  end
  
  # Remove any objects that are not Parametric:SetValueForRun objects
  def remove_extraneous(ary)
    ary.delete_if do |line|
      line.index('Parametric:SetValueForRun') != 0
    end
  end
  
  # Split each object on commas and fill out the names and 
  # all_parameters arrays
  def split_objects(ary)
    @names = []
    @all_parameters = []
    ary.each do |line|
      params = line.split(',')
      params.each {|p| p.strip!} #Ensure padding whitespace is removed from each entry
      name = params[1]
      params = params.drop(2)
      @names.push(name)
      @all_parameters.push(params)
    end
  end
  
  # Constructor
  def initialize(input)
    @names = []
    @all_parameters = []
    strip_comments(input)
    remove_blank_lines(input)
    lines = form_object_lines(input)
    remove_extraneous(lines)
    split_objects(lines)
  end
 
end
