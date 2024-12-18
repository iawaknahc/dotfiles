(fn filetype []
  vim.bo.filetype)

(fn fileencoding []
  vim.bo.fileencoding)

(fn fileencoding-color []
  (if (not= :utf-8 (fileencoding)) :ErrorMsg nil))

(fn fileformat []
  vim.bo.fileformat)

(fn fileformat-color []
  (if (not= :unix (fileformat)) :ErrorMsg nil))

(fn eol []
  (if vim.bo.endofline :eol :NOEOL))

(fn eol-color []
  (if (not= :eol (eol)) :ErrorMsg nil))

(fn navic []
  (let [(status n) (pcall require :nvim-navic)]
    (if (and status (n.is_available)) (n.get_location) "")))

(fn navic-cond []
  (let [(status n) (pcall require :nvim-navic)]
    (if status (n.is_available) false)))

(local theme {:normal {:a :DraculaPurpleBoldInverse
                       :b :DraculaBgLighter
                       :c :DraculaBgLight}
              :insert {:a :DraculaGreenBoldInverse
                       :b :DraculaBgLighter
                       :c :DraculaBgLight}
              :visual {:a :DraculaYellowBoldInverse
                       :b :DraculaBgLighter
                       :c :DraculaBgLight}
              :replace {:a :DraculaRedBoldInverse
                        :b :DraculaBgLighter
                        :c :DraculaBgLight}
              :command {:a :DraculaOrangeBoldInverse
                        :b :DraculaBgLighter
                        :c :DraculaBgLight}
              :inactive {:a :DraculaBgLightBold
                         :b :DraculaBgLighter
                         :c :DraculaBgLight}})

[{1 :nvim-lualine/lualine.nvim
  :enabled true
  :event [:VeryLazy]
  :opts {:options {:icons_enabled false
                   : theme
                   :section_separators ""
                   :component_separators ""}
         :sections {:lualine_a ["%f%m%r%h%w"]
                    :lualine_b [:diff]
                    :lualine_c [:diagnostics]
                    :lualine_x [filetype
                                {1 fileencoding :color fileencoding-color}
                                {1 fileformat :color fileformat-color}
                                {1 eol :color eol-color}]
                    :lualine_y ["%5l:%-5c"]
                    :lualine_z ["%3p%%"]}
         :winbar {:lualine_c [{1 navic :cond navic-cond :draw_empty true}]}}}]
