require 'test_helper'

class MeetingMailerTest < ActionMailer::TestCase
  test "new_meeting" do
    mail = MeetingMailer.new_meeting
    assert_equal "New meeting", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "cancel_meeting" do
    mail = MeetingMailer.cancel_meeting
    assert_equal "Cancel meeting", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "cancel_invitation" do
    mail = MeetingMailer.cancel_invitation
    assert_equal "Cancel invitation", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
