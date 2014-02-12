=begin
** Form generated from reading ui file 'ridf.ui'
**
** Created: Tue Feb 11 00:10:46 2014
**      by: Qt User Interface Compiler version 4.8.4
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
=end

class Ui_MainWindow
    attr_reader :centralwidget
    attr_reader :verticalLayout_4
    attr_reader :splitter_3
    attr_reader :verticalLayoutWidget_2
    attr_reader :verticalLayout_2
    attr_reader :horizontalLayout
    attr_reader :expand_button
    attr_reader :only_existing_button
    attr_reader :alpha_sort_button
    attr_reader :horizontalSpacer
    attr_reader :class_tree
    attr_reader :splitter_2
    attr_reader :splitter
    attr_reader :verticalLayoutWidget
    attr_reader :verticalLayout
    attr_reader :object_description
    attr_reader :object_structure
    attr_reader :verticalLayoutWidget_3
    attr_reader :verticalLayout_3
    attr_reader :horizontalLayout_2
    attr_reader :toolButton_2
    attr_reader :toolButton
    attr_reader :horizontalSpacer_3
    attr_reader :tableView
    attr_reader :menubar
    attr_reader :statusbar

    def setupUi(mainWindow)
    if mainWindow.objectName.nil?
        mainWindow.objectName = "mainWindow"
    end
    mainWindow.resize(1200, 900)
    @centralwidget = Qt::Widget.new(mainWindow)
    @centralwidget.objectName = "centralwidget"
    @verticalLayout_4 = Qt::VBoxLayout.new(@centralwidget)
    @verticalLayout_4.objectName = "verticalLayout_4"
    @splitter_3 = Qt::Splitter.new(@centralwidget)
    @splitter_3.objectName = "splitter_3"
    @splitter_3.orientation = Qt::Horizontal
    @verticalLayoutWidget_2 = Qt::Widget.new(@splitter_3)
    @verticalLayoutWidget_2.objectName = "verticalLayoutWidget_2"
    @verticalLayout_2 = Qt::VBoxLayout.new(@verticalLayoutWidget_2)
    @verticalLayout_2.objectName = "verticalLayout_2"
    @verticalLayout_2.setContentsMargins(0, 0, 0, 0)
    @horizontalLayout = Qt::HBoxLayout.new()
    @horizontalLayout.objectName = "horizontalLayout"
    @expand_button = Qt::ToolButton.new(@verticalLayoutWidget_2)
    @expand_button.objectName = "expand_button"
    @expand_button.checkable = true

    @horizontalLayout.addWidget(@expand_button)

    @only_existing_button = Qt::ToolButton.new(@verticalLayoutWidget_2)
    @only_existing_button.objectName = "only_existing_button"
    @only_existing_button.checkable = true

    @horizontalLayout.addWidget(@only_existing_button)

    @alpha_sort_button = Qt::ToolButton.new(@verticalLayoutWidget_2)
    @alpha_sort_button.objectName = "alpha_sort_button"
    @alpha_sort_button.checkable = true

    @horizontalLayout.addWidget(@alpha_sort_button)

    @horizontalSpacer = Qt::SpacerItem.new(40, 20, Qt::SizePolicy::Expanding, Qt::SizePolicy::Minimum)

    @horizontalLayout.addItem(@horizontalSpacer)


    @verticalLayout_2.addLayout(@horizontalLayout)

    @class_tree = Qt::TreeWidget.new(@verticalLayoutWidget_2)
    @class_tree.objectName = "class_tree"
    @class_tree.indentation = 14
    @class_tree.sortingEnabled = false

    @verticalLayout_2.addWidget(@class_tree)

    @splitter_3.addWidget(@verticalLayoutWidget_2)
    @splitter_2 = Qt::Splitter.new(@splitter_3)
    @splitter_2.objectName = "splitter_2"
    @splitter_2.orientation = Qt::Vertical
    @splitter = Qt::Splitter.new(@splitter_2)
    @splitter.objectName = "splitter"
    @splitter.orientation = Qt::Vertical
    @verticalLayoutWidget = Qt::Widget.new(@splitter)
    @verticalLayoutWidget.objectName = "verticalLayoutWidget"
    @verticalLayout = Qt::VBoxLayout.new(@verticalLayoutWidget)
    @verticalLayout.objectName = "verticalLayout"
    @verticalLayout.setContentsMargins(0, 0, 0, 0)
    @object_description = Qt::TextEdit.new(@verticalLayoutWidget)
    @object_description.objectName = "object_description"
    @sizePolicy = Qt::SizePolicy.new(Qt::SizePolicy::Expanding, Qt::SizePolicy::Minimum)
    @sizePolicy.setHorizontalStretch(0)
    @sizePolicy.setVerticalStretch(0)
    @sizePolicy.heightForWidth = @object_description.sizePolicy.hasHeightForWidth
    @object_description.sizePolicy = @sizePolicy

    @verticalLayout.addWidget(@object_description)

    @object_structure = Qt::TextEdit.new(@verticalLayoutWidget)
    @object_structure.objectName = "object_structure"

    @verticalLayout.addWidget(@object_structure)

    @splitter.addWidget(@verticalLayoutWidget)
    @splitter_2.addWidget(@splitter)
    @verticalLayoutWidget_3 = Qt::Widget.new(@splitter_2)
    @verticalLayoutWidget_3.objectName = "verticalLayoutWidget_3"
    @verticalLayout_3 = Qt::VBoxLayout.new(@verticalLayoutWidget_3)
    @verticalLayout_3.objectName = "verticalLayout_3"
    @verticalLayout_3.setContentsMargins(0, 0, 0, 0)
    @horizontalLayout_2 = Qt::HBoxLayout.new()
    @horizontalLayout_2.objectName = "horizontalLayout_2"
    @toolButton_2 = Qt::ToolButton.new(@verticalLayoutWidget_3)
    @toolButton_2.objectName = "toolButton_2"

    @horizontalLayout_2.addWidget(@toolButton_2)

    @toolButton = Qt::ToolButton.new(@verticalLayoutWidget_3)
    @toolButton.objectName = "toolButton"

    @horizontalLayout_2.addWidget(@toolButton)

    @horizontalSpacer_3 = Qt::SpacerItem.new(40, 20, Qt::SizePolicy::Expanding, Qt::SizePolicy::Minimum)

    @horizontalLayout_2.addItem(@horizontalSpacer_3)


    @verticalLayout_3.addLayout(@horizontalLayout_2)

    @tableView = Qt::TableView.new(@verticalLayoutWidget_3)
    @tableView.objectName = "tableView"

    @verticalLayout_3.addWidget(@tableView)

    @splitter_2.addWidget(@verticalLayoutWidget_3)
    @splitter_3.addWidget(@splitter_2)

    @verticalLayout_4.addWidget(@splitter_3)

    mainWindow.centralWidget = @centralwidget
    @menubar = Qt::MenuBar.new(mainWindow)
    @menubar.objectName = "menubar"
    @menubar.geometry = Qt::Rect.new(0, 0, 1200, 25)
    mainWindow.setMenuBar(@menubar)
    @statusbar = Qt::StatusBar.new(mainWindow)
    @statusbar.objectName = "statusbar"
    mainWindow.statusBar = @statusbar

    retranslateUi(mainWindow)

    Qt::MetaObject.connectSlotsByName(mainWindow)
    end # setupUi

    def setup_ui(mainWindow)
        setupUi(mainWindow)
    end

    def retranslateUi(mainWindow)
    mainWindow.windowTitle = Qt::Application.translate("MainWindow", "MainWindow", nil, Qt::Application::UnicodeUTF8)
    @expand_button.text = Qt::Application.translate("MainWindow", "Expand", nil, Qt::Application::UnicodeUTF8)
    @only_existing_button.text = Qt::Application.translate("MainWindow", "Only Existing", nil, Qt::Application::UnicodeUTF8)
    @alpha_sort_button.text = Qt::Application.translate("MainWindow", "Alpha Sort", nil, Qt::Application::UnicodeUTF8)
    @class_tree.headerItem.setText(0, Qt::Application.translate("MainWindow", "Objects", nil, Qt::Application::UnicodeUTF8))
    @toolButton_2.text = Qt::Application.translate("MainWindow", "...", nil, Qt::Application::UnicodeUTF8)
    @toolButton.text = Qt::Application.translate("MainWindow", "...", nil, Qt::Application::UnicodeUTF8)
    end # retranslateUi

    def retranslate_ui(mainWindow)
        retranslateUi(mainWindow)
    end

end

module Ui
    class MainWindow < Ui_MainWindow
    end
end  # module Ui

