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
        
        # Copy url to clipboard or show message
        if(storage['auto_copy_to_clipboard'] && resp)
          Redcar.app.clipboard << resp
        else
          message = resp || "Can’t paste. Try again."
          Application::Dialog.message_box(message)
        end
      end

      private
      def storage
        @storage ||= Plugin::Storage.new('pastie_plugin')
        @storage.set_default('login', '')
        @storage.set_default('token', '')
        @storage.set_default('auto_copy_to_clipboard', 'true')
        @storage
      end
      
      def paste_text(text)
        uri = URI.parse('http://gist.github.com/api/v1/xml/new')
        req = Net::HTTP::Post.new(uri.path)
        
        # In case of auth fail just post as anonymous
        req.basic_auth(storage['login'] + '/token', storage['token'])
        req.set_form_data({ "files[#{tab.title}]" => text })
        res = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
        if(res.code == '200')
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
