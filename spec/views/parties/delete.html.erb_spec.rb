# encoding: utf-8
require 'spec_helper'
require 'level'

describe 'parties/delete.html.erb' do
  let(:level) { $level = Level.new(filename: 'lvl') }
  let(:party) { $party = level.parties.new(name: 'Delete Me') }

  before(:each) do
    assign(:level, level)
    party.stub(:to_param).and_return('abc')
    assign(:party, party)
    render
  end

  it 'should render the deletion form' do
    assert_select 'form', action: '/levels/lvl/parties/abc', method: 'delete' do
      assert_select 'input', type: 'submit', value: 'Delete Party'
    end
  end

end
