; Set up lazy.nvim
(let [lazypath (vim.fs.joinpath (vim.fn.stdpath :data) :/lazy/lazy.nvim)]
  (vim.opt.runtimepath:prepend lazypath))

(fn get-extension [filename ext]
  (filename:sub (- (+ (length ext) 1))))

(fn strip-extension [filename ext]
  (filename:sub 1 (- (+ (length ext) 2))))

(fn list-concat [a b]
  (-> []
      (vim.list_extend a)
      (vim.list_extend b)))

(local PLUGINS :plugins)

(local specs (accumulate [specs [] _ lang (ipairs [:lua :fnl])]
               (let [find-path (vim.fs.joinpath (vim.fn.stdpath :config) lang
                                                PLUGINS)
                     find-opts {:path find-path :type :file :limit math.huge}
                     find-input (fn [name]
                                  (if (= (get-extension name lang)
                                         (.. "." lang))
                                      true
                                      false))
                     find-results (vim.fs.find find-input find-opts)
                     specs-in-lang (icollect [_ path (ipairs find-results)]
                                     (let [basename (vim.fs.basename path)
                                           without-ext (strip-extension basename
                                                                        lang)
                                           module-name (.. PLUGINS "."
                                                           without-ext)]
                                       (require module-name)))]
                 (list-concat specs specs-in-lang))))

(let [setup (. (require :lazy) :setup)]
  (setup {:spec specs
          :defaults {; lazy by default
                     :lazy true}
          ; I used to enable auto check for update.
          ; But this will cause lazy to write :messages on every launch,
          ; consuming some of my keystrokes.
          ; This is quite annoying.
          ;:checker {
          ;  :enabled true
          ;}
          ; Do not detect change when I am editing plugin configs.
          :change_detection {:enabled false}
          ; I do not use Nerd Font.
          :ui {:icons {:cmd "⌘"
                       :config "🛠"
                       :event "📅"
                       :ft "📂"
                       :init "⚙"
                       :keys "🗝"
                       :plugin "🔌"
                       :runtime "💻"
                       :require "🌙"
                       :source "📄"
                       :start "🚀"
                       :task "📌"
                       :lazy "💤"}}}))

; Return nil because this module is intended for side effects.
nil
