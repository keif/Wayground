# encoding: utf-8

class PathsController < ApplicationController
  before_filter :requires_authority, :except => [:sitepath, :index]
  before_filter :set_path, :except => [:sitepath, :index, :new, :create]
  before_filter :set_breadcrumbs, :except => [:sitepath, :index]
  before_filter :set_new, :only => [:new, :create]
  before_filter :set_edit, :only => [:edit, :update]

  # process arbitrary paths
  def sitepath
    sitepath = params[:url]
    @path = Path.find_for_path(sitepath)

    if @path.nil?
      if sitepath == '/'
        respond_to do |format|
          format.html { render :template=>'paths/default_home' }
          format.xml  { render :xml => nil }
        end
      else
        missing
      end
    elsif @path.redirect?
      redirect_to @path.redirect
    else
      render_path_item(@path.item)
    end
  end

  # GET /paths
  # GET /paths.xml
  def index
    @page_title = 'Custom Paths'
    @paths = Path.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @paths }
    end
  end

  # GET /paths/1
  # GET /paths/1.xml
  def show
    @page_title = "Custom Path: #{@path.sitepath}"
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @path }
    end
  end

  # GET /paths/new
  # GET /paths/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @path }
    end
  end

  # POST /paths
  # POST /paths.xml
  def create
    respond_to do |format|
      if @path.save
        format.html { redirect_to(@path, :notice => 'Path was successfully created.') }
        format.xml  { render :xml => @path, :status => :created, :location => @path }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @path.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /paths/1/edit
  def edit
  end

  # PUT /paths/1
  # PUT /paths/1.xml
  def update
    respond_to do |format|
      if @path.update_attributes(params[:path])
        format.html { redirect_to(@path, :notice => 'Path was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @path.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /paths/1/delete
  def delete
    raise Wayground::AccessDenied unless current_user.has_authority_for_area('Content', :can_delete)
    @page_title = "Delete Custom Path: #{@path.sitepath}"
  end

  # DELETE /paths/1
  # DELETE /paths/1.xml
  def destroy
    @path.destroy

    respond_to do |format|
      format.html { redirect_to(paths_url) }
      format.xml  { head :ok }
    end
  end

  protected

  # The actions for this controller all require that the user is authorized to view Authority records.
  def requires_authority
    unless current_user && current_user.has_authority_for_area(Path.authority_area)
      raise Wayground::AccessDenied
    end
  end

  # Most of the actions for this controller receive the id of an Authority as a parameter.
  def set_path
    @path = Path.find(params[:id])
  end

  # Breadcrumbs for actions on this controller start with the index page.
  def set_breadcrumbs
    @site_breadcrumbs = [{:text => 'Paths', :url => paths_path}]
  end

  def set_new
    @page_title = 'New Custom Path'
    @path = Path.new(params[:path])
  end

  def set_edit
    @page_title = "Edit Custom Path: #{@path.sitepath}"
  end

  def render_path_item(item)
    # TODO: handle security-access for private items
    if item.is_a? Page
      render_item_as_page(item)
    # TODO: handle use of Paths for items other than Pages
    #elsif item.is_a? ???
    else
      respond_to do |format|
        format.html do
          render :template => 'paths/unimplemented', :status => '501 Not Implemented'
        end
        format.xml { render :xml => item }
      end
    end
  end

  def render_item_as_page(item)
      @page = item
      @page_title = @page.title
      @content_for_description = @page.description
      @site_breadcrumbs = @page.breadcrumbs
#      page_nav_links(@page)
      respond_to do |format|
        format.html { render :template => 'paths/page' }
        format.xml  { render :xml => @page }
      end
  end
end
