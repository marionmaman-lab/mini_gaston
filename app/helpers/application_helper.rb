module ApplicationHelper
  def render_markdown(content)
    renderer = Redcarpet::Render::HTML.new(filter_html: true)

    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true
    )

    markdown.render(content.to_s)
  end
  # 45 -> "45 min", 60 -> "1 h", 90 -> "1 h 30", 125 -> "2 h 05"
  def format_duration(minutes)
    minutes = minutes.to_i
    hours, rest = minutes.divmod(60)
    return "#{rest} min" if hours.zero?
    return "#{hours} h" if rest.zero?
    "#{hours} h #{rest.to_s.rjust(2, '0')}"
  end
end
