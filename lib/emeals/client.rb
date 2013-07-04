require 'emeals/menu'

require 'fileutils'
require 'tempfile'

class Emeals::Client
  def parse(filename_or_file)
    temp_file = copy_to_temp_file(filename_or_file)
    text = pdf_to_text(temp_file.path)

    Emeals::Menu.parse(text)
  end

  private

  def copy_to_temp_file(filename_or_file)
    Tempfile.open(['menu', '.pdf']) do |temp|
      temp.binmode
      temp.write(filename_or_file.is_a?(String) ? File.read(filename_or_file) : filename_or_file.read)
      temp
    end
  end

  def pdf_to_text(filename)
    system(pdf_to_text_path, '-raw', '-enc', 'UTF-8', filename)
    File.read(filename.sub(/\.pdf$/, '.txt'))
  end

  def pdf_to_text_path
    path = `which pdftotext`.chop
    return '/opt/boxen/homebrew/bin/pdftotext' if path.empty?
    path
  end
end