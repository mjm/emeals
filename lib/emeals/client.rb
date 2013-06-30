require 'emeals/menu'

require 'fileutils'
require 'tempfile'

class Emeals::Client
  def parse(filename)
    file = copy_to_temp_file(filename)
    text = pdf_to_text(file.path)

    Emeals::Menu.parse(text)
  end

  private

  def copy_to_temp_file(filename)
    Tempfile.open(['menu', '.pdf']) do |temp|
      temp.write(File.read(filename))
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