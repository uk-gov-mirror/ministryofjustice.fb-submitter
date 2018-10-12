require 'rails_helper'

describe Submission do
  describe '#unique_urls' do
    context 'when the submission_details has multiple entries' do
      let(:details) do
        [
            {
              'destination' => 'email_address_1',
              'files' => [
                'url_1',
                'url_2'
              ]
            },
            {
              'destination' => 'email_address_2',
              'files' => [
                'url_3',
                'url_2'
              ]
            }
        ]
      end

      before do
        subject.submission_details = details
      end

      describe 'the return value' do
        it 'is an array' do
          expect(subject.unique_urls).to be_a(Array)
        end

        it 'has every url from the details only once, with no duplicates' do
          expect(subject.unique_urls).to eq(['url_1', 'url_2', 'url_3'])
        end
      end
    end
  end
end
