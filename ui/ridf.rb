#!/usr/bin/env ruby

require 'Qt'
require './ridf_ui.rb'
require 'yaml'
require 'pp'

class Test < Qt::MainWindow

  slots 'class_tree_item_selected(QTreeWidgetItem*,QTreeWidgetItem*)'
  slots 'obj_table_cell_clicked(int,int)'
  slots 'header_clicked(int)'
  slots 'expand(bool)'
  slots 'sort(bool)'
  
  def initialize
    super
    @ui = Ui::MainWindow.new
    @ui.setup_ui(self)
    connect(@ui.class_tree,
            SIGNAL('currentItemChanged(QTreeWidgetItem*,QTreeWidgetItem*)'),
            self,
            SLOT('class_tree_item_selected(QTreeWidgetItem*,QTreeWidgetItem*)'))
    connect(@ui.tableWidget,
            SIGNAL('cellClicked(int,int)'),
            self,
            SLOT('obj_table_cell_clicked(int,int)'))
    connect(@ui.tableWidget.verticalHeader,
            SIGNAL('sectionClicked(int)'),
            self,
            SLOT('header_clicked(int)'))
    connect(@ui.expand_button,
            SIGNAL('toggled(bool)'),
            self,
            SLOT('expand(bool)'))
    connect(@ui.alpha_sort_button,
            SIGNAL('toggled(bool)'),
            self,
            SLOT('sort(bool)'))
    @ui.class_tree.setHeaderHidden(true)
    populate_class_tree
    read_input_file(ARGV[0])
    self.show
  end
  
  def populate_class_tree
    @class_tree_items = []
    @idd = YAML.load(File.read('Energy+.idd.yml'))
    @idd.each do |group,objs|
      strs = []
      strs.push(group)
      @class_tree_items.push( Qt::TreeWidgetItem.new(strs))
      objs.each do |obj,vars|
        s = []
        s.push(obj)
        Qt::TreeWidgetItem.new(@class_tree_items.last,s)
      end
    end
    @ui.class_tree.insertTopLevelItems(0, @class_tree_items)
  end
  
  def class_tree_item_selected(curr,prev)
    parent = curr.parent
    if parent
      @ui.tableWidget.verticalHeader.reset
      obj = @idd[parent.text(0)][curr.text(0)]
      @ui.object_description.setText(obj['__self__']['memo'].join)
      tmp = obj.reject{|k| k=='__self__'}
      #@ui.object_structure.setText(tmp.to_yaml)
      @ui.tableWidget.setRowCount(tmp.size)
      tmp.each_with_index do |field,idx|
        itemText = field.first
        itemText += field.last.has_key?('units') ? " (#{field.last['units']})" : ''
        newItem = Qt::TableWidgetItem.new(itemText)  
        @ui.tableWidget.setVerticalHeaderItem(idx,newItem)
        #@ui.tableWidget.setItem(idx, 0, newItem)
      end
      @ui.tableWidget.verticalHeader().setResizeMode(Qt::HeaderView::ResizeToContents)
      @ui.tableWidget.verticalHeader().setResizeMode(Qt::HeaderView::Interactive)
    else
      # Clear out whatever should go away
    end
  end
  
  def obj_table_cell_clicked(row,col)
    header_clicked(row)
  end
  
  def header_clicked(idx)
    field_name = @ui.tableWidget.verticalHeaderItem(idx).text
    field_name.sub!(/\s\(.+\)$/,'')
    puts field_name
    tree_sel = @ui.class_tree.current_item
    group_name = tree_sel.parent.text(0)
    obj_name = tree_sel.text(0)
    field = @idd[group_name][obj_name][field_name]
    
    desc_text = "<b>Field:</b> #{field_name}" << "<br>"
    vartype = field['vartype'] == 'A' ? "Alphanumeric" : "Numeric"
    desc_text << "<b>Type:</b> #{vartype}<br>"
    desc_text << "<b>Required</b>" if field['required-field']
    desc_text << "<br>"
    defv = field['default'] ? field['default'] : ""
    desc_text << "<b>Default value:</b> #{defv}" if !defv.empty?
    desc_text << "<br><br>"
    if (field['note'] && !field['note'].empty?)
      desc_text << "<b>Notes:</b><br>" << field['note'].join("<br>")
    end
    
    @ui.object_structure.setText(desc_text)
  end
  
  def expand(xpnd)
    if xpnd
      @ui.class_tree.expandAll
    else
      @ui.class_tree.collapseAll
    end
  end
  
  def sort(srt)
    if srt
      @ui.class_tree.sortItems(0,Qt::AscendingOrder)
    else
      @ui.class_tree.setSortingEnabled(false)
      @ui.class_tree.topLevelItemCount.times {|idx| @ui.class_tree.takeTopLevelItem(0)}
      @ui.class_tree.insertTopLevelItems(0,@class_tree_items)
    end
  end
  
  def read_input_file(fname)
  end
  
end

app = Qt::Application.new(ARGV)
Test.new
app.exec
