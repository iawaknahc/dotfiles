scriptContent:
let
  # https://violentmonkey.github.io/api/metadata-block/
  # https://wiki.greasespot.net/Metadata_Block
  metadataSpec = {
    "name" = {
      type = "localizable";
      field = "name";
    };
    "description" = {
      type = "localizable";
      field = "description";
    };

    "namespace" = {
      type = "single";
      field = "namespace";
    };
    "version" = {
      type = "single";
      field = "version";
    };
    "icon" = {
      type = "single";
      field = "icon";
    };
    "run-at" = {
      type = "single";
      field = "runAt";
    };
    "inject-into" = {
      type = "single";
      field = "injectInto";
    };
    "downloadURL" = {
      type = "single";
      field = "downloadURL";
    };
    "supportURL" = {
      type = "single";
      field = "supportURL";
    };
    "homepageURL" = {
      type = "single";
      field = "homepageURL";
    };

    "include" = {
      type = "list";
      field = "include";
    };
    "exclude" = {
      type = "list";
      field = "exclude";
    };
    "match" = {
      type = "list";
      field = "match";
    };
    "exclude-match" = {
      type = "list";
      field = "excludeMatch";
    };
    "require" = {
      type = "list";
      field = "require";
    };
    "grant" = {
      type = "list";
      field = "grant";
    };

    # Boolean flag metadata
    "noframes" = {
      type = "boolean";
      field = "noframes";
    };
    "unwrap" = {
      type = "boolean";
      field = "unwrap";
    };
    "top-level-await" = {
      type = "boolean";
      field = "topLevelAwait";
    };

    "resource" = {
      type = "dictionary";
      field = "resources";
    };
  };

  simpleSplit = sep: s: builtins.filter builtins.isString (builtins.split sep s);

  getBaseKey = key: builtins.head (simpleSplit ":" key);

  getSpec =
    key:
    let
      baseKey = getBaseKey key;
    in
    if metadataSpec ? ${key} then
      metadataSpec.${key}
    else if metadataSpec ? ${baseKey} then
      metadataSpec.${baseKey}
    else
      null;

  isValidKey =
    key:
    let
      spec = getSpec key;
    in
    spec != null;

  getFieldName =
    key:
    let
      spec = getSpec key;
    in
    if spec != null && spec.type == "localizable" then
      key
    else if spec != null then
      spec.field
    else
      key;

  getMetadataType =
    key:
    let
      spec = getSpec key;
    in
    if spec != null then spec.type else null;

  lines = simpleSplit "\n" scriptContent;

  findMetadataBlock =
    lines:
    let
      isStart =
        line: (builtins.match "[[:space:]]*//[[:space:]]*==UserScript==[[:space:]]*" line) != null;
      isEnd = line: (builtins.match "[[:space:]]*//[[:space:]]*==/UserScript==[[:space:]]*" line) != null;

      # Find start index
      findStart =
        idx:
        if idx >= builtins.length lines then
          null
        else if isStart (builtins.elemAt lines idx) then
          idx
        else
          findStart (idx + 1);

      # Find end index after start
      findEnd =
        idx:
        if idx >= builtins.length lines then
          null
        else if isEnd (builtins.elemAt lines idx) then
          idx
        else
          findEnd (idx + 1);

      startIdx = findStart 0;
      endIdx = if startIdx != null then findEnd (startIdx + 1) else null;
    in
    if startIdx != null && endIdx != null then { inherit startIdx endIdx; } else null;

  # Parse a metadata line (// @key value)
  # Boolean flags can have no value
  parseMetadataLine =
    line:
    let
      # Try to match with value first
      matchWithValue = builtins.match "[[:space:]]*//[[:space:]]*@([^[:space:]]+)[[:space:]]+(.*)" line;
      # Try to match without value (boolean flags)
      matchWithoutValue = builtins.match "[[:space:]]*//[[:space:]]*@([^[:space:]]+)[[:space:]]*" line;
    in
    if matchWithValue != null then
      {
        key = builtins.head matchWithValue;
        value = builtins.elemAt matchWithValue 1;
      }
    else if matchWithoutValue != null then
      let
        key = builtins.head matchWithoutValue;
        metadataType = getMetadataType key;
      in
      {
        inherit key;
        value = if metadataType == "boolean" then true else "";
      }
    else
      null;

  extractMetadata =
    block:
    let
      # Parse all lines
      parsed = map parseMetadataLine block;
      validEntries = builtins.filter (x: x != null) parsed;

      # Validate that all keys are known
      unknownKeys = builtins.filter (entry: !(isValidKey entry.key)) validEntries;
      validated =
        if builtins.length unknownKeys > 0 then
          throw "Unknown metadata keys found: ${builtins.concatStringsSep ", " (map (e: e.key) unknownKeys)}"
        else
          true;

      # Separate dictionary-type entries from regular entries
      dictionaryEntries = builtins.filter (e: (getMetadataType e.key) == "dictionary") validEntries;
      regularEntries = builtins.filter (e: (getMetadataType e.key) != "dictionary") validEntries;

      # Parse dictionary entries (e.g., @resource name url)
      parseDictionaryValue =
        value:
        let
          parts = builtins.match "([^[:space:]]+)[[:space:]]+(.*)" value;
        in
        if parts != null then
          {
            name = builtins.head parts;
            value = builtins.elemAt parts 1;
          }
        else
          throw "Invalid dictionary metadata format: ${value}";

      # Process dictionary entries by field name
      processDictionaries =
        entries:
        let
          # Group dictionary entries by their field name
          fieldNames = builtins.foldl' (
            acc: entry:
            let
              fieldName = getFieldName entry.key;
            in
            if builtins.elem fieldName acc then acc else acc ++ [ fieldName ]
          ) [ ] entries;

          buildDictAttr =
            fieldName:
            let
              # Get all entries for this field
              fieldEntries = builtins.filter (e: (getFieldName e.key) == fieldName) entries;
              # Parse each entry into name-value pairs
              parsed = map (e: parseDictionaryValue e.value) fieldEntries;
            in
            {
              name = fieldName;
              value = builtins.listToAttrs parsed;
            };
        in
        builtins.listToAttrs (map buildDictAttr fieldNames);

      # Group regular entries by key
      groupRegularEntries =
        entries:
        let
          # Get unique keys
          keys = builtins.foldl' (
            acc: entry: if builtins.elem entry.key acc then acc else acc ++ [ entry.key ]
          ) [ ] entries;

          # For each key, collect all values
          buildAttr =
            key:
            let
              values = map (e: e.value) (builtins.filter (e: e.key == key) entries);
              fieldName = getFieldName key;
              metadataType = getMetadataType key;
            in
            {
              name = fieldName;
              value =
                if metadataType == "list" then
                  values # Always use list for list-type metadata
                else if builtins.length values == 1 then
                  builtins.head values # Single value
                else
                  throw "Metadata key '${key}' should only appear once but appears ${toString (builtins.length values)} times";
            };
        in
        builtins.listToAttrs (map buildAttr keys);

      regularAttrs = groupRegularEntries regularEntries;
      dictionaryAttrs = processDictionaries dictionaryEntries;
    in
    # Force validation before returning results
    builtins.seq validated (regularAttrs // dictionaryAttrs);

  metadataBlock = findMetadataBlock lines;

  metadata =
    if metadataBlock != null then
      let
        blockLines =
          let
            start = metadataBlock.startIdx + 1;
            end = metadataBlock.endIdx;
            indices = builtins.genList (i: start + i) (end - start);
          in
          map (idx: builtins.elemAt lines idx) indices;
      in
      extractMetadata blockLines
    else
      { };
in
metadata
