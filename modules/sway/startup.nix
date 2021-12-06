{ pkgs, ... }:

let
  gsettings = "${pkgs.glib}/bin/gsettings";
  gnomeSchema = "org.gnome.desktop.interface";
  importGsettings = pkgs.writeShellScript "import_gsettings.sh" ''
    config="/home/user/.config/gtk-3.0/settings.ini"
    if [ ! -f "$config" ]; then exit 1; fi
    gtk_theme="$(grep 'gtk-theme-name' "$config" | sed 's/.*\s*=\s*//')"
    icon_theme="$(grep 'gtk-icon-theme-name' "$config" | sed 's/.*\s*=\s*//')"
    cursor_theme="$(grep 'gtk-cursor-theme-name' "$config" | sed 's/.*\s*=\s*//')"
    font_name="$(grep 'gtk-font-name' "$config" | sed 's/.*\s*=\s*//')"
    ${gsettings} set ${gnomeSchema} gtk-theme "$gtk_theme"
    ${gsettings} set ${gnomeSchema} icon-theme "$icon_theme"
    ${gsettings} set ${gnomeSchema} cursor-theme "$cursor_theme"
    ${gsettings} set ${gnomeSchema} font-name "$font_name"
  '';
in
[
  { command = "${importGsettings}"; }
  { command = "keepassxc"; }
  { command = "chromium"; }
  { command = "telegram-desktop"; }
  { command = "alacritty"; }
  { command = "freetube"; }
]
