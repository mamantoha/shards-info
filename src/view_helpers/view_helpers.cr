require "ecr"

module ViewHelpers
  extend self

  def local_datetime(time : Time, format = "%Y-%m-%d %H:%M:%S") : String
    %(<time class="js-local-datetime" datetime="#{time.to_rfc3339}">#{time.to_s(format)}</time>)
  end

  record Paginator, current_page : Int32, per_page : Int32, total_count : Int64, link : String do
    ECR.def_to_s "#{__DIR__}/paginate.ecr"
  end
end
