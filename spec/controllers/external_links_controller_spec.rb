require 'rails_helper'

describe ExternalLinksController, type: :controller do

  before(:all) do
    ExternalLink.delete_all
    Event.delete_all
    Authority.delete_all
    User.delete_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, :name => 'Admin User')
    @user_normal = FactoryGirl.create(:user, :name => 'Normal User')
    # create some extraneous ExternalLinks to make sure we’re not loading :all when we want a subset
    FactoryGirl.create_list(:external_link, 2)
    @event = FactoryGirl.create(:event)
    # create an extra ExternalLink on the event
    FactoryGirl.create(:external_link, item: @event, position: 1)
  end

  def set_logged_in_admin
    allow(controller).to receive(:current_user).and_return(@user_admin)
  end
  def set_logged_in_user
    allow(controller).to receive(:current_user).and_return(@user_normal)
  end

  # This should return the minimal set of attributes required to create a valid
  # ExternalLink. As you add validations to ExternalLink, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {:title => 'Valid Title', :url => 'http://valid.url/'}
  end

  let(:event) { @event }
  let(:external_link) { $external_link = FactoryGirl.create(:external_link, :item => event, :position => 99)}

  describe "GET 'index'" do
    it "returns http success" do
      get :index, params: { event_id: event.id }
      expect(response).to be_success
    end
    it "assigns the item’s external_links as @external_links" do
      external_links = [event.external_links.first, external_link]
      get :index, params: { event_id: event.id }
      expect(assigns(:external_links)).to eq(external_links)
    end
    context 'with an event_id param' do
      it 'assigns the event as @item' do
        get :index, params: { event_id: event.to_param }
        expect(assigns(:item)).to eq(event)
      end
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get :show, params: { event_id: event.id, id: external_link.id }
      expect(response).to be_success
    end
    it "assigns the requested external_link as @external_link" do
      get :show, params: { event_id: event.id, id: external_link.id }
      expect(assigns(:external_link)).to eq(external_link)
    end
    it "returns http missing if invalid id" do
      get :show, params: { event_id: event.id, id: (external_link.id + 10) }
      expect(response.status).to eq 404
    end
    it "returns http missing if invalid item id" do
      get :show, params: { event_id: (event.id + 10), id: external_link.id }
      expect(response.status).to eq 404
    end
  end

  describe "GET 'new'" do
    it "fails if not sufficent authority" do
      set_logged_in_user
      get :new, params: { event_id: event.id }
      expect(response.status).to eq 403
    end

    it "returns http success" do
      set_logged_in_admin
      get :new, params: { event_id: event.id }
      expect(response).to be_success
    end
    it "assigns a new ExternalLink as @external_link" do
      set_logged_in_admin
      get :new, params: { event_id: event.id }
      expect(assigns(:external_link)).to be_a_new(ExternalLink)
    end
    it 'associates the new ExternalLink with the event' do
      set_logged_in_admin
      get :new, params: { event_id: event.id }
      expect( assigns(:external_link).item ).to eq event
    end
  end

  describe "POST 'create'" do
    it "fails if not sufficient authority" do
      set_logged_in_user
      post :create, params: { event_id: event.id, external_link: valid_attributes }
      expect(response.status).to eq 403
    end

    context 'with valid params' do
      it "creates a new Event" do
        set_logged_in_admin
        expect {
          post :create, params: { event_id: event.id, external_link: valid_attributes }
        }.to change(event.external_links, :count).by(1)
      end
      it "assigns a newly created ExternalLink as @external_link" do
        set_logged_in_admin
        post :create, params: { event_id: event.id, external_link: valid_attributes }
        expect(assigns(:external_link)).to be_a(ExternalLink)
        expect(assigns(:external_link)).to be_persisted
      end
      it 'associates the new ExternalLink with the event' do
        set_logged_in_admin
        post :create, params: { event_id: event.id, external_link: valid_attributes }
        expect( assigns(:external_link).item ).to eq event
      end
      it "redirects to the created ExternalLink" do
        set_logged_in_admin
        post :create, params: { event_id: event.id, external_link: valid_attributes }
        expect(response).to redirect_to([event, event.external_links.last])
      end
    end

    context 'with invalid params' do
      it "assigns a newly created but unsaved ExternalLink as @external_link" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalLink).to receive(:save).and_return(false)
        post :create, params: { event_id: event.id, external_link: {} }
        expect(assigns(:external_link)).to be_a_new(ExternalLink)
      end
      it 'associates the new ExternalLink with the event' do
        set_logged_in_admin
        allow_any_instance_of(ExternalLink).to receive(:save).and_return(false)
        post :create, params: { event_id: event.id, external_link: {} }
        expect( assigns(:external_link).item ).to eq event
      end
      it "re-renders the 'new' template" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalLink).to receive(:save).and_return(false)
        post :create, params: { event_id: event.id, external_link: {} }
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET 'edit'" do
    it "requires the user to have authority" do
      set_logged_in_user
      get :edit, params: { event_id: event.id, id: external_link.id }
      expect(response.status).to eq 403
    end

    it "assigns the requested external_link as @external_link" do
      set_logged_in_admin
      get :edit, params: { event_id: event.id, id: external_link.id }
      expect(assigns(:external_link)).to eq(external_link)
    end
  end

  describe "PUT 'update'" do
    it "requires the user to have authority" do
      set_logged_in_user
      patch :update, params: { event_id: event.id, id: external_link.id, external_link: { 'these' => 'params' } }
      expect(response.status).to eq 403
    end

    describe "with valid params" do
      it "updates the requested external_link" do
        set_logged_in_admin
        # This specifies that the ExternalLink receives the :update message
        # with whatever params are submitted in the request.
        expected_params = ActionController::Parameters.new('title' => 'valid_params').permit!
        expect_any_instance_of(ExternalLink).to receive(:update).with(expected_params)
        patch :update, params: { event_id: event.id, id: external_link.id, external_link: { 'title' => 'valid_params' } }
      end

      it "assigns the requested external_link as @external_link" do
        set_logged_in_admin
        patch :update, params: { event_id: event.id, id: external_link.id, external_link: valid_attributes }
        expect(assigns(:external_link)).to eq(external_link)
      end

      it "redirects to the external_link" do
        set_logged_in_admin
        patch :update, params: { event_id: event.id, id: external_link.id, external_link: valid_attributes }
        expect(response).to redirect_to([event, external_link])
      end
    end

    describe "with invalid params" do
      it "assigns the external_link as @external_link" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalLink).to receive(:save).and_return(false)
        patch :update, params: { event_id: event.id, id: external_link.id, external_link: { url: 'invalid url' } }
        expect(assigns(:external_link)).to eq(external_link)
      end

      it "re-renders the 'edit' template" do
        set_logged_in_admin
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExternalLink).to receive(:save).and_return(false)
        patch :update, params: { event_id: event.id, id: external_link.id, external_link: { url: 'invalid url' } }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "GET 'delete'" do
    it "requires the user to have authority" do
      set_logged_in_user
      get :delete, params: { event_id: event.id, id: external_link.id }
      expect(response.status).to eq 403
    end

    it "shows a form for confirming deletion of an external_link" do
      set_logged_in_admin
      get :delete, params: { event_id: event.id, id: external_link.id }
      expect(assigns(:external_link)).to eq external_link
    end
  end

  describe "DELETE 'destroy'" do
    it "requires the user to have authority" do
      set_logged_in_user
      delete :destroy, params: { event_id: event.id, id: external_link.id }
      expect(response.status).to eq 403
    end

    it "destroys the requested external_link" do
      set_logged_in_admin
      delete_this = FactoryGirl.create(:external_link, :item => event)
      expect {
        delete :destroy, params: { event_id: event.id, id: delete_this.id }
      }.to change(event.external_links, :count).by(-1)
    end

    it "redirects to the containing item" do
      set_logged_in_admin
      delete_this = FactoryGirl.create(:external_link, :item => event)
      delete :destroy, params: { event_id: event.id, id: delete_this.id }
      expect(response).to redirect_to(event)
    end
  end

end
