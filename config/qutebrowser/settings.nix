{
  auto_save.session = true;
  new_instance_open_target = "window";
  tabs.background = true;
  downloads.position = "bottom";
  # spellcheck.languages = ["en-US" "ru-RU"];
  fonts.web.family.fantasy = "FantsqueSansM Nerd Font";

  # HiDPI
  qt.highdpi = true;

  # Minimize fingerprinting
  content = {
    headers = {
      user_agent =
        "Mozilla/5.0 (X11; Linux x86_64 10.0; rv:68.0) Gecko/20100101 Firefox/68.0";
      accept_language = "en-US,en;q=0.5";
    };

    blocking = {
      enabled = true;
      method = "both";
      adblock.lists = [
        "https://easylist.to/easylist/easylist.txt"
        "https://easylist.to/easylist/easyprivacy.txt"
        "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt"
        "https://easylist.to/easylist/fanboy-annoyance.txt"
        "https://secure.fanboy.co.nz/fanboy-annoyance.txt"
        "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances.txt"
        "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2020.txt"
        "https://github.com/uBlockOrigin/uAssets/raw/master/filters/unbreak.txt"
        "https://github.com/uBlockOrigin/uAssets/raw/master/filters/resource-abuse.txt"
        "https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt"
        "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters.txt"
      ];
    };
    canvas_reading = false;
    pdfjs = true;
  };
}
