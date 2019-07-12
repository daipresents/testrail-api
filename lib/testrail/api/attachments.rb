# frozen_string_literal: true

module TestRail
  module API
    module Attachments
      def add_attachment_to_result(result_id, file_path)
        _send_attachment("add_attachment_to_result/#{result_id}", file_path)
      end

      def add_attachment_to_result_for_case(result_id, case_id, file_path)
        _send_attachment("add_attachment_to_result_for_case/#{result_id}/#{case_id}", file_path)
      end

      def get_attachments_for_case(case_id)
        send_get("get_attachments_for_case/#{case_id}")
      end

      # TODO: testing
      def get_attachments_for_test(test_id)
        send_get("get_attachments_for_test/#{test_id}")
      end

      def get_attachment(attachment_id)
        _get_attachment("get_attachment/#{attachment_id}")
      end

      def delete_attachment(attachment_id)
        send_post("delete_attachment/#{attachment_id}", nil)
      end

      private

      def _send_attachment(uri, file_path)
        url = URI.parse(@url + uri)
        request = Net::HTTP::Post.new(url.path + '?' + url.query)
        request.basic_auth(@user, @password)

        data = [['attachment', File.open(file_path, 'r'), { filename: File.basename(file_path) }]]
        request.set_form(data, 'multipart/form-data')

        conn = Net::HTTP.new(url.host, url.port)
        if url.scheme == 'https'
          conn.use_ssl = true
          conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        response = conn.request(request)
        result = JSON.parse(response.body) if response.body && !response.body.empty?

        return result if response.code == '200'

        if result&.key?('error')
          raise_api_error(response.code, '"' + result['error'] + '"')
        else
          raise_api_error(response.code, 'No additional error message received')
        end
      end

      def _get_attachment(uri)
        url = URI.parse(@url + uri)
        request = Net::HTTP::Get.new(url.path + '?' + url.query)
        request.basic_auth(@user, @password)
        request.add_field('Content-Type', 'application/json')

        conn = Net::HTTP.new(url.host, url.port)
        if url.scheme == 'https'
          conn.use_ssl = true
          conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        response = conn.request(request)
        result = response.body if response.body && !response.body.empty?

        return result if response.code == '200'

        if result&.key?('error')
          raise_api_error(response.code, '"' + result['error'] + '"')
        else
          raise_api_error(response.code, 'No additional error message received')
        end
      end

      def raise_api_error(response_code, error)
        raise APIError.new('TestRail API returned HTTP %s (%s)' % [response_code, error])
      end
    end
  end
end
