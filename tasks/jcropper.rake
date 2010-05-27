namespace :jcropper do
  desc "install files"
  task :install => :environment do
    root = File.join(File.dirname(__FILE__), '..')
    FileUtils.cp(File.join(root, 'public/images/Jcrop.gif'), File.join(Rails.root, 'public/images/Jcrop.gif'))
    FileUtils.cp(File.join(root, 'public/javascripts/jquery.Jcrop.min.js'), File.join(Rails.root, 'public/javascripts/jquery.Jcrop.min.js'))
    FileUtils.cp(File.join(root, 'public/javascripts/jcropper.js'), File.join(Rails.root, 'public/javascripts/jcropper.js'))
    FileUtils.cp(File.join(root, 'public/stylesheets/jquery.Jcrop.css'), File.join(Rails.root, 'public/stylesheets/jquery.Jcrop.css'))
  end
end