namespace :jcropper do
  desc "Install .CSS and .js files required for view helpers to function. Will not overwrite"
  task :install => :environment do
    root = File.join(File.dirname(__FILE__), '..')
    install_file(File.join(root, 'public/images/Jcrop.gif'), File.join(Rails.root, 'public/images/Jcrop.gif'))
    install_file(File.join(root, 'public/javascripts/jquery.Jcrop.min.js'), File.join(Rails.root, 'public/javascripts/jquery.Jcrop.min.js'))
    install_file(File.join(root, 'public/javascripts/jcropper.js'), File.join(Rails.root, 'public/javascripts/jcropper.js'))
    install_file(File.join(root, 'public/stylesheets/jquery.Jcrop.css'), File.join(Rails.root, 'public/stylesheets/jquery.Jcrop.css'))
  end
  
  private 
  def install_file(from, to)
    if File.exists? to
      puts "#{to} exists, will not overwrite. Remove first."
    else
      puts "Installing file to #{to}"
      FileUtils.cp(from, to)
    end
  end
end