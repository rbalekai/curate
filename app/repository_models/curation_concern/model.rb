module CurationConcern
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      def human_readable_type
        name.demodulize.titleize
      end
    end

    included do
      include Hydra::ModelMixins::CommonMetadata
      include Sufia::ModelMethods
      include Sufia::GenericFile::Permissions
      include Curate::ActiveModelAdaptor
      include Hydra::Collections::Collectible
      
      extend ClassMethods

      has_metadata name: "properties", type: PropertiesDatastream, control_group: 'M'
      delegate_to :properties, [:relative_path, :depositor], unique: true
      delegate_to :descMetadata, [:archived_object_type], unique: true
      before_save :set_archived_object_type

      class_attribute :human_readable_short_description
    end

    def human_readable_type
      self.class.human_readable_type
    end

    def set_archived_object_type
      self.archived_object_type = human_readable_type
    end

    # Parses a comma-separated string of tokens, returning an array of ids
    def self.ids_from_tokens(tokens)
      tokens.gsub(/\s+/, "").split(',')
    end

    def as_json(options)
      { pid: pid, title: title, model: self.class.to_s, curation_concern_type: archived_object_type }
    end

    def to_solr(solr_doc={}, opts={})
      super(solr_doc, opts)
      index_collection_pids(solr_doc)
      solr_doc[Solrizer.solr_name('noid', Sufia::GenericFile.noid_indexer)] = noid
      Solrizer.set_field(solr_doc, 'desc_metadata__resource_type', 'Work', :facetable)
      return solr_doc
    end

    def to_s
      title
    end

  end
end
