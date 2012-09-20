class CommentDecorator
  def initialize(comment)
    @comment = comment
  end

  def formatted_created_at
    @comment.created_at.to_formatted_s(:short)
  end

  def method_missing(method_sym, *args)
    if @comment.respond_to?(method_sym)
      @comment.send(method_sym, *args)
    else
      super
    end
  end
end
