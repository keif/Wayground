require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe PagesController, type: :controller do

  before(:all) do
    Authority.delete_all
    User.delete_all
    Page.delete_all
    @default_admin = FactoryGirl.create(:user, email: 'test+mockadmin@wayground.ca', name: 'The Admin')
    @default_page = FactoryGirl.create(:page)
  end

  def default_page
    @default_page
  end

  def set_logged_in_default_admin
    allow(controller).to receive(:current_user).and_return(@default_admin)
  end

  def mock_page(stubs={})
    @mock_page ||= mock_model(Page, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all pages as @pages" do
      allow(controller).to receive(:paginate).with(Page).and_return([mock_page])
      get :index
      expect(assigns(:pages)).to eq([mock_page])
    end
  end

  describe "GET show" do
    it "assigns the requested page as @page" do
      set_logged_in_default_admin
      allow(Page).to receive(:find).with("37") { mock_page }
      get :show, :id => "37"
      expect(assigns(:page)).to be(mock_page)
    end
  end

  describe "GET new" do
    it "requires the user to have authority" do
      get :new
      expect(response.status).to eq 403
    end

    it "assigns a new page as @page" do
      set_logged_in_default_admin
      allow(Page).to receive(:new) { mock_page }
      get :new
      expect(assigns(:page)).to be(mock_page)
    end

    it "assigns the parent page if given" do
      set_logged_in_default_admin
      parent_page = FactoryGirl.create(:page)
      get :new, :parent => parent_page.id.to_s
      expect(assigns(:page).parent).to eq parent_page
    end
  end

  describe "POST create" do
    it "requires the user to have authority" do
      post :create
      expect(response.status).to eq 403
    end

    describe "with valid params" do
      it "assigns a newly created page as @page" do
        set_logged_in_default_admin
        page = default_page
        allow(page).to receive(:save).and_return(true)
        allow(Page).to receive(:new).with('filename' => 'valid_params').and_return(page)
        post :create, page: { 'filename' => 'valid_params' }
        expect(assigns(:page)).to be(page)
      end

      it "assigns the parent page if given" do
        set_logged_in_default_admin
        parent_page = FactoryGirl.create(:page)
        parent_page.path ||= FactoryGirl.create(:path, :item => parent_page)
        post(:create,
          parent: parent_page.id.to_s,
          page: { filename: 'spec_create_with_parent', title: 'test' }
        )
        expect(assigns(:page).parent).to eq parent_page
      end

      it "redirects to the created page" do
        set_logged_in_default_admin
        page = default_page
        allow(Page).to receive(:new).and_return(page)
        allow(page).to receive(:save).and_return(true)
        post :create, :page => {}
        expect(response).to redirect_to(page_url(page))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved page as @page" do
        set_logged_in_default_admin
        post :create, page: { 'invalid' => 'params' }
        page = assigns(:page)
        expect(page.new_record?).to be_truthy
        expect(page.errors).not_to be_nil
      end

      it "re-renders the 'new' template" do
        set_logged_in_default_admin
        allow(Page).to receive(:new) { mock_page(:save => false) }
        post :create, :page => {}
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET edit" do
    it "requires the user to have authority" do
      test_page = FactoryGirl.create(:page)
      get :edit, :id => test_page.id.to_s
      expect(response.status).to eq 403
    end

    it "assigns the requested page as @page" do
      set_logged_in_default_admin
      allow(Page).to receive(:find).with("37") { mock_page }
      get :edit, :id => "37"
      expect(assigns(:page)).to be(mock_page)
    end
  end

  describe "PUT update" do
    it "requires the user to have authority" do
      test_page = FactoryGirl.create(:page)
      patch :update, id: test_page.id.to_s
      expect(response.status).to eq 403
    end

    describe "with valid params" do
      it "updates the requested page" do
        set_logged_in_default_admin
        page = default_page
        allow(Page).to receive(:find).with(page.id.to_s) { page }
        expect(page).to receive(:update).with('filename' => 'valid_params')
        patch :update, id: page.id.to_s, page: { 'filename' => 'valid_params' }
      end

      it "assigns the requested page as @page" do
        set_logged_in_default_admin
        page = default_page
        allow(Page).to receive(:find) { page }
        allow(page).to receive(:update).and_return(true)
        patch :update, id: page.id.to_s
        expect(assigns(:page)).to be(page)
      end

      it "redirects to the page" do
        set_logged_in_default_admin
        page = default_page
        allow(Page).to receive(:find) { page }
        allow(page).to receive(:update).and_return(true)
        patch :update, id: page.id.to_s
        expect(response).to redirect_to(page_url(page))
      end
    end

    describe "with invalid params" do
      it "assigns the page as @page" do
        set_logged_in_default_admin
        allow(Page).to receive(:find) { mock_page(update: false) }
        patch :update, id: '1'
        expect(assigns(:page)).to be(mock_page)
      end

      it "re-renders the 'edit' template" do
        set_logged_in_default_admin
        allow(Page).to receive(:find) { mock_page(update: false) }
        patch :update, id: '1'
        expect(response).to render_template("edit")
      end
    end
  end

  describe "GET delete" do
    it "requires the user to have authority" do
      test_page = FactoryGirl.create(:page)
      get :delete, :id => test_page.id.to_s
      expect(response.status).to eq 403
    end

    it "shows a form for confirming deletion of a page" do
      set_logged_in_default_admin
      allow(Page).to receive(:find).with("37") { mock_page }
      get :delete, :id => "37"
      expect(assigns(:page)).to be(mock_page)
    end
  end

  describe "DELETE destroy" do
    it "requires the user to have authority" do
      test_page = FactoryGirl.create(:page)
      delete :destroy, :id => test_page.id.to_s
      expect(response.status).to eq 403
    end

    it "destroys the requested page" do
      set_logged_in_default_admin
      allow(Page).to receive(:find).with("37") { mock_page }
      expect(mock_page).to receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the pages list" do
      set_logged_in_default_admin
      allow(Page).to receive(:find) { mock_page }
      delete :destroy, :id => "1"
      expect(response).to redirect_to(pages_url)
    end
  end

end
