Spree::HomeController.class_eval do

    helper 'spree/products'
    respond_to :html
    
    helper 'forem/posts'
    before_filter :authenticate_forem_user, :only => [:test]
    before_filter :find_forum, :only => [:test]
    before_filter :block_spammers, :only => [:test]

    def test
      @searcher = Spree::Config.searcher_class.new(params)
      @products = @searcher.retrieve_products
      authorize! :create_topic, @forum
      @topic = @forum.topics.build
      @topic.forum = @forum #added this. Neccesary?    
      @topic.posts.build
    end
  end