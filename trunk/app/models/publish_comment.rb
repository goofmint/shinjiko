class PublishComment < Iso2022jpMailer
  def sendmail (params)
    recipients params[:to]
    bcc        params[:bcc]
    subject    _("[Shinji-ko] Publish comment")
    from       "admin@moongift.jp"
    body       params
  end
end
