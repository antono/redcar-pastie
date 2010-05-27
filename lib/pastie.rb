require 'net/http'
require 'uri'

module Redcar

  class Pastie

    def self.keymaps
      linwin = Keymap.build("main", [:linux, :windows]) do
        link "Ctrl+Shift+P", Pastie::PasteSelection
      end

      osx = Keymap.build("main", :osx) do
        link "Cmd+Shift+P", Pastie::PasteSelection
      end

      [linwin, osx]
    end

    def self.menus
      Menu::Builder.build do
        sub_menu "Plugins" do
          sub_menu "Pastie" do
            item "Paste selection", PasteSelection
            item "Select service", SelectService
          end
        end
      end
    end

    class PasteSelection < EditTabCommand
      def execute        
        text    = doc.selection? ? doc.selected_text : doc.to_s
        resp    = paste_text(text)        
        message = resp || "Can't paste :("        
        Application::Dialog.message_box(message)
      end

      private

      def paste_text(text)
        uri = URI.parse('http://gist.github.com/api/v1/xml/new')
        res = Net::HTTP.post_form(uri, { "files[#{tab.title}]" => text })
        if res.code == '200'
          'http://gist.github.com/' + res.body.match(/repo>(\d+)</)[1]
        else
          false
        end
      end
    end

    class SelectService < Redcar::Command
      def execute
      end
    end
  end
end
