# encoding: utf-8
require 'party'
require 'level'

# RESTful controller for Party records.
# Called as a sub-controller under LevelsController
class PartiesController < ApplicationController
  before_action :set_user
  before_action :set_level
  before_action :set_party, only: [:show, :edit, :update, :delete, :destroy]
  before_action :prep_new, only: [:new, :create]
  before_action :prep_edit, only: [:edit, :update]
  before_action :prep_delete, only: [:delete, :destroy]
  before_action :set_section

  def index
    page_metadata(title: 'Parties')
    @parties = @level.parties
  end

  def show
    page_metadata(title: "Party “#{@party.name}”")
  end

  def new; end

  def create
    if @party.save
      redirect_to([@level, @party], notice: 'The party has been saved.')
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    if @party.update_attributes(params[:party])
      redirect_to([@level, @party], notice: 'The party has been saved.')
    else
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Party “#{@party.name}”")
  end

  def destroy
    @party.destroy
    redirect_to level_parties_url(@level)
  end

  protected

  def set_user
    @user = current_user
  end

  def set_level
    @level = Level.from_param(params[:level_id]).first
  end

  def set_party
    @party = @level.parties.from_param(params[:id]).first
  end

  def set_section
    @site_section = :parties
  end

  def prep_new
    requires_authority(:can_create)
    page_metadata(title: 'New Party')
    @party = @level.parties.new(params[:party])
  end

  def prep_edit
    requires_authority(:can_update)
    page_metadata(title: "Edit Party “#{@party.name}”")
  end

  def prep_delete
    requires_authority(:can_delete)
  end

  def requires_authority(action)
    unless (
      (@party && @party.has_authority_for_user_to?(@user, action)) ||
      (@user && @user.has_authority_for_area(Party.authority_area, action))
    )
      raise Wayground::AccessDenied
    end
  end

end
