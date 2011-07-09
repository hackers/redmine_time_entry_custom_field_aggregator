require 'fastercsv'

class AggregatorController < ApplicationController
  unloadable

  YEAR_MIN = 2000
  YEAR_RANGE = 10

  def index

    if params.has_key? :project_id
      @project = Project.find_by_identifier(params[:project_id])
    end
    @years = (Date::new(YEAR_MIN).year .. Date.today.year + YEAR_RANGE).to_a
    @months = (1 .. 12).to_a

    user = User.current
    @year = params.has_key?(:year) ? params[:year][:id].to_i : Date.today.year
    @month = params.has_key?(:month) ? params[:month][:id].to_i : Date.today.month

    if @project and user

      custom_fields = CustomField.find(:all, 
                                        :conditions => {:type => 'TimeEntryCustomField', 
                                                        :field_format => 'float'},
                                        :order => :position)
      @headers = [l(:cfa_table_header_hours)]
      custom_fields.each do |custom_field|
        @headers << custom_field.name
      end
 
      ## 日ごとのデータ集計
      @sum_all = Array.new(@headers.length, 0)

      selected_date = Date::new(@year.to_i, @month.to_i)
      @month_index = (selected_date.beginning_of_month .. selected_date.at_end_of_month).to_a
      @month_index = @month_index.map {|x| x.to_s}

      @data_table = Hash[*@month_index.zip(Array.new(@month_index.length, 0)).flatten]
      @data_table.each do |key, val|
        @data_table[key] = Array.new(@headers.length, 0)
      end

      entries = TimeEntry.find(:all, 
                                :conditions => {:user_id => @user, 
                                                :project_id => @project })
      entries.each do |entry|
        if not @data_table.has_key? entry.spent_on.to_s
          next
        end
        @data_table[entry.spent_on.to_s][0] += entry.hours
        @sum_all[0] += entry.hours
        i = 1
        custom_fields.each do |custom_field|
          custom_values = CustomValue.find(:all, 
                                           :conditions => 
                                             {:customized_id => entry.id, 
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
      format.csv { send_data(table_to_csv(@headers, @month_index, @data_table, @sum_all), :type => 'text/csv; header=present', :filename => 'export.csv') }
    end
     
    end # if project and user
  end
  
  private

  def table_to_csv(headers, month_index, data_table, sum_all)
    decimal_separator = l(:general_csv_decimal_separator)
    export = FasterCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      csv << headers
      month_index.each do |aday|
        data = [aday]
        data_table[aday].each do |value|
          data << value
        end
        csv << data
      end
      data = [l(:cfa_table_total)]
      sum_all.each do |value|
        data << value
      end
      csv << data
    end
    export 
  end

end
