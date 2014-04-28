module RevealCK
  module Builders
    # Given a location of the user's reveal-ck files, a Rake
    # application, and a place where everything should end up, this
    # class knows how to work with Rake and build up a presentation
    # with the user's stuff.
    class CopyUserFiles
      require 'rake'

      attr_reader :user_files_dir, :output_dir
      attr_reader :application
      attr_reader :things_to_create

      def initialize(args)
        @user_files_dir = args[:user_files_dir] || fail(':user_files_dir is required')
        @output_dir     = args[:output_dir]     || fail(':output_dir is required')
        @application    = args[:application]    || fail(':application is required')
        @things_to_create = Set.new
        analyze
      end

      private

      def analyze
        files = UserFiles.new(user_files_dir: user_files_dir)
        files.all.each do |file|
          analyze_file(file)
        end
        application.define_task(Rake::Task, 'copy_user_files' => things_to_create.to_a)
      end

      def analyze_file(file)
        dest = file.pathmap("%{^#{user_files_dir}/,#{output_dir}/}p")
        application.define_task(Rake::FileTask, dest => file) do
          FileUtils.cp file, dest
        end
        dest_dir = dest.pathmap('%d')
        application.define_task(Rake::Task, dest_dir) do
          FileUtils.mkdir_p dest_dir
        end
        things_to_create.add(dest_dir)
        things_to_create.add(dest)
      end
    end

  end
end
