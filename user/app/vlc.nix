{ pkgs, ... }:

{
  # Set VLC as the default media player
  # Handles all video, audio, and streaming formats

  xdg.mimeApps.defaultApplications = {
    # Video formats
    "video/mp4" = "vlc.desktop";
    "video/x-matroska" = "vlc.desktop";
    "video/webm" = "vlc.desktop";
    "video/mpeg" = "vlc.desktop";
    "video/x-mpeg" = "vlc.desktop";
    "video/x-mpeg2" = "vlc.desktop";
    "video/x-msvideo" = "vlc.desktop";
    "video/avi" = "vlc.desktop";
    "video/x-avi" = "vlc.desktop";
    "video/quicktime" = "vlc.desktop";
    "video/x-ms-wmv" = "vlc.desktop";
    "video/x-ms-asf" = "vlc.desktop";
    "video/x-flv" = "vlc.desktop";
    "video/ogg" = "vlc.desktop";
    "video/x-ogm" = "vlc.desktop";
    "video/x-theora" = "vlc.desktop";
    "video/mp2t" = "vlc.desktop";
    "video/divx" = "vlc.desktop";
    "video/vnd.divx" = "vlc.desktop";
    "video/3gp" = "vlc.desktop";
    "video/3gpp" = "vlc.desktop";
    "video/3gpp2" = "vlc.desktop";
    "video/vnd.mpegurl" = "vlc.desktop";
    "video/dv" = "vlc.desktop";
    "video/x-nsv" = "vlc.desktop";
    "video/fli" = "vlc.desktop";
    "video/flv" = "vlc.desktop";
    "video/x-flc" = "vlc.desktop";
    "video/x-fli" = "vlc.desktop";
    "video/x-m4v" = "vlc.desktop";

    # Audio formats
    "audio/mpeg" = "vlc.desktop";
    "audio/mp3" = "vlc.desktop";
    "audio/x-mp3" = "vlc.desktop";
    "audio/x-mpeg" = "vlc.desktop";
    "audio/mp4" = "vlc.desktop";
    "audio/m4a" = "vlc.desktop";
    "audio/x-m4a" = "vlc.desktop";
    "audio/aac" = "vlc.desktop";
    "audio/x-aac" = "vlc.desktop";
    "audio/flac" = "vlc.desktop";
    "audio/x-flac" = "vlc.desktop";
    "audio/ogg" = "vlc.desktop";
    "audio/vorbis" = "vlc.desktop";
    "audio/x-vorbis" = "vlc.desktop";
    "audio/opus" = "vlc.desktop";
    "audio/webm" = "vlc.desktop";
    "audio/x-matroska" = "vlc.desktop";
    "audio/wav" = "vlc.desktop";
    "audio/x-wav" = "vlc.desktop";
    "audio/x-ms-wma" = "vlc.desktop";
    "audio/ac3" = "vlc.desktop";
    "audio/eac3" = "vlc.desktop";
    "audio/vnd.dts" = "vlc.desktop";
    "audio/vnd.dts.hd" = "vlc.desktop";
    "audio/x-speex" = "vlc.desktop";
    "audio/3gpp" = "vlc.desktop";
    "audio/3gpp2" = "vlc.desktop";
    "audio/AMR" = "vlc.desktop";
    "audio/AMR-WB" = "vlc.desktop";
    "audio/mpegurl" = "vlc.desktop";
    "audio/x-mpegurl" = "vlc.desktop";
    "audio/scpls" = "vlc.desktop";
    "audio/x-scpls" = "vlc.desktop";
    "audio/x-pn-realaudio" = "vlc.desktop";
    "audio/x-realaudio" = "vlc.desktop";
    "audio/vnd.rn-realaudio" = "vlc.desktop";
    "audio/x-aiff" = "vlc.desktop";
    "audio/x-pn-wav" = "vlc.desktop";
    "audio/x-adpcm" = "vlc.desktop";
    "audio/midi" = "vlc.desktop";
    "audio/basic" = "vlc.desktop";
    "audio/x-ape" = "vlc.desktop";
    "audio/x-gsm" = "vlc.desktop";
    "audio/x-musepack" = "vlc.desktop";
    "audio/x-tta" = "vlc.desktop";
    "audio/x-wavpack" = "vlc.desktop";
    "audio/x-it" = "vlc.desktop";
    "audio/x-mod" = "vlc.desktop";
    "audio/x-s3m" = "vlc.desktop";
    "audio/x-xm" = "vlc.desktop";

    # Streaming protocols
    "x-scheme-handler/mms" = "vlc.desktop";
    "x-scheme-handler/mmsh" = "vlc.desktop";
    "x-scheme-handler/rtsp" = "vlc.desktop";
    "x-scheme-handler/rtp" = "vlc.desktop";
    "x-scheme-handler/rtmp" = "vlc.desktop";
    "x-scheme-handler/icy" = "vlc.desktop";
    "x-scheme-handler/icyx" = "vlc.desktop";

    # Application types
    "application/ogg" = "vlc.desktop";
    "application/x-ogg" = "vlc.desktop";
    "application/x-flac" = "vlc.desktop";
    "application/mpeg4-iod" = "vlc.desktop";
    "application/mpeg4-muxcodetable" = "vlc.desktop";
    "application/x-extension-m4a" = "vlc.desktop";
    "application/x-extension-mp4" = "vlc.desktop";
    "application/x-matroska" = "vlc.desktop";
    "application/vnd.rn-realmedia" = "vlc.desktop";
    "application/vnd.rn-realmedia-vbr" = "vlc.desktop";
    "application/x-quicktime-media-link" = "vlc.desktop";
    "application/x-quicktimeplayer" = "vlc.desktop";
    "application/ram" = "vlc.desktop";
    "application/xspf+xml" = "vlc.desktop";
    "application/vnd.apple.mpegurl" = "vlc.desktop";
    "application/vnd.ms-asf" = "vlc.desktop";
    "application/vnd.ms-wpl" = "vlc.desktop";
    "application/sdp" = "vlc.desktop";
    "application/x-shockwave-flash" = "vlc.desktop";
    "application/x-flash-video" = "vlc.desktop";
    "application/mxf" = "vlc.desktop";

    # Optical media content types
    "x-content/video-vcd" = "vlc.desktop";
    "x-content/video-svcd" = "vlc.desktop";
    "x-content/video-dvd" = "vlc.desktop";
    "x-content/audio-cdda" = "vlc.desktop";
    "x-content/audio-player" = "vlc.desktop";
  };
}
