module Dyn
  module FeatureHelper
    module EmailHelpers

      def find_email(email_address, table=nil)
        Merb::Mailer.deliveries.detect do |email| 
          status = true
          if(!email.bcc.blank?)
            status &&= email.bcc.include?(email_address)
          end
          if(!email.to.blank?)
            status &&= email.to.include?(email_address)
          end
          unless table.nil?
            table.rows.each do |row|
              field, value = row.first, row.last
              val = case field
              when /subject( contains)?/
                status &&= email.subject.to_s =~ /#{Regexp.escape(email.quoted_printable_encode_header(value))}/
              when /body contains$/
                status &&= email.text =~ /#{Regexp.escape(value)}/
              when /body does not contain$/
                status &&= !(email.text =~ /#{Regexp.escape(value)}/)
              when /attachments/
                filenames = email.attachments
                status &&= !filenames.nil? && value.split(',').all?{|m| filenames.map(&:original_filename).include?(m) }
              else
                raise "The field #{field} is not supported, please update this step if you intended to use it."
              end
            end
          end
          status
        end
      end
      
    end
  end
end

World(Dyn::FeatureHelper::EmailHelpers)