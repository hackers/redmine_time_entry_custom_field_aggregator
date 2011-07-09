require 'redmine'

Redmine::Plugin.register :redmine_custom_field_aggregator do
  name 'Redmine Custom Field Aggregator plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://github.com/hackers/redmine_custom_field_aggregator'
  author_url 'http://github.com/hackers'
  permission :sample, {:aggregator => [:index]}, :public => true
  menu :project_menu, :sample, { :controller => 'aggregator', :action => 'index'}, :caption => '時間集計', :param => :project_id
end
