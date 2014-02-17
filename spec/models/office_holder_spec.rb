# encoding: utf-8
require 'spec_helper'
require 'office_holder'
require 'office'
require 'person'

describe OfficeHolder do

  before(:all) do
    OfficeHolder.delete_all
    @office = Office.first || FactoryGirl.create(:office)
    @office2 = Office.offset(1).first || FactoryGirl.create(:office)
    @person = Person.first || FactoryGirl.create(:person)
  end

  describe 'acts_as_authority_controlled' do
    it 'should be in the “Democracy” area' do
      OfficeHolder.authority_area.should eq 'Democracy'
    end
  end

  describe 'attribute mass assignment security' do
    it 'should not allow office' do
      expect {
        OfficeHolder.new(office: Office.new)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it 'should not allow office_id' do
      expect {
        OfficeHolder.new(office_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it 'should not allow person' do
      expect {
        OfficeHolder.new(person: Person.new)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it 'should not allow person_id' do
      expect {
        OfficeHolder.new(person_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it 'should not allow previous' do
      expect {
        OfficeHolder.new(previous: OfficeHolder.new)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it 'should not allow previous_id' do
      expect {
        OfficeHolder.new(previous_id: 1)
      }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error)
    end
    it 'should allow start_on' do
      date = 1.day.ago.to_date
      expect( OfficeHolder.new(start_on: date).start_on ).to eq date
    end
    it 'should allow end_on' do
      date = 1.day.ago.to_date
      expect( OfficeHolder.new(end_on: date).end_on ).to eq date
    end
  end

  describe '#office' do
    it 'should allow a user to be set' do
      office = Office.new
      holder = OfficeHolder.new
      holder.office = office
      expect( holder.office ).to eq office
    end
  end

  describe '#person' do
    it 'should allow a user to be set' do
      person = Person.new
      holder = OfficeHolder.new
      holder.person = person
      expect( holder.person ).to eq person
    end
  end

  describe '#previous' do
    it 'should allow a user to be set' do
      previous = OfficeHolder.new
      holder = OfficeHolder.new
      holder.previous = previous
      expect( holder.previous ).to eq previous
    end
  end

  describe 'validation' do
    let(:required) { $required = { start_on: 1.day.ago } }
    it 'should validate with all required values' do
      holder = @office.office_holders.build(required)
      holder.person = @person
      expect( holder.valid? ).to be_true
    end
    describe 'of office' do
      it 'should fail if office is not set' do
        holder = OfficeHolder.new(required)
        holder.person = @person
        expect( holder.valid? ).to be_false
      end
    end
    describe 'of person' do
      it 'should fail if person is not set' do
        holder = @office.office_holders.build(required)
        expect( holder.valid? ).to be_false
      end
    end
    describe 'of previous' do
      it 'should fail if previous is not for the same office' do
        not_same_office = @office2.office_holders.build(required)
        not_same_office.person = @person
        holder = @office.office_holders.build(required)
        holder.person = @person
        holder.previous = not_same_office
        expect( holder.valid? ).to be_false
      end
      it 'should fail if previous starts after this holder' do
        other_holder = @office.office_holders.build(required.merge(start_on: 5.days.from_now))
        other_holder.person = @person
        holder = @office.office_holders.build(required.merge(start_on: 4.days.from_now))
        holder.person = @person
        holder.previous = other_holder
        expect( holder.valid? ).to be_false
      end
      it 'should validate with an appropriate previous holder' do
        other_holder = @office.office_holders.build(required.merge(start_on: 6.days.ago))
        other_holder.person = @person
        holder = @office.office_holders.build(required.merge(start_on: 7.days.from_now))
        holder.person = @person
        holder.previous = other_holder
        expect( holder.valid? ).to be_true
      end
    end
    describe 'of start_on' do
      it 'should fail if start_on is nil' do
        holder = @office.office_holders.build(required.merge(start_on: nil))
        holder.person = @person
        expect( holder.valid? ).to be_false
      end
      it 'should fail if start_on is blank' do
        holder = @office.office_holders.build(required.merge(start_on: ''))
        holder.person = @person
        expect( holder.valid? ).to be_false
      end
    end
    describe 'of end_on' do
      it 'should fail if end_on is before start_on' do
        holder = @office.office_holders.build(required.merge(start_on: 1.day.ago, end_on: 2.days.ago))
        holder.person = @person
        expect( holder.valid? ).to be_false
      end
      it 'should validate if end_on is the same date as start_on' do
        date = 3.days.ago
        holder = @office.office_holders.build(required.merge(start_on: date, end_on: date))
        holder.person = @person
        expect( holder.valid? ).to be_true
      end
      it 'should validate if end_on is after start_on' do
        holder = @office.office_holders.build(required.merge(start_on: 5.days.ago, end_on: 4.days.ago))
        holder.person = @person
        expect( holder.valid? ).to be_true
      end
    end
  end

end