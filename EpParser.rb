#!/usr/bin/env ruby

require 'pp'
require 'yaml'

class EP_Parser

  def parse_idd(input,flag)
    @str = input
    @groups = {}
    strip_comments
    strip_head
    groups = break_into_groups
    groups.each do |group|
      group_name = group.slice!(/.+\n/).strip
      oh = {}
      objects = break_at_newlines(group,2)
      objects.each do |obj|
        fh = {}
        fields = break_at_fields(obj)
        obj_name_field = fields.shift
        obj_name = obj_name_field.first
        field_hash = enhash_fields(fields)
        field_hash["__self__"] = enhash_fields(Array.new.push(obj_name_field))[obj_name]
        oh["#{obj_name}"] = field_hash
      end
      @groups["#{group_name}"] = oh
    end
    File.open( "Energy+.idd.yml", 'w' ) { |output| output << @groups.to_yaml } if flag
    puts @groups.to_yaml unless flag
  end
  
  def strip_comments
    @str.gsub!(/!.*\n/,'')
    @str.strip!
  end
  
  def strip_head
    @str.sub!(/Lead Input;\n/,'')
    @str.sub!(/Simulation Data;\n/,'')
    @str.strip!
  end
  
  def break_into_groups
    arr = @str.split(/^\\group /i)
    arr.delete_if {|item| item.empty?} 
    arr
  end
  
  def break_at_newlines(str,num_newlines=1)
    arr = str.split(Regexp.new("\n{#{num_newlines}}"))
    arr.delete_if {|item| item.empty? || item.strip.empty?} 
    arr
  end
  
  def break_at_fields(str)
    arr = []
    str.lines.each do |line|
      line.strip!
      in_var = true
      while !line.empty?
        varholder = ""
        comment = ""
        line.each_char do |char|
          if in_var && char.start_with?(',',';')
            line.slice!(0)
            break
          elsif char == "\\"
            in_var = false
          end
          varholder << char if in_var
          comment << char if (!in_var && char != "\\")
          line.slice!(0)
        end
        varholder.strip!
        if !varholder.empty?
          v = []
          c = []
          v.push(varholder)
          v.push(c)
          arr.push(v)
        end
        arr.last.last.push(comment) if !comment.empty?
      end
    end
    arr
  end
  
  # The array passed as input looks like:
  # [
  #   [A1, ["field Name","note First note","note Second note"]],
  #   [A2, ["field Zone List", "blah Blah"]],
  #   etc.
  # ]
  #
  # Output looks like:
  #
  # {
  #   "Name" => {"type"=>"A","notes"=>["First note","Second note"]},
  #   "Zone List" => {"type"=>"A","blah"=>"Blah"},
  #   etc.
  # }
  def enhash_fields( fields )
    fh = {}
    array_props = ['note','memo','key','object-list','reference','reference-class-name']
    fields.each do |field|
      props = field.last
      ph = {}
      # set prop type based on A or N. This strips out the digits next to A or N
      ph['vartype'] = field.first.sub(/\d+/,'')
      name = get_name(field.first,props)
      # The items in array props decalre properties whose values must be stored 
      # in an array because the idd grammar allows multiple entries of each
      array_props.each do |ap|
        vals = get_array_prop( props, ap )
        ph[ap] = vals if !vals.empty?
      end
      # Get all remaining properties. These should be unique.
      props.each do |prop| 
        pname = prop.slice!(/\w+-?\w*/).strip
        # Strip whitespace and downcase the E in numbers like 1.E-4, also add 
        # a 0 before the . in numbers like 1.E-4
        ph[pname] = prop.strip.gsub(/(\d+)\.(\d*)E([-\+])(\d)/,'\1.\20e\3\4')
      end
      fh[name] = ph
    end
    fh
  end
  
  
  def get_name( default_name, props )
      # start off with a default name based on the Ax or Nx field delim. from idd
      name = default_name
      # check for a 'field' property which will give a proper name    
      props.each {|prop| name = prop.sub(/^field/,'').strip if prop =~ /^field/}
      # remove the 'field' property from the props array
      props.delete_if {|prop| prop =~ /^field/ }
      name
  end
  
  def get_array_prop( props, pname )
    values = []
    patt = Regexp.new("^#{pname}")
    props.each do |prop|
      if prop =~ patt
        values.push( prop.sub(patt,'') )
      end
    end
    props.delete_if {|prop| prop =~ patt}
    values
  end
  
end #class


test = %q@

\group Thermal Zones and Surfaces

ZoneList,
       \memo Defines a list of thermal zones which can be referenced as a group. The ZoneList name
       \memo may be used elsewhere in the input to apply a parameter to all zones in the list.
       \memo ZoneLists can be used effectively with the following objects: People, Lights,
       \memo ElectricEquipment, GasEquipment, HotWaterEquipment, ZoneInfiltration:DesignFlowRate,
       \memo ZoneVentilation:DesignFlowRate, Sizing:Zone, ZoneControl:Thermostat, and others.
       \min-fields 2
       \extensible:1 - repeat last field, remembering to remove ; from "inner" fields.
  A1 , \field Name
       \note Name of the Zone List
       \note Second note
       \boozoo 7 5 4
       \required
  A2 , \field Zone 1 Name
  A102,A103,A104; \note fields as indicated
  
\group Compliance Objects

Compliance:Building,
       \memo Building level inputs related to compliance to building standards, building codes, and beyond energy code programs.
       \unique-object
       \min-fields 1
  N1;  \field Building Rotation for Appendix G
       \note Additional degrees of rotation to be used with the requirement in ASHRAE Standard 90.1 Appendix G
       \note that states that the baseline building should be rotated in four directions.
       \units deg
       \type real
       \default 0.0
@

test = File.read('Energy+.idd') if ARGV[0] == 'file'
epp = EP_Parser.new
epp.parse_idd(test, ARGV[0])
