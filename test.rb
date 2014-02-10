#!/usr/bin/env ruby

require 'yaml'

s = YAML.load(File.read('idd.yaml'))
puts s['Thermal Zones and Surfaces']['ZoneList']
