require 'gettext/utils'

task :update_po do
     GetText.update_pofiles('shinjiko', Dir.glob("#{RAILS_ROOT}/app/**/*.{rb,html.erb}"), 'Shinjiko 1.0.0')
end

task :make_mo do
     GetText.create_mofiles(true, 'po', 'locale')
end
