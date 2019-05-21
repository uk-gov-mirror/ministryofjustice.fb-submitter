class TemplateMappingService
  class Email
    ALL = {
      'email.return.setup.email.token' => '38f6a1cd-a810-4f59-8899-2c300236c5b4',
      'email.return.setup.email.verified' => '54ac8d51-3dc5-43c1-9ce8-81bf61d08998',
      'email.return.setup.mobile.verified' => '135a4a24-8fe5-40ca-9f77-7c4e196f00f1',
      'email.return.signin.email' => '407d8723-71c4-45db-9607-6750be761d6a',
      'email.return.signin.success' => '7d914db7-e6d8-41d6-b3c9-f14341e10b66',
      'email.generic' => '46a72b64-9541-4000-91a7-fa8a3fa10bf9'
    }

    def self.template_id_for_name(name)
      ALL.fetch(name, ALL['email.generic'])
    end
  end

  class Sms
    ALL = {
      'sms.return.setup.mobile' => '54dcaad7-4967-431d-8606-72b0b80b5c6a',
      'sms.return.signin.mobile' => '6b72dc4-bc79-49c9-8ea6-5a78911fb472',
      'sms.generic' => '9153cfba-4808-4a1d-9b84-784500197651'
    }

    def self.template_id_for_name(name)
      ALL.fetch(name, ALL['sms.generic'])
    end
  end
end
