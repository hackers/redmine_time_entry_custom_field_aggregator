class Aggregator
  
  def initialize(project, user, date_st=Date.today.beginning_of_month, 
                          date_ed=Date.today.at_end_of_month)
    @user = user
    @date_st = date_st
    @date_ed = date_ed
    @project = project
  end

  def days
    days_hash = Hash[*days_index.zip(Array.new(days_index.length, 0)).flatten]
    days_hash.each do |key, val|
      days_hash[key] = Array.new(headers.length-1, 0)
    end
    entries.each do |entry|
      target_date = entry.issue.start_date.to_s
      if not days_hash.has_key? target_date
        next
      end
      days_hash[target_date][0] += entry.hours
      i = 1
      custom_fields.each do |custom_field|
        custom_values = CustomValue.find(:all, 
                                         :conditions => {
                                           :customized_id => entry.id, 
                                           :custom_field_id => custom_field.id})
        custom_values.each do |custom_value|
          days_hash[target_date][i] += custom_value.value.to_f
        end
        i += 1
      end
    end

    _days = []
    days_index.each do |aday|
      _days << days_hash[aday].unshift(aday)
    end
    _days
  end

  def sum_all
    _sum_all = Array.new(headers.length-1, 0)
    entries.each do |entry|
      _sum_all[0] += entry.hours
      i = 1
      custom_fields.each do |custom_field|
        custom_values = CustomValue.find(:all, 
                                         :conditions => {
                                           :customized_id => entry.id, 
                                           :custom_field_id => custom_field.id})
        custom_values.each do |custom_value|
          _sum_all[i] += custom_value.value.to_f
        end
        i += 1
      end
    end
    _sum_all
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

  def days_index
    (@date_st .. @date_ed).map {|x| x.to_s}
  end

  def entries
    entries = TimeEntry.find(:all,
                             :conditions => [
                               "user_id = :user and project_id = :project 
                                and spent_on >= :date_st and spent_on <= :date_ed",
                               {:user => @user,
                                :project => @project,
                                :date_st => @date_st,
                                :date_ed => @date_ed}
                             ])
  end

end
