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
end
