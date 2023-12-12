# frozen_string_literal: true

class WeeklyDigestNotification < ScoutplanNotification
  deliver_by :email, mailer: "WeeklyDigestMailer", if: :email?
  deliver_by :twilio, if: :sms?, format: :format_for_twilio, credentials: :twilio_credentials, ignore_failure: true

  param :unit

  def format_for_twilio
    {
      From: ENV.fetch("TWILIO_NUMBER"),
      To:   recipient.phone,
      Body: sms_body(recipient: recipient, unit: params[:unit])
    }
  end

  def feature_enabled?
    recipient.unit.settings(:communication).digest == "true"
  end
end
