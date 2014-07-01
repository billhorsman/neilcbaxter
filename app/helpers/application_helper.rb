module ApplicationHelper


  # Add some automatic classes to the <body> tag to help with
  # CSS scoping.
  def body_class
    a = [controller.controller_name, "_#{controller.action_name}"]
    # Adding namescope in body class
    a << controller.class.name.split("::").first.downcase if defined?(controller.class) && controller.class.name.split("::").length > 1
    a << @extra_body_class if @extra_body_class.present?
    a.join(" ")
  end

  # Works well with Bootstap navs
  # http://twitter.github.com/bootstrap/components.html#navs
  #
  # Wraps up a normal link_to in a <li> tag and gives that tag
  # an 'active' class if it determines that the page we're on
  # right now is the same place as the one that is linked to.
  #
  # That's pretty simple if you're just linking to a single page
  # or resource because it assumes that any paths that start with
  # the linked path are also 'active'. E.g.
  #
  #   = smart_link_to "Users", [:admin, :users]
  #
  # will be active for the following URLs:
  #
  #   /admin/users
  #   /admin/users/1
  #   /admin/users/new
  #   etc.
  #
  # If that behaviour is not what you want then you can pass your
  # own regular expression in the :pattern option. E.g.
  #
  #  = smart_link_to "Home", root_path, pattern: /\A\/\Z/
  #
  # It'll pass any :wrapper_options as options to the wrapper <li>
  # tag.
  #
  # A complete example might look like this, in HAML:
  #
  # %ul.nav
  #   = smart_link_to "Home", root_path, pattern: /\A\/\Z/
  #   = smart_link_to "Sign Up", new_signup_path
  #
  # It works with the block form of link_to too.
  #
  def smart_link_to(*args, &block)
    if block_given?
      options = args[0] || {}
      html_options = args[1]
      caption = capture(&block)
    else
      caption = args[0]
      options = args[1] || {}
      html_options = args[2]
    end
    html_options ||= {}
    li_options = html_options.delete(:wrapper_options) || {}
    li_classes = li_options[:class].present? ? li_options.delete(:class).split(" ") : []
    url = String === options ? options : url_for(options)
    if html_options.delete(:just_path)
      url = url.split("?")[0]
    end
    pattern = html_options.delete(:pattern) || Regexp.new("^#{url}#{'$' if html_options.delete(:strict)}")
    count = html_options.delete(:count)
    if count.to_i > 0
      caption += decorate_pill(count)
      html_options[:class] = [html_options[:class], "with-count"].join(" ").strip
    end
    if html_options[:icon]
      caption = "#{content_tag(:i, "", class: "fa fa-fw fa-#{html_options[:icon]}")} #{caption}".html_safe
    end
    if when_buying = html_options.delete(:when_buying)
      li_classes += when_buying.split(" ").map {|t| "#{when_buying}-when-buying" }
    end
    if hide = html_options.delete(:hide)
      li_classes += Array(hide).map {|size| "hide-#{size}"}
    end
    if show = html_options.delete(:show)
      li_classes += Array(show).map {|size| "show-#{size}"}
    end
    if tooltip = html_options.delete(:tooltip)
      li_options[:data] ||= {}
      li_options[:data][:toggle] = "tooltip"
      li_options[:data][:title] = tooltip
    end
    path = request.path
    if html_options[:override] || path =~ pattern
      li_classes << "active"
    end
    if html_options.delete(:pull) == :right
      li_classes << "pull-right"
    end
    if html_options.delete(:action)
      li_classes << "action"
    end
    li_options[:class] = li_classes.any? ? li_classes.join(" ") : nil
    content_tag :li, li_options do
      link_to caption.html_safe, options, html_options
    end
  end

end
