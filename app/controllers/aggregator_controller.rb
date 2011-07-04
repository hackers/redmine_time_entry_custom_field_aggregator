class AggregatorController < ApplicationController
  unloadable


  def index
      @projects = Project.all
      if params.has_key? :project
        @project = Project.find(params[:project][:id])
      end
  end
end
