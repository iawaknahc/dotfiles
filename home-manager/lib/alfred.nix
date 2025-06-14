{
  pkgs,
  ...
}:
let
  libplist = (import ./plist.nix) { inherit pkgs; };
in
rec {
  scriptFilter = args: libplist.toPlist (makeScriptFilter args);

  makeScriptFilter =
    {
      bundleid,
      keyword,
      scriptfile,
      universalaction_uid,
      scriptfilter_uid,
      clipboard_uid,
    }:
    libplist.dict [
      {
        key = "bundleid";
        value = bundleid;
      }
      {
        key = "connections";
        value = libplist.dict [
          {
            key = universalaction_uid;
            value = [
              (libplist.dict [
                {
                  key = "destinationuid";
                  value = scriptfilter_uid;
                }
                {
                  key = "modifiers";
                  value = 0;
                }
                {
                  key = "modifiersubtext";
                  value = "";
                }
                {
                  key = "vitoclose";
                  value = true;
                }
              ])
            ];
          }
          {
            key = scriptfilter_uid;
            value = [
              (libplist.dict [
                {
                  key = "destinationuid";
                  value = clipboard_uid;
                }
                {
                  key = "modifiers";
                  value = 0;
                }
                {
                  key = "modifiersubtext";
                  value = "";
                }
                {
                  key = "vitoclose";
                  value = false;
                }
              ])
            ];
          }
        ];
      }
      {
        key = "createdby";
        value = "";
      }
      {
        key = "description";
        value = "";
      }
      {
        key = "disabled";
        value = false;
      }
      {
        key = "name";
        value = keyword;
      }
      {
        key = "objects";
        value = [
          (libplist.dict [
            {
              key = "config";
              value = libplist.dict [
                {
                  key = "alfredfiltersresults";
                  value = false;
                }
                {
                  key = "alfredfiltersresultsmatchmode";
                  value = 0;
                }
                {
                  key = "argumenttreatemptyqueryasnil";
                  value = true;
                }
                {
                  key = "argumenttrimmode";
                  value = 0;
                }
                {
                  key = "argumenttype";
                  value = 1;
                }
                {
                  key = "escaping";
                  value = 0;
                }
                {
                  key = "keyword";
                  value = keyword;
                }
                {
                  key = "queuedelaycustom";
                  value = 3;
                }
                {
                  key = "queuedelayimmediatelyinitially";
                  value = true;
                }
                {
                  key = "queuedelaymode";
                  value = 0;
                }
                {
                  key = "queuemode";
                  value = 1;
                }
                {
                  key = "runningsubtext";
                  value = "";
                }
                {
                  key = "script";
                  value = "";
                }
                {
                  key = "scriptargtype";
                  value = 1;
                }
                {
                  key = "scriptfile";
                  value = toString scriptfile;
                }
                {
                  key = "subtext";
                  value = "";
                }
                {
                  key = "title";
                  value = "";
                }
                {
                  key = "type";
                  value = 8;
                }
                {
                  key = "withspace";
                  value = true;
                }
              ];
            }
            {
              key = "type";
              value = "alfred.workflow.input.scriptfilter";
            }
            {
              key = "uid";
              value = scriptfilter_uid;
            }
            {
              key = "version";
              value = 3;
            }
          ])

          (libplist.dict [
            {
              key = "config";
              value = libplist.dict [
                {
                  key = "autopaste";
                  value = false;
                }
                {
                  key = "clipboardtext";
                  value = "{query}";
                }
                {
                  key = "ignoredynamicplaceholders";
                  value = false;
                }
                {
                  key = "transient";
                  value = false;
                }
              ];
            }
            {
              key = "type";
              value = "alfred.workflow.output.clipboard";
            }
            {
              key = "uid";
              value = clipboard_uid;
            }
            {
              key = "version";
              value = 3;
            }
          ])
          (libplist.dict [
            {
              key = "config";
              value = libplist.dict [
                {
                  key = "acceptsfiles";
                  value = false;
                }
                {
                  key = "acceptsmulti";
                  value = 0;
                }
                {
                  key = "acceptstext";
                  value = true;
                }
                {
                  key = "acceptsurls";
                  value = false;
                }
                {
                  key = "name";
                  value = keyword;
                }
              ];
            }
            {
              key = "type";
              value = "alfred.workflow.trigger.universalaction";
            }
            {
              key = "uid";
              value = universalaction_uid;
            }
            {
              key = "version";
              value = 1;
            }
          ])
        ];
      }
      {
        key = "readme";
        value = "";
      }
      {
        key = "uidata";
        value = libplist.dict [
          {
            key = universalaction_uid;
            value = libplist.dict [
              {
                key = "xpos";
                value = 30.0;
              }
              {
                key = "ypos";
                value = 115.0;
              }
            ];
          }
          {
            key = scriptfilter_uid;
            value = libplist.dict [
              {
                key = "xpos";
                value = 220.0;
              }
              {
                key = "ypos";
                value = 115.0;
              }
            ];
          }
          {
            key = clipboard_uid;
            value = libplist.dict [
              {
                key = "xpos";
                value = 415.0;
              }
              {
                key = "ypos";
                value = 115.0;
              }
            ];
          }
        ];
      }
      {
        key = "userconfigurationconfig";
        value = [ ];
      }
      {
        key = "variablesdontexport";
        value = [ ];
      }
      {
        key = "version";
        value = "";
      }
      {
        key = "webaddress";
        value = "";
      }
    ];
}
