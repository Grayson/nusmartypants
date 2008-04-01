;; source files
(set @m_files     (array "./smartypants.m"))
(set @nu_files 	  (array "./smartypants.nu"))

;; framework description
(set @framework "SmartyPants")
(set @framework_identifier   "nu.programming.smartypants")
(set @framework_creator_code "????")
(set @framework_initializer  "SmartyPantsInit")


(set @frameworks  '("Cocoa" "Nu"))
(set @includes    "")

(compilation-tasks)
(framework-tasks)

(task "clobber" => "clean" is
      (SH "rm -rf #{@framework_dir}"))


(task "install" => "framework" is
      (SH "sudo rm -rf /Library/Frameworks/#{@framework}.framework")
      (SH "ditto #{@framework}.framework /Library/Frameworks/#{@framework}.framework"))

(task "default" => "framework")

(task "doc" is (SH "nudoc"))
