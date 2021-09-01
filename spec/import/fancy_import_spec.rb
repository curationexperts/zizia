# frozen_string_literal: true
require 'spec_helper'
require_relative '../../lib/import/fancy_import.rb'
RSpec.describe FancyImport, clean: true do
  before :context do
    @output = FancyImport.from(File.open("spec/fixtures/fancy.csv"))
  end

  it "understands collections" do
    expect(@output.size).to eq(69)
    f = @output.first
    expect(f.identifier).to eq("TPC-000")
    expect(f.class.to_s).to eq("Struct::Collection")
    expect(f.title).to eq("Turkish Playing Cards")
    expect(f.line_number).to eq(2)

  end

  it "understands type file" do
    l = @output.last
    expect(l.class.to_s).to eq("Struct::File")
    expect(l.parent_id).to eq("TPC-J-000")
    expect(l.identifier).to eq("TPC-J-003")
    expect(l.files).to eq(["Joker1-Verso.tiff"])
    expect(l.line_number).to eq(70)
  end

  it "understands type work" do
    l = @output[1]
    expect(l.class.to_s).to eq("Struct::Work")
    expect(l.parent_id).to eq("TPC-000")
    expect(l.identifier).to eq("TPC-H-000")
    expect(l.title).to eq("Turkish Playing Cards - Hearts")
    expect(l.resource_type).to eq("Image")
    expect(l.creator).to eq("Turkish Republic Playing Cards Monopoly")
    expect(l.contributor).to eq("Bussey, Mark H.")
    expect(l.description).to eq("Hearts from a Turkish playing card set circa 1960-1963")
    expect(l.keyword).to eq(["playing card", "heart"])
    expect(l.license).to eq("http://creativecommons.org/publicdomain/mark/1.0/")
    expect(l.rights_statement).to eq("http://rightsstatements.org/vocab/NoC-OKLR/1.0/")
    expect(l.line_number).to eq(3)
  end


end
