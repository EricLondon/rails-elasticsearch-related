class User < ActiveRecord::Base
  acts_as_taggable_on :interests

  #
  # Elasticsearch integration - start
  #

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include Elasticsearch::Model::Indexing

  def as_indexed_json(_options = {})
    as_json.merge(
      'interests' => interest_list
    )
  end

  def search_more_like_this(how_many = nil)
    how_many = 5 unless how_many.is_a?(Integer)

    search_definition = {
      query: {
        more_like_this: {
          fields: tag_types,
          docs: [
            {
              _index: self.class.index_name,
              _type: self.class.document_type,
              _id: id
            }
          ],
          min_term_freq: 1
        }
      },
      size: how_many
    }

    self.class.__elasticsearch__.search(search_definition)
  end

  #
  # Elasticsearch integration - end
  #
end
