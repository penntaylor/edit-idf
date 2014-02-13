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

#module EditIDF

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
# @idd hold the data dictionary from which we can get allowed values, types,
# number of rows, headers, etc.

  def initialize( idd, data )
    idd_hash = idd.clone
    @data = data
    @idd = {}
    # Remove the "group" layer from the hash, leaving just a collection of
    # objects.
    idd_hash.each_key {|key| @idd.merge!(idd_hash.delete(key)) }
    @class = ''
    @v_headers = []
  end

  def set_class( clas )
    @class = clas
    # Form the row headers for this class
    @v_headers.clear
    fields = @idd[@class].reject{|key| key=='__self__'}
    fields.each do |field|
      header_text = field.first
      header_text += field.last.has_key?('units') ?
                     " (#{field.last['units']})" : ''
      @v_headers.push(header_text)
    end
  end
  
  def row_count
    return 0 if @class.empty?
    return 0 if !@idd.has_key?(@class)
    # subtract 1 to take the __self__ "row" into account. It's always at the
    # end of each class's hash, so it will never be queried.
    return @idd[@class].size - 1
  end
  
  def column_count
    return 0 if @class.empty?
    return 0 if !@data.has_key?(@class)
    return @data[@class].size
  end
  
  def get_data( row, col )
    return nil if @class.empty?
    objs = @data[@class]
    return nil if (!objs || objs.empty?)
    return nil if col >= objs.size
    obj = objs[col]
    return nil if (obj.empty? || row >= obj.size )
    return obj[row]
  end
  
  def set_data( row, col, value )
    return nil if @class.empty?
    objs = @data[@class]
    return nil if (!objs || objs.empty?)
    return nil if col >= objs.size
    obj = objs[col]
    return nil if (obj.empty? || row >= obj.size )
    obj[row] = value
    return nil
  end

  def get_header(section, orientation, role)
    return @v_headers[section] if orientation == Qt::Vertical && role == Qt::DisplayRole
    return nil
  end

  def get_default(row)
    return nil if @class.empty?
    defv = @idd[@class].values[row].has_key?('default') ?
           @idd[@class].values[row]['default'] : 'NONE'
    return defv
  end
  
end



class ViewModel < Qt::AbstractTableModel
  
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
    return Qt::Variant.new( "Default: #{@data.get_default(index.row)}" ) if role == Qt::ToolTipRole
    return Qt::Variant.new if (role != Qt::DisplayRole) && (role != Qt::EditRole)
    return Qt::Variant.new( @data.get_data(index.row,index.column) )
  end

  def headerData (section, orientation, role = Qt::DisplayRole)
    return Qt::Variant.new(@data.get_header(section, orientation, role))
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
      when Qt::MetaType::Int
        value = value.toInt
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

  def beginResetModel
    super
  end

  def endResetModel
    super
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


class IdfParser

  def initialize(idd)
    idd_hash = idd.clone
    @idd = {}
    # Remove the "group" layer from the hash, leaving just a collection of
    # objects.
    idd_hash.each_key {|key| @idd.merge!(idd_hash.delete(key)) }
  end

  protected
  # Strip out all comments from the input
  def strip_comments(ary)
    ary.each do |line|
      comment = line.index('!')
      line.slice!(comment,line.length) if comment
      line.strip!
    end
  end

  protected
  # Remove all blank lines
  def remove_blank_lines(ary)
    ary.delete_if do |line|
      line.empty?
    end
  end

  protected
  # Join all lines and then split on semicolons, which represent
  # object boundaries
  def form_object_lines(ary)  
    oneline = ary.join
    return oneline.split(';')
  end

  protected
  # Split each object on commas and fill out the names and 
  # all_parameters arrays
  def split_objects(ary)
    obj_hash = {}
    ary.each do |line|
      params = line.split(',')
      params.each {|p| p.strip!}
      name = params[0]
      obj_hash[name] = Array.new if !obj_hash.has_key?(name)
      params = params.drop(1)
      params.map!.with_index do |param,idx|
        field = @idd[name].values[idx]
        if field['vartype'] == 'N'
          if field.has_key?('type') && field['type'] == 'integer'
            param.to_i
          else
            param.to_f
          end
        else
         param
        end
      end
      obj_hash[name].push(params)
    end
    return obj_hash
  end

  public
  def parse_idf( fname )
    input = File.readlines(fname)
    strip_comments(input)
    remove_blank_lines(input)
    lines = form_object_lines(input)
    return split_objects(lines)
  end

end

#end
