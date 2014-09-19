module ApplicationHelper

  def user_image(user)
    if user.image.present?
      image_tag("http://dananos.brinkster.net/GifProxy.aspx?url=#{user.image}", class: 'm-user-image')
    else
      content_tag :div, class: 'm-user-image as-default' do
        user.short_name
      end
    end
  end

  def user_balance(user)
    percentage = user.win_percentage
    "#{percentage}% (#{user.number_of_games} games)"
  end

  def league_present?
    current_league.present?
  end

  def facebook_connect_path(league)
    "/auth/facebook"
  end

  def twitter_connect_path(league)
    "/auth/twitter"
  end

  def positive_negative(difference)
    "as-#{difference > 0 ? 'positive' : 'negative'}"
  end

  def signed(number)
    sprintf("%+d", number)
  end

  def match_css_classes(match, difference)
    css = [positive_negative(difference)]
    css << 'as-crawling' if match.crawling?
    css.join(' ')
  end

  def svg_tag(path)
    file = File.open("#{Rails.root}/app/assets/images/#{path}", "rb")
    raw(file.read)
  end

  def other_locale(locale)
    case locale
      when :de
        :en
      when :en
        :de
      else
        I18n.default_locale
      end
  end

  def picturefill_image_tag(regular, retina, options = {})
    srcset = "#{asset_path(regular)}, #{asset_path(retina)} 2x"
    image_tag(regular, options.merge(srcset: srcset))
  end

end
