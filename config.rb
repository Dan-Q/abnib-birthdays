# Time and Zone
ENV['TZ'] = 'UTC'
require 'time'

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

REMINDER_FREQUENCIES = {
  'wedding anniversary' => [0]
}

helpers do
  def ordinal(n, type = 'birthday')
    suffix = case n % 100
      when 11, 12, 13 then 'th'
      else
        case n % 10
          when 1 then 'st'
          when 2 then 'nd'
          when 3 then 'rd'
          else 'th'
      end
    end
    result = "#{n}#{suffix}"
    if type == 'wedding anniversary'
      # https://en.wikipedia.org/wiki/Wedding_anniversary#Traditional_and_modern_anniversary_gifts
      # https://www.anniversarygifts.co.uk/general-anniversary-articles/list-php/
      result = result + case n
        when  1 then ' (paper)'
        when  2 then ' (cotton)'
        when  3 then ' (leather)'
        when  4 then ' (linen)'
        when  5 then ' (wood)'
        when  6 then ' (sugar/iron)'
        when  7 then ' (woollen/copper)'
        when  8 then ' (salt/bronze)'
        when  9 then ' (copper/pottery)'
        when 10 then ' (tin)'
        when 11 then ' (steel)'
        when 12 then ' (silk/fine linen)'
        when 13 then ' (lace)'
        when 14 then ' (ivory)'
        when 15 then ' (crystal)'
        when 20 then ' (porcelain/china)'
        when 25 then ' (silver)'
        when 30 then ' (pearl)'
        when 35 then ' (coral)'
        when 40 then ' (ruby)'
        when 45 then ' (sapphire)'
        when 50 then ' (gold)'
        when 55 then ' (emerald)'
        when 60 then ' (diamond)'
        when 65 then ' (blue sapphire)'
        when 70 then ' (platinum)'
        when 75 then ' (diamond/gold)'
        when 80 then ' (oak)'
        when 85 then ' (wine)'
        when 90 then ' (granite/stone)'
        else ''
      end
    end
    result
  end

  def birthdays
    today = Date.today
    all_birthdays = data.birthdays.map do |id, birthday|
      birthday['id'] = id
      next_birthday_is_this_year = (birthday.month > today.month || (birthday.month == today.month && birthday.day >= today.day))
      next_birthday_year = next_birthday_is_this_year ? today.year : today.year + 1
      birthday['date'] = begin
        Date.new(next_birthday_year, birthday.month, birthday.day)
      rescue Date::Error => e
        raise e unless birthday.month == 2 && birthday.day == 29
        # catch date errors where the celebrant was born on a leap day and celebrate their birthday on 3 March instead
        Date.new(next_birthday_year, 3, 1)
      end
      birthday['age'] = next_birthday_year - birthday.year if birthday.year
      birthday
    end
    all_birthdays.sort_by{|birthday| birthday['date']}
  end

  def reminders
    today = Date.today
    all_reminders = []
    birthdays.each do |birthday|
      reminder_frequencies = REMINDER_FREQUENCIES[birthday['type'] || 'birthday'] || [0, 1, 7]
      reminders = reminder_frequencies.map do |lead|
        {
          'id' => "#{birthday['id']}-#{birthday['date'].year}-#{lead}",
          'birthday' => birthday,
          'date' => birthday['date'] - lead,
          'lead' => lead,
          'when' => (lead == 0 ? 'today' : (lead == 1 ? 'tomorrow' : "in #{lead} days"))
        }
      end
      all_reminders += reminders.reject{|reminder| reminder['date'] > today}
    end
    all_reminders.sort_by{|reminder| reminder['date']}
  end

  def describe_birthday(birthday)
    if birthday['type'] && birthday['type'] != 'birthday'
      if birthday['age']
        return birthday.name.gsub('{n}', birthday['age'].to_s).gsub('{nth}', ordinal(birthday['age'], birthday['type']))
      else
        return birthday.name
      end
    else
      result = "#{birthday.name}'s" unless birthday.name =~ /s$/
      result = [result, ordinal(birthday['age'])].join(' ') if birthday['age']
      return "#{result} birthday"
    end
  end
end

# helpers do
#   def some_helper
#     'Helping'
#   end
# end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# configure :build do
#   activate :minify_css
#   activate :minify_javascript
# end
