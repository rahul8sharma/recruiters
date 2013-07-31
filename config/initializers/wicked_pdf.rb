module WickedPdfHelper
  def wicked_pdf_stylesheet_link_tag(*sources)
    css = sources.collect { |source|
      "<style type='text/css'>#{Rails.application.assets.find_asset(source+".sass")}</style>"
    }.join("\n").html_safe
    Rails.logger.info "Hello....#{css}"
    css
  end

  def wicked_pdf_image_tag(img, options={})
    asset = Rails.application.assets.find_asset(img)
    image_tag "file://#{asset.pathname.to_s}", options
  end

  def wicked_pdf_javascript_src_tag(jsfile, options={})
    asset = Rails.application.assets.find_asset(jsfile)
    javascript_include_tag "file://#{asset.pathname.to_s}", options
  end

  def wicked_pdf_javascript_include_tag(*sources)
    sources.collect{ |source| "<script type='text/javascript'>#{Rails.application.assets.find_asset(source+".js")}</script>" }.join("\n").html_safe
  end
end
WickedPdf.config = { :exe_path => '/usr/bin/wkhtmltopdf' }
