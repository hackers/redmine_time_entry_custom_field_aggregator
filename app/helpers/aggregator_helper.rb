module AggregatorHelper
  def table_to_csv(headers, month_index, data_table, sum_all)
    decimal_separator = l(:general_csv_decimal_separator)
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      csv << headers.unshift(l(:cfa_table_header_date))
      month_index.each do |aday|
        csv << data_table[aday].unshift(aday)
      end
      csv << sum_all.unshift(l(:cfa_table_total))
    end
    export 
  end
end
