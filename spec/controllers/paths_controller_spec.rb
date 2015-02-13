require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe PathsController, type: :controller do

  before(:all) do
    Authority.delete_all
    User.delete_all
    Path.delete_all
    @default_admin = FactoryGirl.create(:user, email: 'test+mockadmin@wayground.ca', name: 'The Admin')
    @default_path = FactoryGirl.create(:path, {:redirect => '/'})
  end

  def default_path
    @default_path
  end

  def set_logged_in_default_admin
    allow(controller).to receive(:current_user).and_return(@default_admin)
  end

  def mock_path(stubs={})
    @mock_path ||= mock_model(Path, stubs).as_null_object
  end

  describe "GET sitepath" do
    it "displays the default home page if the root url was called and there is no Path found" do
      get :sitepath, {:url => '/'}
      expect(response).to render_template('default_home')
    end
    it "shows the 404 missing error if no Path was found and not the root url" do
      get :sitepath, {:url => '/no/such/path'}
      expect(response.status).to eq 404
      expect(response).to render_template('missing')
    end
    it "redirects if the Path is a redirect" do
      path = FactoryGirl.create(:path, {:redirect => '/'})
      get :sitepath, {:url => path.sitepath}
      expect(response).to redirect_to('/')
    end
    it "shows the Page if the Path’s item is a Page" do
      page = FactoryGirl.create(:page)
      path = FactoryGirl.create(:path, {:item => page})
      get :sitepath, {:url => path.sitepath}
      expect(response.status).to eq 200
      expect(response).to render_template('page')
      expect(assigns(:page)).to eq page
    end
    it "shows the 501 unimplemented error if the Path’s item is not supported" do
      set_logged_in_default_admin
      item = FactoryGirl.create(:user)
      path = FactoryGirl.create(:path, {:item => item})
      get :sitepath, {:url => path.sitepath}
      expect(response.status).to eq 501
    end
    it "shows the 404 missing error if the Path’s item requires authority to view" do
      page = FactoryGirl.create(:page, {:is_authority_controlled => true})
      path = FactoryGirl.create(:path, {:item => page})
      get :sitepath, {:url => path.sitepath}
      expect(response.status).to eq 404
    end
    it "allows an authorized user to access an authority controlled item" do
      set_logged_in_default_admin
      page = FactoryGirl.create(:page, {:is_authority_controlled => true})
      path = FactoryGirl.create(:path, {:item => page})
      get :sitepath, {:url => path.sitepath}
      expect(response.status).to eq 200
    end
  end

  describe "GET index" do
    it "assigns all paths as @paths" do
      set_logged_in_default_admin
      allow(controller).to receive(:paginate).and_return([mock_path])
      get :index
      expect(assigns(:paths)).to eq([mock_path])
    end
  end

  describe "GET show" do
    it "assigns the requested path as @path" do
      set_logged_in_default_admin
      allow(Path).to receive(:find).with("37") { mock_path }
      get :show, :id => "37"
      expect(assigns(:path)).to be(mock_path)
    end
  end

  describe "GET new" do
    it "requires the user to have authority" do
      get :new
      expect(response.status).to eq 403
    end

    it "assigns a new path as @path" do
      set_logged_in_default_admin
      allow(Path).to receive(:new) { mock_path }
      get :new
      expect(assigns(:path)).to be(mock_path)
    end
  end

  describe "POST create" do
    it "requires the user to have authority" do
      post :create
      expect(response.status).to eq 403
    end

    describe "with valid params" do
      it "assigns a newly created path as @path" do
        set_logged_in_default_admin
        path = default_path
        allow(Path).to receive(:new).with({'these' => 'params'}) { path }
        allow(path).to receive(:save).and_return(true)
        post :create, :path => {'these' => 'params'}
        expect(assigns(:path)).to be(path)
      end

      it "redirects to the created path" do
        set_logged_in_default_admin
        path = default_path
        allow(Path).to receive(:new) { path }
        allow(path).to receive(:save).and_return(true)
        post :create, :path => {}
        expect(response).to redirect_to(path_url(path))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved path as @path" do
        set_logged_in_default_admin
        allow(Path).to receive(:new).with({'these' => 'params'}) { mock_path(:save => false) }
        post :create, :path => {'these' => 'params'}
        expect(assigns(:path)).to be(mock_path)
      end

      it "re-renders the 'new' template" do
        set_logged_in_default_admin
        allow(Path).to receive(:new) { mock_path(:save => false) }
        post :create, :path => {}
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET edit" do
    it "requires the user to have authority" do
      path = FactoryGirl.create(:path, {:redirect => '/'})
      get :edit, :id => path.id.to_s
      expect(response.status).to eq 403
    end

    it "assigns the requested path as @path" do
      set_logged_in_default_admin
      allow(Path).to receive(:find).with("37") { mock_path }
      get :edit, :id => "37"
      expect(assigns(:path)).to be(mock_path)
    end
  end

  describe "PUT update" do
    it "requires the user to have authority" do
      patch :update, id: default_path.id.to_s
      expect(response.status).to eq 403
    end

    describe "with valid params" do
      it "updates the requested path" do
        set_logged_in_default_admin
        path = default_path
        allow(Path).to receive(:find).with(path.id.to_s) { path }
        expect(path).to receive(:update).with('these' => 'params').and_return(true)
        patch :update, id: path.id.to_s, path: { 'these' => 'params' }
      end

      it "assigns the requested path as @path" do
        set_logged_in_default_admin
        path = default_path
        allow(Path).to receive(:find) { path }
        allow(path).to receive(:update).and_return(true)
        patch :update, id: path.id.to_s
        expect(assigns(:path)).to be(path)
      end

      it "redirects to the path" do
        set_logged_in_default_admin
        path = default_path
        allow(Path).to receive(:find) { path }
        allow(path).to receive(:update).and_return(true)
        patch :update, id: path.id.to_s
        expect(response).to redirect_to(path_url(path))
      end
    end

    describe "with invalid params" do
      it "assigns the path as @path" do
        set_logged_in_default_admin
        path = default_path
        allow(Path).to receive(:find) { path }
        allow(path).to receive(:update).and_return(false)
        patch :update, id: path.id.to_s
        expect(assigns(:path)).to be(path)
      end

      it "re-renders the 'edit' template" do
        set_logged_in_default_admin
        path = default_path
        allow(Path).to receive(:find) { path }
        allow(path).to receive(:update).and_return(false)
        patch :update, id: path.id.to_s
        expect(response).to render_template("edit")
      end
    end
  end

  describe "GET delete" do
    it "requires the user to have authority" do
      path = FactoryGirl.create(:path, {:redirect => '/'})
      get :delete, :id => path.id.to_s
      expect(response.status).to eq 403
    end
    it "shows a form for confirming deletion of a path" do
      set_logged_in_default_admin
      allow(Path).to receive(:find).with("37") { mock_path }
      get :delete, :id => "37"
      expect(assigns(:path)).to be(mock_path)
    end
  end

  describe "DELETE destroy" do
    it "requires the user to have authority" do
      path = FactoryGirl.create(:path, {:redirect => '/'})
      delete :destroy, :id => path.id.to_s
      expect(response.status).to eq 403
    end

    it "destroys the requested path" do
      set_logged_in_default_admin
      allow(Path).to receive(:find).with("37") { mock_path }
      expect(mock_path).to receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the paths list" do
      set_logged_in_default_admin
      allow(Path).to receive(:find) { mock_path }
      delete :destroy, :id => "1"
      expect(response).to redirect_to(paths_url)
    end
  end

end
