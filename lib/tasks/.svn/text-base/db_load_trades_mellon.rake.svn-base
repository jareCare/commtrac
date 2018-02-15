namespace :db do

  namespace :load_trades do

    desc "Load all of today's mellon trades from tmp/trades/mellon into the db"
    task :mellon => :environment do 
      company = Company.find 2
      filename = File.join RAILS_ROOT, 'tmp', 'trades', 'mellon', "#{Date.today.strftime '%Y%m%d'}.csv"
      csv_file = File.read filename
      CSV.parse(csv_file) do |array|
        trade = Trade.from_array array
        trade.company = company
        trade.save!
      end
    end

  end

end
