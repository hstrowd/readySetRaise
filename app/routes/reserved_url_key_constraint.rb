class ReservedUrlKeyConstraint
  def matches?(request)
    !ApplicationController.reserved_routing_keywords.include?(request.params[:org_url_key])
  end
end
