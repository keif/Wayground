# encoding: utf-8
require 'spec_helper'
require_relative '../../app/datatypes/db_array'

describe DbArray do

  describe "initialization" do
    it "should default to an empty array" do
      expect( DbArray.new ).to eq []
    end
    it 'should accept a pg array formatted string' do
      expect( DbArray.new('{"A","B"}') ).to eq ['A', 'B']
    end
    it 'should accept an array' do
      expect( DbArray.new(['C', 'D']) ).to eq ['C', 'D']
    end
  end

  describe "#array=" do
    it "should accept a string" do
      dbarray = DbArray.new
      dbarray.array = '{"E","F"}'
      expect( dbarray ).to eq ['E', 'F']
    end
    it 'should accept an array' do
      dbarray = DbArray.new
      dbarray.array = ['G', 'H']
      expect( dbarray ).to eq ['G', 'H']
    end
    it 'should accept an empty array' do
      dbarray = DbArray.new
      dbarray.array = []
      expect( dbarray ).to eq []
    end
    it 'should default to an empty array when given an empty string' do
      dbarray = DbArray.new
      dbarray.array = ''
      expect( dbarray ).to eq []
    end
    it 'should default to an empty array when given nil' do
      dbarray = DbArray.new
      dbarray.array = nil
      expect( dbarray ).to eq []
    end
  end

  describe "#array" do
    it "should return the array value" do
      dbarray = DbArray.new(['I', 'J'])
      expect( dbarray.array ).to eq ['I', 'J']
    end
  end

  describe "#to_s" do
    it "should generate a string" do
      dbarray = DbArray.new(['K', 'L'])
      expect( dbarray.to_s ).to eq '{"K","L"}'
    end
    context 'with a nil array value' do
      it 'should return an empty string' do
        expect( DbArray.new(nil).to_s ).to eq ''
      end
    end
    it 'should strip quotes from array values' do
      dbarray = DbArray.new(['A string with "quotes".'])
      expect( dbarray.to_s ).to eq '{"A string with quotes."}'
    end
    it 'should strip backslashes from array values' do
      dbarray = DbArray.new(['A string with a backslash: \\'])
      expect( dbarray.to_s ).to eq '{"A string with a backslash: "}'
    end
  end

  describe "#==" do
    it "should return true if given a matching DbArray" do
      dbarray1 = DbArray.new(['M', 'N'])
      dbarray2 = DbArray.new(['M', 'N'])
      expect( (dbarray1 == dbarray2) ).to be_true
    end
    it "should return true if given a matching array" do
      dbarray = DbArray.new(['O', 'P'])
      expect( (dbarray == ['O', 'P']) ).to be_true
    end
    it "should return true if given a matching pg array formatted string" do
      dbarray = DbArray.new(['Q', 'R'])
      expect( (dbarray == '{"Q","R"}') ).to be_true
    end
  end

  describe "#<<" do
    it "should push an item onto the array value" do
      dbarray = DbArray.new(nil)
      expect( dbarray << 'S' ).to eq ['S']
    end
  end

  describe "#[]" do
    it "should return an indexed value from the array value" do
      dbarray = DbArray.new(['T','U'])
      expect( dbarray[1] ).to eq 'U'
    end
  end

end