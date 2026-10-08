require 'asciidoctor-mathematical'
require 'tmpdir'

module SpecHelpers
  attr_reader :tmp_dir

  # Parse source with the extension active. The tree processor runs during load,
  # so assertions on the document tree hold for any backend (html5, pdf, ...)
  def load_doc source, attributes = {}
    ::Asciidoctor.load source, safe: :safe, base_dir: tmp_dir,
      attributes: { 'stem' => 'latexmath', 'imagesdir' => 'images' }.merge(attributes)
  end

  def generated_files
    (Dir.glob '**/*', base: tmp_dir).select {|path| ::File.file? ::File.join tmp_dir, path }.sort
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
  config.disable_monkey_patching!
  config.warnings = true

  config.around do |example|
    Dir.mktmpdir 'asciidoctor-mathematical-' do |dir|
      @tmp_dir = dir
      example.run
    end
  end
end
