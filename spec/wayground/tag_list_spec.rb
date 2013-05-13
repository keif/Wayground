# encoding: utf-8
require 'spec_helper'
require 'tag_list'

describe Wayground::TagList do

  describe "#initialize" do
    it "should accept a tags param" do
      expect( Wayground::TagList.new(tags: :tags).tags ).to eq :tags
    end
  end

  describe '#to_s' do
    context 'with no tags' do
      it 'should return an empty string' do
        list = Wayground::TagList.new
        expect( list.to_s ).to eq ''
      end
    end
    context 'with a single tag' do
      it 'should return the tag title' do
        list = Wayground::TagList.new(tags: [Tag.new(title: 'Test Tag')])
        expect( list.to_s ).to eq 'Test Tag'
      end
    end
    context 'with multiple tags' do
      it 'should return a comma and space separated string of the tag titles' do
        tags = []
        tags << Tag.new(title: 'Tag A')
        tags << Tag.new(title: 'Tag B')
        tags << Tag.new(title: 'Tag C')
        list = Wayground::TagList.new(tags: tags)
        expect( list.to_s ).to eq 'Tag A, Tag B, Tag C'
      end
    end
  end

  describe '#tags=' do
    it 'should call through to the sub-methods' do
      list = Wayground::TagList.new
      list.should_receive(:determine_existing_tags)
      list.should_receive(:figure_out_tags_to_include).with('the tag string')
      list.should_receive(:remove_leftover_existing_tags)
      list.tags = 'the tag string'
    end
    it 'should handle the whole stack' do
      item = FactoryGirl.create(:event)
      item.tag_list = 'â, B'
      item.save!
      item.reload
      list = Wayground::TagList.new(tags: item.tags, editor: item.user)
      list.tags = 'A,"C"'
      item.save!
      item.reload
      expect( Wayground::TagList.new(tags: item.tags).to_s ).to eq 'A, C'
    end
  end

  describe '#determine_existing_tags' do
    context 'with no tags' do
      it 'should return an empty hash' do
        tags = []
        tags.stub(:all).and_return(tags)
        list = Wayground::TagList.new(tags: tags)
        expect( list.determine_existing_tags ).to eq({})
      end
    end
    context 'with some tags' do
      it 'should return a hash with the tags as values keyed on the tag.tag' do
        taga = Tag.new(title: 'Tag A')
        tagb = Tag.new(title: 'Tag B')
        tagc = Tag.new(title: 'Tag C')
        tags = [taga, tagb, tagc]
        tags.stub(:all).and_return(tags)
        list = Wayground::TagList.new(tags: tags)
        expect( list.determine_existing_tags ).to eq({ 'taga' => taga, 'tagb' => tagb, 'tagc' => tagc })
      end
    end
  end

  describe '#figure_out_tags_to_include' do
    it 'should call include_tag_title for each title in the given string' do
      list = Wayground::TagList.new
      list.should_receive(:include_tag_title).with('a')
      list.should_receive(:include_tag_title).with('b')
      list.should_receive(:include_tag_title).with('c')
      list.figure_out_tags_to_include('a,b,c')
    end
  end

  describe '#tag_titles_from_string' do
    it 'should strip leading quotes and spaces' do
      expect( Wayground::TagList.new.tag_titles_from_string(" '\" text") ).to eq ['text']
    end
    it 'should strip trailing quotes and spaces' do
      expect( Wayground::TagList.new.tag_titles_from_string("text\" ' ") ).to eq ['text']
    end
    it 'should split on commas, stripping adjacent quotes and spaces' do
      expect( Wayground::TagList.new.tag_titles_from_string("a\",'b , c ' ,d") ).to eq ['a', 'b', 'c', 'd']
    end
  end

  describe '#include_tag_title' do
    it 'should ignore blank titles' do
      list = Wayground::TagList.new
      list.include_tag_title(' "-.!" ')
      expect( list.tagged ).to eq []
    end
    it 'should call through to ensure_tag_title' do
      list = Wayground::TagList.new
      list.should_receive(:ensure_tag_title).with('A Tag')
      list.include_tag_title('A Tag')
    end
    it 'should not create duplicates' do
      list = Wayground::TagList.new
      list.tagged = ['a', 'b']
      list.include_tag_title('A')
      list.include_tag_title('B')
      expect( list.tagged ).to eq ['a', 'b']
    end
  end

  describe '#ensure_tag_title' do
    it 'should call through to update_existing_tag' do
      list = Wayground::TagList.new
      list.should_receive(:update_existing_tag).with('ensure').and_return(true)
      list.ensure_tag_title('ensure')
    end
    it 'should call through to new_tag when it doesn’t update_existing_tag' do
      list = Wayground::TagList.new
      list.stub(:update_existing_tag).with('ensure').and_return(false)
      list.should_receive(:new_tag).with('ensure')
      list.ensure_tag_title('ensure')
    end
  end

  describe '#update_existing_tag' do
    context 'with no matching existing tag' do
      it 'should do nothing' do
        tags = []
        tags.stub(:all).and_return(tags)
        list = Wayground::TagList.new(tags: tags)
        list.determine_existing_tags
        expect( list.update_existing_tag('Not Present') ).to be_nil
      end
    end
    context 'with a matching existing tag with the same title' do
      before(:all) do
        @tag = Tag.new(title: 'same title')
      end
      before(:each) do
        @tags = [@tag]
        @tags.stub(:all).and_return(@tags)
        @list = Wayground::TagList.new(tags: @tags)
        @list.determine_existing_tags
      end
      it 'should not update the tag' do
        Tag.any_instance.should_not_receive(:update_attributes!)
        @list.update_existing_tag('same title')
      end
      it 'should return the tag' do
        expect( @list.update_existing_tag('same title') ).to eq @tag
      end
      it 'should remove the tag from the list of existing tags being tracked' do
        @list.update_existing_tag('same title')
        expect( @list.existing_tags ).to eq({})
      end
    end
    context 'with a matching existing tag with a different title' do
      it 'should update the title for the tag' do
        tag = Tag.new(title: 'Different title.')
        tags = [tag]
        tags.stub(:all).and_return(tags)
        list = Wayground::TagList.new(tags: tags)
        list.determine_existing_tags
        Tag.any_instance.should_receive(:update_attributes!).with(title: 'different title').and_return(true)
        list.update_existing_tag('different title')
      end
    end
  end

  describe '#new_tag' do
    it 'should use the given title for the new tag' do
      list = Wayground::TagList.new(tags: Tag)
      tag = list.new_tag('New Tag')
      expect( tag.tag ).to eq 'newtag'
    end
    it 'should assign the editor as the user for the new tag' do
      user = User.new
      list = Wayground::TagList.new(tags: Tag, editor: user)
      tag = list.new_tag('Tag With Editor')
      expect( tag.user ).to eq user
    end
  end

  describe '#remove_leftover_existing_tags' do
    it 'should send the destroy message to all tags not removed from the existing tags hash' do
      taga = Tag.new(title: 'Tag A')
      tagb = Tag.new(title: 'Tag B')
      tags = [taga, tagb]
      tags.stub(:all).and_return(tags)
      list = Wayground::TagList.new(tags: tags)
      list.determine_existing_tags
      taga.should_receive(:destroy)
      tagb.should_receive(:destroy)
      list.remove_leftover_existing_tags
    end
  end

end
