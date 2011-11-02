require 'fastercsv'

class AggregatorController < ApplicationController
  unloadable

  include AggregatorHelper

  YEAR_MIN = 2000
  YEAR_RANGE = 10

  def index

    if params.has_key? :project_id
      @project = Project.find_by_identifier(params[:project_id])
    end
    @years = (Date::new(YEAR_MIN).year .. Date.today.year + YEAR_RANGE).to_a
    @months = (1 .. 12).to_a

    @user = params.has_key?(:user) ? User.find(params[:user]) : User.current
    @year = params.has_key?(:year) ? params[:year].to_i : Date.today.year
    @month = params.has_key?(:month) ? params[:month].to_i : Date.today.month

    if @project and @user

      selected_date = Date::new(@year.to_i, @month.to_i)
      @aggregator = Aggregator::new(@project, @user, selected_date.beginning_of_month,
                                   selected_date.at_end_of_month)
      @days = @aggregator.days
      @sum_all = @aggregator.sum_all
    end

    respond_to do |format|
      format.html
      format.csv { send_data(table_to_csv(@aggregator), :type => 'text/csv; header=present', 
                                                        :filename => 'export.csv') }

    end
  end
end
