# frozen_string_literal: true
require 'csv'

module Zizia
  class MetadataDetails
    include Singleton

    def details(work_attributes:)
      validators = work_attributes.validators
      detail_list = work_attributes.properties.sort.map { |p| definition_hash_for(p, validators) }
      detail_list << visibility_definition
      detail_list << file_definition
      detail_list.sort_by { |prop| prop[:label] }
    end

    def to_csv(work_attributes:)
      attribute_list = details(work_attributes: work_attributes)
      headers = extract_headers(attribute_list[0])
      csv_string = CSV.generate do |csv|
        csv << headers
        attribute_list.each do |attribute|
          csv << headers.map { |h| attribute[h] }
        end
      end
      csv_string
    end

    private

    def csv_header(field)
      Zizia.config.metadata_mapper_class.csv_header(field) || "not configured"
    end

    def extract_headers(attribute_hash)
      headers = attribute_hash.keys.sort
      headers = [:attribute] + (headers - [:attribute])     # force :attribute to the beginning of the list
      headers = (headers - [:usage]) + [:usage]             # force :usage to the end of the list becuause it's so long
      headers
    end

    def required_on_form_to_s(attribute)
      Hyrax::Forms::WorkForm.required_fields.include?(attribute.to_sym).to_s
    end

    def type_to_s(type)
      return 'Not specified' if type.blank?
      type.to_s
    end

    def validator_to_string(validator:)
      case validator
      when ActiveModel::Validations::PresenceValidator
        'required'
      else
        'No validation present in the model.'
      end
    end

    def definition_hash_for(field_properties, validators)
      Hash[
        label: I18n.t("simple_form.labels.defaults.#{field_properties[0]}"),
        attribute: field_properties[0],
        predicate: field_properties[1].predicate.to_s,
        multiple: field_properties[1].try(:multiple?).to_s,
        type: type_to_s(field_properties[1].type),
        validator: validator_to_string(validator: validators[field_properties[0].to_sym][0]),
        csv_header: csv_header(field_properties[0]),
        required_on_form: required_on_form_to_s(field_properties[0]),
        usage: MetadataUsage.instance.usage[field_properties[0]]
      ]
    end

    def file_definition
      {
        attribute: 'files',
        predicate: 'n/a',
        multiple: 'true',
        type: 'String',
        validator: 'Required, must name a file on the server',
        label: 'Files',
        csv_header: 'files',
        required_on_form: 'true',
        usage: MetadataUsage.instance.usage['files']
      }
    end

    def visibility_definition
      {
        attribute: 'visibility',
        predicate: 'n/a',
        multiple: 'false',
        type: 'String',
        validator: 'Required, must exist in the application\'s controlled vocabulary for visiblity levels.',
        label: 'Visibility',
        csv_header: 'visibility',
        required_on_form: 'true',
        usage: MetadataUsage.instance.usage['visibility']
      }
    end
  end
end
