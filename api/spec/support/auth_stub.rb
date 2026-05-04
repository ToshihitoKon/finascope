# frozen_string_literal: true

module AuthStub
  TEST_UID = "test_user_uid_001"

  def stub_authenticated_user(uid: TEST_UID)
    allow(Firebase).to receive(:decode_jwt).and_return(
      uid: uid, name: "Test User", picture_url: nil
    )
  end

  def auth_header(uid: TEST_UID)
    { "HTTP_AUTHORIZATION" => "Bearer dummy.jwt.token.#{uid}" }
  end
end
