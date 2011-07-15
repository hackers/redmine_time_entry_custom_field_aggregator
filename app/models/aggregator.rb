class Aggregator
  
  attr_accessor :headers, :days, :data_table, :sum_all

  def initialize(project, date_st=Date.today.beginning_of_month, 
                          date_ed=Date.today.at_end_of_month)
    @date_st = date_st
    @date_ed = date_ed
    @project = project
  end

  def each_days_table
    @data_table = Hash[*days.zip(Array.new(days.length, 0)).flatten]
    @data_table.each do |key, val|
      @data_table[key] = Array.new(headers.length-1, 0)
    end
    entries.each do |entry|
      if not @data_table.has_key? entry.spent_on.to_s
        next
      end
      @data_table[entry.spent_on.to_s][0] += entry.hours
      i = 1
      custom_fields.each do |custom_field|
        custom_values = CustomValue.find(:all, 
                                         :conditions => {
                                           :customized_id => entry.id, 
                                           :custom_field_id => custom_field.id})
        custom_values.each do |custom_value|
          @data_table[entry.spent_on.to_s][i] += custom_value.value.to_f
        end
        i += 1
      end
    end
    @data_table
  end

  def sum
    @sum_all = Array.new(headers.length-1, 0)
    entries.each do |entry|
      @sum_all[0] += entry.hours
      i = 1
      custom_fields.each do |custom_field|
        custom_values = CustomValue.find(:all, 
                                         :conditions => {
                                           :customized_id => entry.id, 
                                           :custom_field_id => custom_field.id})
        custom_values.each do |custom_value|
          @sum_all[i] += custom_value.value.to_f
        end
        i += 1
      end
    end
    @sum_all
  end

  def custom_fields
    custom_fields = CustomField.find(:all, 
                                     :conditions => [
                                       "type = :type and field_format in ('float', 'int')",
                                       {:type => 'TimeEntryCustomField'}],
                                     :order => :position)
  end

  def headers
    [:cfa_table_header_date, :cfa_table_header_hours].concat(custom_fields.map {|x| x.name})
  end

  def days
    (@date_st .. @date_ed).map {|x| x.to_s}
  end

  def entries
    entries = TimeEntry.find(:all,
                             :conditions => [
                               "user_id = :user and project_id = :project 
                                and spent_on >= :date_st and spent_on <= :date_ed",
                               {:user => User.current,
                                :project => @project,
                                :date_st => @date_st,
                                :date_ed => @date_ed}
                             ])
  end

end
