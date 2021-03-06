require_relative 'html_presenter'

# Present a ExternalLink.
class ExternalLinkPresenter < HtmlPresenter
  attr_reader :view, :link, :user

  def initialize(view:, link:, user: nil)
    @view = view
    @link = link
    @user = user
  end

  def present_link_in(tag_type = :span)
    html_tag(tag_type, class: link_class) do
      present_label + present_link_as_url_class
    end
  end

  def present_label
    if label_text.present?
      html_tag(:span, class: 'label') { "#{label_text}: ".html_safe }
    else
      html_blank
    end
  end

  def present_link_as_url_class
    link_title = link.title
    view.link_to(link_title, link.url, class: 'url', title: link_title, target: '_blank')
  end

  def present_link
    link_title = link.title
    view.link_to(link_title, link.url, class: link_url_class, title: link_title, target: '_blank')
  end

  protected

  def link_class
    link_site = link.site
    if link_site.present?
      html_escape(link_site)
    else
      'website'.html_safe
    end
  end

  def link_url_class
    'url '.html_safe + link_class
  end

  def label_text
    {
      'facebook' => 'Facebook', 'flickr' => 'Flickr', 'google' => 'Google',
      'instagram' => 'Instagram', 'linkedin' => 'LinkedIn', 'twitter' => 'Twitter',
      'vimeo' => 'Vimeo', 'youtube' => 'YouTube'
    }[link.site]
  end
end
