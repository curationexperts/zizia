
    Struct.new("Collection", :identifier, :title, :children, :line_number)do
      def initialize(*)
        super
        self.children ||= []
      end
    end

    Struct.new("File", :identifier, :parent_id, :files, :line_number)
    Struct.new("Work", :identifier, :parent_id, :title, :resource_type, 
                :creator, :contributor, :description, :keyword, :license, 
                :rights_statement, :children, :line_number)   do
                  def initialize(*)
                    super
                    self.children ||= []
                  end
                end
    

    Struct.new("Graph", :collections)

