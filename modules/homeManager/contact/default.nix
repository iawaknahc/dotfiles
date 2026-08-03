{
  pkgs,
  ...
}:
{
  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        # Manipulate vCard
        vobject
        # Parse phone number found in vCard
        phonenumbers
        # Parse country found in vCard
        pyicu
      ]
    )
  ];

  home.packages = [
    (pkgs.writeScriptBin "contact.py" (builtins.readFile ./contact.py))
  ];
}
