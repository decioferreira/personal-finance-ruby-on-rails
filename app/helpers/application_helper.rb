module ApplicationHelper
  def nav_link_to(name, path)
    active = current_page?(path)

    classes = [ "rounded-lg px-3 py-2 text-sm font-medium transition" ]
    classes << if active
      "bg-indigo-50 text-indigo-600"
    else
      "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
    end

    link_to name, path, class: classes.join(" "), "aria-current": (active ? "page" : nil)
  end
end
