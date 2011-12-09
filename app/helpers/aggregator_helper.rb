module AggregatorHelper
  def table_to_csv(aggregator)
    days = aggregator.days
    decimal_separator = l(:general_csv_decimal_separator)
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      row = []
      aggregator.headers.each do |header|
        header = l(header).start_with?('translation missing:') ? header : l(header)
        row << header
      end
      csv << row
      aggregator.days.each do |aday|
        csv << aday
      end
      csv << aggregator.sum_all.unshift(l(:cfa_table_total))
    end
    export 
  end

  def table_to_json(aggregator)
    data = []
    header = []
    aggregator.headers.each do |col|
      col = l(col).start_with?('translation missing:') ? col : l(col)
      header << col
    end
    aggregator.days.each do |aday|
      ary = [header, aday].transpose
      data << Hash[*ary.flatten]
    end
    data
  end
end
