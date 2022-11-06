{
  config,
  lib,
...}: 
with lib; let
  cfg = config.nixchad.mpv;
in {
  options.nixchad.mpv = {
    enable = mkEnableOption "mpv";
  };

  config = mkIf cfg.enable {
    hm = {
      programs.mpv = {
        enable = true;
        config = {
          profile = "gpu-hq";
          sub-auto = "fuzzy";
          sub-bold = "yes";
          hwdec = "auto-safe";

          #keep-open = "yes";
          #audio-display = "no";
          #term-osd-bar = "yes";
          #term-osd-bar-chars = "[=|-]";
          #screenshot-template = "screenshot_%#02n";
          #cache-secs = "300";
          #cache-pause-initial = "yes";
          #cache-pause-wait = "15";
          #autofit-smaller = "854x480";
          #autofit-larger = "95%x95%";
          #msg-level = "ffmpeg=fatal";
          #script-opts = "ytdl_hook-ytdl_path=yt-dlp,osc-timetotal=yes";
          #ytdl-format = "[height<=?720][fps<=?30]";
          #term-title = "\${?metadata/by-key/artist:\${metadata/by-key/artist} -}\${media-title} - MPV";

          ##[graph0]
          #lavfi-complex = "[vid1]copy[vo];[aid1]acopy[ao]";
          ##[showvolume]
          #lavfi-complex = "[aid1]asplit[ao],showvolume,[vid1]overlay='(W-w)/2'[vo]";
          ##[showfreqs]
          #lavfi-complex = "[aid1]asplit[ao],showfreqs=240x180:cmode=separate,[vid1]overlay[vo]";
          ##[showwaves]
          #lavfi-complex = "[aid1]asplit[ao],showwaves=240x180:split_channels=1:mode=cline,[vid1]overlay[vo]";
          ##input.conf
          ##= apply-profile showvolume
          ##+ apply-profile showfreqs
          ##~ apply-profile showwaves
          ##_ apply-profile graph0
          ##[msg1]
          #term-status-msg = "\${?pause==no:\\e[7m}\${time-pos}\\e[0m \${video-bitrate:} \${audio-bitrate:}";
          ##[msg2]
          #term-status-msg = "\${?pause==no:\\e[7m}\${time-pos}\\e[0m \${video-frame-info/picture-type:} x\${speed}";
          ##[default]
          #profile = "msg1";
          ##input.conf
          ##\ apply-profile msg2
          ##| apply-profile msg1
          ##; no-osd seek -0.04 keyframes
          ##' no-osd seek +0.04 keyframes
          ##HOME seek 0 absolute-percent
          ##END seek 100 absolute-percent exact
          ##- script-message osc-visibility cycle
          ##D ab-loop-align-cache; ab-loop-dump-cache "cache_dump.mkv"
        };
      };
    };
  };
}
