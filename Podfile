use_frameworks!

target 'iOSBuckExample' do
    pod 'RxSwift'
    pod 'RxCocoa'
end

post_install do |installer|
  require 'fileutils'

  # Assuming we're at the root dir
  buck_files_dir = 'buck-files'
  if File.directory?(buck_files_dir)
    installer.pod_targets.flat_map do |pod_target|
      pod_name = pod_target.pod_name
      # Copy the file at buck-files/BUCK_pod_name to Pods/pod_name/BUCK,
      # override existing file if needed
      buck_file = buck_files_dir + '/BUCK_' + pod_name
      bridging_file_name =  pod_name + "-Bridging-Header.h"
      bridging_header_File = buck_files_dir + "/" + bridging_file_name

      if File.file?(buck_file)
        FileUtils.cp(buck_file, 'Pods/' + pod_name + '/BUCK', :preserve => false)
      end

      if File.file?(bridging_header_File)
        FileUtils.cp(bridging_header_File, 'Pods/' + pod_name + '/' + bridging_file_name, :preserve => false)
      end
    end
  end
end
