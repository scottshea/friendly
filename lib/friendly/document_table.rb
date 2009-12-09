require 'friendly/table'
require 'active_support/inflector'

module Friendly
  class DocumentTable < Table
    attr_reader :klass, :translator

    def initialize(klass, datastore=Friendly.datastore, translator=Translator.new)
      super(datastore)
      @klass      = klass
      @translator = translator
    end

    def table_name
      klass.name.pluralize.underscore
    end

    def satisfies?(query)
      query.conditions.keys == [:id] && !query.order
    end

    def create(document)
      record = translator.to_record(document)
      id     = datastore.insert(document, record)
      update_document(document, record.merge(:id => id))
    end

    def update(document)
      record = translator.to_record(document)
      datastore.update(document, document.id, record)
      update_document(document, record)
    end

    def destroy(document)
      datastore.delete(document, document.id)
    end

    def first(query)
      record = datastore.first(klass, query)
      record && translator.to_object(klass, record)
    end

    def all(query)
      datastore.all(klass, query).map { |r| translator.to_object(klass, r) }
    end

    protected
      def update_document(document, record)
        document.attributes = record.reject { |k,v| k == :attributes }
      end
  end
end
