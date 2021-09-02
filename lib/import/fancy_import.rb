require 'csv'
require_relative 'types'
class FancyImport
  class << self

    def from(file)
      csv = CSV.new(file, headers: true, 
        header_converters: [->(s){s.downcase.gsub(' ', '_')}])

      result = []
      csv.each do |row|
        next if row.all?{|x| x.last.nil?}
      result <<   case row["object_type"]
        when "File"
          process_file row, csv.lineno
        when "Work"
          process_work row, csv.lineno
        when "Collection"
          process_collection row, csv.lineno
        end
      end
      result
    end

    def connect(col)
      colindex = col.find_all{|x| x.class == Struct::Collection || x.class == Struct::Work}.inject({}){|m,x| m[x.identifier]=x; m}
      #connect child works to collections & other works
      col.find_all{|x| x.class == Struct::Work && !x.parent_id.nil?}.each{|x| colindex[x.parent_id].children << x}
      naked_works = col.find_all{|x| x.class == Struct::Work && x.parent_id.nil?}

      [colindex.values.select{|x| x.class == Struct::Collection}, naked_works]
    end

    private

    def process_collection(r, lineno)
      Struct::Collection.new(r["identifier"], r["title"], [], lineno)
    end

    def process_work(r, lineno)
      Struct::Work.new(r["identifier"], r["parent_id"], r["title"], r["resource_type"],
                       r["creator"], r["contributor"], r["description"], 
                       r["keyword"].split("|~|"), r["license"], 
                       r["rights_statement"], [], lineno)
    end

    def process_file(r, lineno)
      Struct::File.new(r["identifier"], r["parent_id"], r["files"].split(","), lineno)
    end
  end

  def initialize()
  end
end
