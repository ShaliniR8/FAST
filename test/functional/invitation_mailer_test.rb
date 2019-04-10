require 'test_helper'

class InvitationMailerTest < ActionMailer::TestCase
  test "update_invitation" do
    mail = InvitationMailer.update_invitation
    assert_equal "Update invitation", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
