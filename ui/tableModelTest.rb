#!/usr/bin/env ruby

require 'Qt'
require './idd.rb'

#monkey-patch String
class String
  def is_integer?
    Integer(self)
    true 
  rescue 
    false
  end

  def is_float?
    Float(self)
    true 
  rescue 
    false
  end
end

class DataModel

# @data is a hash of arrays of arrays, like so:
# {
#   "first_class" : [[obj1_1,obj1_2],[obj2_1,obj2_2],[obj3_1,obj3_2]],
#   "second_class" : [[obj1_1,obj1_2],[obj2_1,obj2_2],[obj3_1,obj3_2]]
# }
# 
# The current class within the hash on which all operations will be performed
# is set via set_class. Column refers to obj1, obj2, obj3, etc. and row
# refers to each value within an object: obj1_1, obj1_2, etc.
#
# @dict hold the data dictionary from which we can get allowed values, types,
# number of rows, headers, etc.

  def initialize( idd_hash, data )
    @data = data
    @dict = {}
    # Remove the "group" layer from the hash, leaving just a collection of
    # objects.
    idd_hash.each_key {|key| @dict.merge!(idd_hash.delete(key)) }
  end

  def set_class( clas )
    @class = clas
  end
  
  def row_count
    # subtract 1 to take the __self__ "row" into account. It's always at the
    # end of each class's hash, so it will never be queried.
    return @dict[@class].size - 1
  end
  
  def column_count
    return @data[@class].size
  end
  
  def get_data( row, col )
    objs = @data[@class]
    return nil if (!objs || objs.empty?)
    return nil if col >= objs.size
    obj = objs[col]
    return nil if (obj.empty? || row >= obj.size )
    return obj[row]
  end
  
  def set_data( row, col, value )
    objs = @data[@class]
    return nil if (!objs || objs.empty?)
    return nil if col >= objs.size
    obj = objs[col]
    return nil if (obj.empty? || row >= obj.size )
    obj[row] = value
    return nil
  end
  
end



class ViewModel < Qt::AbstractTableModel

#  def initialize
#    super
#    #@table = [[1,2.6,3],[4,5,6],[7,8,9],[10,11,12],["one","two","three"],[true,false,true]]
#  end
  
  def rowCount( parent = Qt::ModelIndex.new )
    return @data.row_count
  end
  
  def columnCount( parent = Qt::ModelIndex.new )
    return @data.column_count
  end
  
  def data( index, role = Qt::DisplayRole )
    return Qt::Variant.new if !index.isValid
    return Qt::Variant.new if index.row >= rowCount
    return Qt::Variant.new if index.column >= columnCount
    return Qt::Variant.new if (role != Qt::DisplayRole) && (role != Qt::EditRole)
    return Qt::Variant.new( @data.get_data(index.row,index.column) )
  end
  
  def flags( index )
    return Qt::ItemIsEnabled if !index.isValid
    return super(index) | Qt::ItemIsEditable
  end
  
  def setData( index, value, role = Qt::EditRole )
    if (index.isValid && role == Qt::EditRole)
      case value.type
      when Qt::MetaType::Double
        value = value.toDouble
      when Qt::MetaType::Bool
        value = value.toBool
      else
        value = value.toString
      end
      @data.set_data(index.row,index.column,value)
      dataChanged(index,index)
      return true
    end
    return false
  end
  
  def set_data_model( model )
    @data = model
  end
  
end



class Choicer

  def initialize
    @choices = {}#{'2'=>["7","8","9"],'3'=>["hog","bog","dog","log","cog","fog","gog","jog","nog","sog","tog"]}
  end

  def has_choices_for_row( row )
    return true if @choices.has_key? row.to_s
    return false
  end

  def choices_for_row( row )
    return @choices[row.to_s]
  end

end



class ComboDelegate < Qt::ItemDelegate

  def set_choicer( choicer )
    @ch = choicer  
  end
  
  def createEditor( parent, option, index )
    if( @ch.has_choices_for_row( index.row) )
      combobox = Qt::ComboBox.new( parent )
      combobox.addItems( @ch.choices_for_row( index.row ) )
      return combobox
    else
      return super
    end
  end
  
end


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
  
# Split each object on commas and fill out the names and 
# all_parameters arrays
  def split_objects(ary)
    obj_hash = {}
    ary.each do |line|
      params = line.split(',')
      params.each {|p| p.strip!} #Ensure padding whitespace is removed from each entry
      name = params[0]
      obj_hash[name] = Array.new if !obj_hash.has_key?(name)
      params = params.drop(1)
      params.map! do |param|
        #if param.is_integer?
          #param.to_f
        if param.is_float?
          param.to_f
        else
          param
        end
      end
      obj_hash[name].push(params)
    end
    return obj_hash
  end

def parse_idf( fname )
  input = File.readlines(fname)
  strip_comments(input)
  remove_blank_lines(input)
  lines = form_object_lines(input)
  return split_objects(lines)
end



app = Qt::Application.new(ARGV)
idd = IDD.new.idd
idf = parse_idf('700ppm.idf')
data = DataModel.new(idd, idf)
data.set_class('SizingPeriod:DesignDay')
vm = ViewModel.new
vm.set_data_model( data )
v = Qt::TableView.new
c = Choicer.new
d = ComboDelegate.new
d.set_choicer( c )
v.setItemDelegate( d )
v.setModel(vm)
v.show
v.resize(800, 900)
app.exec
