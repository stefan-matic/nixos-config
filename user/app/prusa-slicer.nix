{ pkgs, ... }:

{
  # Set PrusaSlicer as the default application for 3D model files
  # Handles STL, 3MF, OBJ, and AMF formats

  xdg.mimeApps.defaultApplications = {
    # 3D model formats
    "model/stl" = "PrusaSlicer.desktop";
    "application/vnd.ms-3mfdocument" = "PrusaSlicer.desktop";
    "application/prs.wavefront-obj" = "PrusaSlicer.desktop";
    "application/x-amf" = "PrusaSlicer.desktop";

    # Additional common 3D formats (not in desktop file but commonly associated)
    "model/x.stl-ascii" = "PrusaSlicer.desktop";
    "model/x.stl-binary" = "PrusaSlicer.desktop";
  };
}
