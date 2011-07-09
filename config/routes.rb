ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'aggregator', :action => 'index' do |aggregator| 
    aggregator.connect 'projects/:project_id/aggregator' 
    aggregator.connect 'projects/:project_id/aggregator.:format'
  end
end
