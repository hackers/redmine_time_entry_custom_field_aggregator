ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'aggregator' do |aggregator| 
    aggregator.connect 'projects/:project_id/aggregator', :action => 'index'
  end
end
