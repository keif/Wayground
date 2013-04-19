# encoding: utf-8
require 'spec_helper'

describe "images/delete.html.erb" do

  let(:image) { $image = Image.new(title: 'Delete Me') }
  before(:each) do
    assign(:image, image)
  end

  it "should render the deletion form" do
    image.stub(:id).and_return(123)
    render
    assert_select 'form', action: '/images/123', method: 'delete' do
      assert_select 'input', type: 'submit', value: 'Delete Image'
    end
  end

end