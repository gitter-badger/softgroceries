require 'rails_helper'

RSpec.describe OauthsController, :type => :controller do

  describe "GET callback" do
    let(:user) { create(:user) }

    it "Should redirect to kit successfully if user found" do
      expect_any_instance_of(OauthsController).to receive(:login_from).with('provider').and_return(user)
      get :callback, provider: 'provider'

      expect(response).to redirect_to root_path
      expect(flash[:notice]).to be_present
    end

    it "Should create a user and activate it if no existing user is found" do
      expect_any_instance_of(OauthsController).to receive(:login_from).with('github').and_return(nil)
      expect_any_instance_of(OauthsController).to receive(:create_from).and_return(user)

      get :callback, provider: 'github', code: '123'

      expect(controller.current_user).to eq(user)
      expect(response).to redirect_to user_groups_path
      expect(flash[:notice]).to be_present
    end
  end
end
