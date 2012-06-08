if Rails.version.to_f >= 3.0
  scope :controller => 'aggregator', :action => 'index' do
    match 'projects/:project_id/aggregator'
    match 'projects/:project_id/aggregator.:format'
  end
else
  ActionController::Routing::Routes.draw do |map|
    map.with_options :controller => 'aggregator', :action => 'index' do |aggregator|
      aggregator.connect 'projects/:project_id/aggregator'
      aggregator.connect 'projects/:project_id/aggregator.:format'
    end
  end
end
