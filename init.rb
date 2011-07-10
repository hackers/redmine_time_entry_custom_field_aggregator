require 'redmine'

Redmine::Plugin.register :redmine_custom_field_aggregator do
  name 'Redmine Time Entry Custom Field Aggregator plugin'
  author 'Yusaku ONO'
  description "This plugin enables to sum up spent time and custom field's values."
  version '0.0.1'
  url 'http://github.com/hackers/redmine_time_entry_custom_field_aggregator'
  author_url 'http://github.com/hackers'
  project_module :custom_field_aggregator do
    permission :view_table, {:aggregator => [:index]}, :public => true
    menu :project_menu, :view_table, { :controller => 'aggregator', :action => 'index'}, :caption => :cfa_menu, :param => :project_id
  end
end
