; Set up lazy.nvim
(let [lazypath (vim.fs.joinpath (vim.fn.stdpath :data) :/lazy/lazy.nvim)]
  (vim.opt.runtimepath:prepend lazypath))

(fn get_extension [filename ext]
  (filename:sub (- (+ (length ext) 1))))

(fn strip_extension [filename ext]
  (filename:sub 1 (- (+ (length ext) 2))))

(local PLUGINS :plugins)

(local specs [])
(each [_ lang (ipairs [:lua :fnl])]
  (let [findpath (vim.fs.joinpath (vim.fn.stdpath :config) lang PLUGINS)
        findopts {:path findpath :type :file :limit math.huge}
        findinput (fn [name]
                    (if (= (get_extension name lang) (.. "." lang)) true
                        false))
        paths (vim.fs.find findinput findopts)]
    (each [_ path (ipairs paths)]
      (let [basename (vim.fs.basename path)
            without_ext (strip_extension basename lang)
            module_name (.. PLUGINS "." without_ext)
            spec (require module_name)]
        (table.insert specs spec)))))

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
