$:.unshift File.expand_path("../..", __FILE__)
require 'spec_helper'
require 'dawg_helper'

shared_examples "SSE" do |man, tests|
  describe man.to_s.split("/")[-2] do
    tests.each do |t|
      case t.type
      when MF.QueryEvaluationTest, MF.PositiveSyntaxTest, MF.PositiveSyntaxTest11
        it "parses #{t.entry} - #{t.name} - #{t.comment} to correct SXP" do
          case t.name
          when 'Basic - Term 7', 'syntax-lit-08.rq'
            pending "Decimal format changed in SPARQL 1.1"
          when 'syntax-esc-04.rq', 'syntax-esc-05.rq'
            pending "Fixing PNAME_LN not matching :\\u0070"
          when /propertyPaths|syn-pp/
            pending "Property Paths"
          end
          pending "Property Paths" if man.to_s.split("/")[-2] == 'property-path'
          parser_opts = {base_uri: t.action.query_file}
          parser_opts[:debug] = true if ENV['PARSER_DEBUG']
          query = SPARQL::Grammar.parse(t.action.query_string, parser_opts)
          sxp = SPARQL::Algebra.parse(t.action.sse_string, parser_opts)
          expect(query).to eq sxp
        end

        it "parses #{t.entry} - #{t.name} - #{t.comment} to lexically equivalent SSE" do
          case t.name
          when 'Basic - Term 6', 'Basic - Term 7', 'syntax-lit-08.rq'
            pending "Decimal format changed in SPARQL 1.1"
          when 'syntax-esc-04.rq', 'syntax-esc-05.rq'
            pending "Fixing PNAME_LN not matching :\\u0070"
          when /propertyPaths|syn-pp/
            pending "Property Paths"
          end
          pending "Property Paths" if man.to_s.split("/")[-2] == 'property-path'
          query = begin
            SPARQL::Grammar.parse(t.action.query_string, debug: ENV['PARSER_DEBUG'])
          rescue Exception => e
            "Error: #{e.message}"
          end
          normalized_query = query.to_sxp.
            gsub(/\s+/m, " ").
            gsub(/\(\s+\(/, '((').
            gsub(/\)\s+\)/, '))').
            strip
          normalized_result = t.action.sse_string.
            gsub(/\s+/m, " ").
            gsub(/\(\s+\(/, '((').
            gsub(/\)\s+\)/, '))').
            strip
          expect(normalized_query).to produce(normalized_result, ["original query:", t.action.query_string])
        end
      when MF.NegativeSyntaxTest, MF.NegativeSyntaxTest11
        it "detects syntax error for #{t.entry} - #{t.name} - #{t.comment}" do
          pending("Better Error Detection") if %w(
            syn-blabel-cross-graph-bad.rq syn-blabel-cross-optional-bad.rq syn-blabel-cross-union-bad.rq
            syn-bad-34.rq syn-bad-35.rq syn-bad-36.rq syn-bad-37.rq syn-bad-38.rq
            syn-bad-OPT-breaks-BGP.rq syn-bad-UNION-breaks-BGP.rq syn-bad-GRAPH-breaks-BGP.rq
            agg08.rq agg09.rq agg10.rq agg11.rq agg12.rq
            syntax-BINDscope6.rq syntax-BINDscope7.rq syntax-BINDscope8.rq
            syntax-SELECTscope2.rq
            syn-bad-pname-06.rq
          ).include?(t.entry)
          pending("Better Error Detection") if %w(
            syn-bad-01.rq syn-bad-02.rq
          ).include?(t.entry) && man.to_s.split("/")[-2] == 'syntax-query'
          expect {SPARQL::Grammar.parse(t.action.query_string, validate: true)}.to raise_error
        end
      when UT.UpdateEvaluationTest, MF.UpdateEvaluationTest, MF.PositiveUpdateSyntaxTest11
        it "parses #{t.entry} - #{t.name} - #{t.comment} to correct SXP" do
          pending("Whitespace in string tokens") if %w(
            syntax-update-26.ru syntax-update-27.ru syntax-update-28.ru
            syntax-update-36.ru
          ).include?(t.entry)
          pending("Null update corner case") if %w(
            syntax-update-38.ru
          ).include?(t.entry)
          parser_opts = {update: true, base_uri: t.action.query_file}
          parser_opts[:debug] = true if ENV['PARSER_DEBUG']
          query = SPARQL::Grammar.parse(t.action.query_string, parser_opts)
          sxp = SPARQL::Algebra.parse(t.action.sse_string, parser_opts)
          expect(query).to eq sxp
        end

        it "parses #{t.entry} - #{t.name} - #{t.comment} to lexically equivalent SSE", focus:true do
          pending("Whitespace in string tokens") if %w(
            syntax-update-26.ru syntax-update-27.ru syntax-update-28.ru
            syntax-update-36.ru
          ).include?(t.entry)
          pending("Null update corner case") if %w(
            syntax-update-38.ru
          ).include?(t.entry)
          query = begin
            SPARQL::Grammar.parse(t.action.query_string, update: true, debug: ENV['PARSER_DEBUG'])
          rescue Exception => e
            "Error: #{e.message}"
          end
          normalized_query = query.to_sxp.
            gsub(/\s+/m, " ").
            gsub(/\(\s+\(/, '((').
            gsub(/\)\s+\)/, '))').
            strip
          normalized_result = t.action.sse_string.
            gsub(/\s+/m, " ").
            gsub(/\(\s+\(/, '((').
            gsub(/\)\s+\)/, '))').
            strip
          expect(normalized_query).to produce(normalized_result, ["original query:", t.action.query_string])
        end
      when MF.NegativeUpdateSyntaxTest11
        it "detects syntax error for #{t.entry} - #{t.name} - #{t.comment}" do
          pending("Better Error Detection") if %w(
            syntax-update-bad-03.ru syntax-update-bad-04.ru syntax-update-bad-10.ru
            syntax-update-bad-11.ru syntax-update-bad-12.ru syntax-update-54.ru
          ).include?(t.entry)
          expect {SPARQL::Grammar.parse(t.action.query_string, update: true, validate: true)}.to raise_error
        end
      when MF.CSVResultFormatTest, MF.ServiceDescriptionTest, MF.ProtocolTest,
           MF.GraphStoreProtocolTest
        it "parses #{t.entry} - #{t.name} to correct SSE - #{t.comment}"
        it "parses #{t.entry} - #{t.name} to lexically equivalent SSE - #{t.comment}"
      else
        it "??? #{t.entry} - #{t.name} - #{t.comment}" do
          puts t.inspect
          fail "Unknown test type #{t.type}"
        end
      end
    end
  end
end

describe SPARQL::Grammar::Parser do
  before(:each) {$stderr = StringIO.new}
  after(:each) {$stderr = STDERR}
  describe "w3c dawg SPARQL 1.0 syntax tests" do
    SPARQL::Spec.sparql1_0_syntax_tests(true).group_by(&:manifest).each do |man, tests|
      it_behaves_like "SSE", man, tests
    end
  end

  describe "w3c dawg SPARQL 1.0 tests" do
    SPARQL::Spec.sparql1_0_tests(true).group_by(&:manifest).each do |man, tests|
      it_behaves_like "SSE", man, tests
    end
  end

  describe "w3c dawg SPARQL 1.1 tests" do
    SPARQL::Spec.sparql1_1_tests(true).
      reject do |tc|
        %w{
          entailment

          http-rdf-dupdate
          protocol
          service
          syntax-fed

        }.include? tc.manifest.to_s.split('/')[-2]
      end.
      group_by(&:manifest).
      each do |man, tests|
      it_behaves_like "SSE", man, tests
    end
  end
end unless ENV['CI']