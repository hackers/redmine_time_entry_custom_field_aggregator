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

    user = User.current
    @year = params.has_key?(:year) ? params[:year].to_i : Date.today.year
    @month = params.has_key?(:month) ? params[:month].to_i : Date.today.month

    if @project and user

      custom_fields = CustomField.find(:all, 
                                       :conditions => [
                                         "type = :type and field_format in ('float', 'int')",
                                         {:type => 'TimeEntryCustomField'}],
                                       :order => :position)
      @headers = [l(:cfa_table_header_date), l(:cfa_table_header_hours)]
      @headers.concat(custom_fields.map {|x| x.name})
 
      @sum_all = Array.new(@headers.length-1, 0)

      selected_date = Date::new(@year.to_i, @month.to_i)
      @month_index = (selected_date.beginning_of_month .. selected_date.at_end_of_month).to_a
      @month_index = @month_index.map {|x| x.to_s}

      @data_table = Hash[*@month_index.zip(Array.new(@month_index.length, 0)).flatten]
      @data_table.each do |key, val|
        @data_table[key] = Array.new(@headers.length-1, 0)
      end

      entries = TimeEntry.find(:all, 
                               :conditions => [
                                 " user_id = :user and project_id = :project" + 
                                 " and spent_on >= :date_st and spent_on <= :date_ed", 
                                 {:user => user,
                                  :project => @project,
                                  :date_st => selected_date.beginning_of_month,
                                  :date_ed => selected_date.at_end_of_month}])

      entries.each do |entry|
        if not @data_table.has_key? entry.spent_on.to_s
          next
        end
        @data_table[entry.spent_on.to_s][0] += entry.hours
        @sum_all[0] += entry.hours
        i = 1
        custom_fields.each do |custom_field|
          custom_values = CustomValue.find(:all, 
                                           :conditions => {
                                             :customized_id => entry.id, 
                                             :custom_field_id => custom_field.id})
          custom_values.each do |custom_value|
            @data_table[entry.spent_on.to_s][i] += custom_value.value.to_f
            @sum_all[i] += custom_value.value.to_f
          end
          i += 1
        end
      end
    
    respond_to do |format|
      format.html
      format.csv { send_data(table_to_csv(@headers, @month_index, @data_table, @sum_all), 
                             :type => 'text/csv; header=present', 
                             :filename => 'export.csv') }
    end
     
    end # if project and user
  end
end
