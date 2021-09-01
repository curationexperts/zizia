require 'csv'
class FancyImport
  class << self
    Struct.new("Collection", :identifier, :title, :line_number)
    Struct.new("File", :identifier, :parent_id, :files, :line_number)
    Struct.new("Work", :identifier, :parent_id, :title, :resource_type, 
                :creator, :contributor, :description, :keyword, :license, 
                :rights_statement, :line_number)  
    def from(file)
      csv = CSV.new(file, headers: true, 
        header_converters: [->(s){s.downcase.gsub(' ', '_')}])

      result = []
      csv.each do |row|
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

    private

    def process_collection(r, lineno)
      Struct::Collection.new(r["identifier"], r["title"], lineno)
    end
    def process_work(r, lineno)
      Struct::Work.new(r["identifier"], r["parent_id"], r["title"], r["resource_type"],
                       r["creator"], r["contributor"], r["description"], 
                       r["keyword"].split("|~|"), r["license"], 
                       r["rights_statement"], lineno)
    end

    def process_file(r, lineno)
      Struct::File.new(r["identifier"], r["parent_id"], r["files"].split(","), lineno)
    end
  end

  def initialize()
  end
end
