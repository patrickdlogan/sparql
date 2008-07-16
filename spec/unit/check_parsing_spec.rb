require 'pathname'

require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe "SparqlParser", '#parse' do
  
  before(:all) do
  end
  
  it "should recognize a basic SELECT query with one variable and one triple pattern" do
    basic_valid_select_query = 'SELECT ?foo WHERE { ?x foaf:knows ?y . }'
    parser = SparqlParser.new
    parser.parse(basic_valid_select_query).well_formed?.should == true
    parser.parse(basic_valid_select_query).prologue.text_value.should == ""
    parser.parse(basic_valid_select_query).query_part.text_value.should == "SELECT ?foo WHERE { ?x foaf:knows ?y . }"
    parser.parse('SELECT ?foo ?bar WHERE { ?x foaf:knows ?y . ?z foaf:name ?y . }').should_not == nil
  end
  
  it "should recognize a basic SELECT query with one variable, one triple pattern, and a PREFIX declaration" do
    basic_valid_select_query_with_prologue = 'PREFIX foaf: <http://xmlns.com/foaf/0.1/> SELECT ?foo WHERE { ?x foaf:knows ?y . }'
    parser = SparqlParser.new
    parser.parse(basic_valid_select_query_with_prologue).well_formed?.should == true
    # parser.parse(basic_valid_select_query_with_prologue).prologue.text_value.should == ""
    #  parser.parse(basic_valid_select_query_with_prologue).query_part.text_value.should == "SELECT ?foo WHERE { ?x foaf:knows ?y . }"
    #  parser.parse('SELECT ?foo ?bar WHERE { ?x foaf:knows ?y . ?z foaf:name ?y . }').should_not == nil
   end

  
  it "should recognize a CONSTRUCT query"
  it "should recognize an ASK query"
  it "should recognize a DESCRIBE query"

end