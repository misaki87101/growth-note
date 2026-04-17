# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: '"Growth Note" <fukumatsu@nail-box.net>'
  layout "mailer"
end
