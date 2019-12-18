FactoryBot.define do
  submission_id = SecureRandom.uuid

  factory :submission do
    service_slug { 'service-slug' }
    encrypted_user_id_and_token { 'some token' }
    transient do
      meta do
        {
          'submission_id' => submission_id,
          'submission_at' => '2019-12-18T09:25:59.238Z'
        }
      end
      actions { [] }
      attachments { [] }
      submission do
        {
          'submission_id' => submission_id,
          'pdf_heading' => 'Application against a refusal of criminal legal aid on interests of justice grounds',
          'pdf_subheading' => 'IOJ',
          'sections' => [
            {
              'heading' => 'Case details',
              'summary_heading' => '',
              'questions' => []
            },
            {
              'heading' => '',
              'summary_heading' => '',
              'questions' => [
                {
                  'label' => 'Unique submission number (USN)',
                  'answer' => '1234567',
                  'key' => 'usn'
                }
              ]
            },
            {
              'heading' => 'MAAT number',
              'summary_heading' => '',
              'questions' => []
            },
            {
              'heading' => '',
              'summary_heading' => '',
              'questions' => [
                {
                  'label' => 'MAAT number',
                  'answer' => '6123456',
                  'key' => 'maat[1]'
                }
              ]
            },
            {
              'heading' => 'Defendant’s details',
              'summary_heading' => '',
              'questions' => []
            },
            {
              'heading' => '',
              'summary_heading' => '',
              'questions' => [
                {
                  'label' => 'Full name',
                  'answer' => 'john doe',
                  'key' => 'fullname'
                },
                {
                  'label' => 'Date of birth',
                  'answer' => '1 January 1990',
                  'key' => 'dob'
                }
              ]
            },
            {
              'heading' => 'Solicitor’s details',
              'summary_heading' => '',
              'questions' => []
            },
            {
              'heading' => '',
              'summary_heading' => '',
              'questions' => [
                {
                  'label' => 'Full name',
                  'answer' => 'Mr Solicitor',
                  'key' => 'solicitor_fullname'
                },
                {
                  'label' => 'Firm',
                  'answer' => 'Pearson',
                  'key' => 'firm'
                },
                {
                  'label' => 'Email address',
                  'answer' => 'info@solicitor.co.uk',
                  'key' => 'solicitor_email'
                },
                {
                  'label' => 'Legal aid provider account number',
                  'answer' => '1A234B',
                  'key' => 'lapan'
                }
              ]
            },
            {
              'heading' => 'Offence',
              'summary_heading' => '',
              'questions' => []
            },
            {
              'heading' => '',
              'summary_heading' => '',
              'questions' => [
                {
                  'label' => 'Offence type',
                  'answer' => 'Grand theft auto',
                  'key' => 'offence[1].type'
                },
                {
                  'label' => 'Date of offence',
                  'answer' => '1 January 1990',
                  'key' => 'offence[1].date'
                },
                {
                  'label' => 'Reasons for appeal',
                  'answer' => 'A genuine reason',
                  'key' => 'offence[1].reasons'
                }
              ]
            },
            {
              'heading' => '',
              'summary_heading' => '',
              'questions' => []
            },
            {
              'heading' => '',
              'summary_heading' => '',
              'questions' => [
                {
                  'label' => 'Attach any documentation that supports your appeal',
                  'answer' => [{
                    'fieldname' => 'upload[1]',
                    'originalname' => 'hello_world.txt',
                    'encoding' => '7bit',
                    'mimetype' => 'text/plain'
                  }],
                  'human_value' => 'an-image.jpg',
                  'key' => 'documentation'
                }
              ]
            }
          ]
        }
      end
    end

    payload do
      EncryptionService.new.encrypt(
        meta: meta, actions: actions, submission: submission, attachments: attachments
      )
    end

    trait :json do
      actions do
        [
          {
            type: 'json',
            url: 'https://my-custom-endpoint/ap/v1/foo',
            encryption_key: 'jdwjdwjwdhwhdh73'
          }
        ]
      end
    end

    trait :csv do
      actions do
        [
          {
            type: 'csv',
            user_answers: {
              first_name: 'Bob',
              last_name: 'Smith',
              'has-email': 'yes',
              email_address: 'bob.smith@digital.justice.gov.uk',
              complaint_details: 'Foo bar baz',
              'checkbox-apples' => 'yes',
              'checkbox-pears' => 'yes',
              date: '2007-11-12',
              number_cats: 28,
              cat_spy: 'machine answer 3',
              cat_breed: 'California Spangled',
              upload: [{ filename: 'cat.jpg' }]
            }
          }
        ]
      end
    end

    trait :email do
      actions do
        [
          {
            'from' => 'some.one@example.com',
            'to' => 'destination@example.com',
            'subject' => 'mail subject',
            'type' => 'email',
            'email_body' => 'some plain text'
          }
        ]
      end
    end

    created_at { Time.current }
    updated_at { Time.current }
  end
end
