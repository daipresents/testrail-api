# frozen_string_literal: true

RSpec.describe 'TestRail' do
  context 'API' do
    context 'Attachments' do
      before(:each) do
        @project_id = RSpec.current_example.metadata[:project_id]
        @case_id = RSpec.current_example.metadata[:case_id]

        @client = TestRail::Client.new

        payload = @client.payload_for_adding_run
        payload[:name] = 'Run Name'
        payload[:description] = 'description'
        @run = @client.add_run(@project_id, payload.compact)

        payload = @client.payload_for_adding_result_for_case
        payload[:status_id] = 1
        payload[:comment] = 'comment'
        payload[:version] = nil
        payload[:elapsed] = '30s'
        payload[:defects] = 'defects'
        payload[:assignedto_id] = 1
        @result = @client.add_result_for_case(@run['id'], @case_id, payload)
      end

      it 'add_attachment_to_result_for_case and delete_attachment and get_attachments_for_case' do
        sample_path = File.join(Bundler.root, 'spec/fixtures/sample.txt')
        @client.add_attachment_to_result_for_case(@result['id'], @case_id, sample_path)

        attachments = @client.get_attachments_for_case(@case_id)
        expect(attachments[0]['project_id']).to eq(@project_id.to_i)
        expect(attachments[0]['case_id']).to eq(@case_id.to_i)
        expect(attachments[0]['result_id']).to eq(@result['id'].to_i)

        @client.delete_attachment(attachments[0]['id'])

        attachments = @client.get_attachments_for_case(@case_id)
        expect(attachments.size).to eq(0)
      end

      it 'add_attachment_to_result and get_attachment and delete_attachment' do
        sample_path = File.join(Bundler.root, 'spec/fixtures/sample.txt')
        attachment = @client.add_attachment_to_result(@result['id'], sample_path)
        result = @client.get_attachment(attachment['attachment_id'])
        expect(result).to eq('This is sample test.')

        # If you want to use attachment, need to write file again
        # File.binwrite("#{sample_path}.copy", result)
      end
    end
  end
end
