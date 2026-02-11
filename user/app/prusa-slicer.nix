{ pkgs, ... }:

{
  # Set PrusaSlicer as the default application for 3D model files
  # Handles STL, 3MF, OBJ, and AMF formats

  xdg.mimeApps.defaultApplications = {
    # STL formats (various MIME types used by different systems/browsers)
    "model/stl" = "PrusaSlicer.desktop";
    "model/x.stl-ascii" = "PrusaSlicer.desktop";
    "model/x.stl-binary" = "PrusaSlicer.desktop";
    "application/sla" = "PrusaSlicer.desktop";
    "application/vnd.ms-pki.stl" = "PrusaSlicer.desktop";

    # 3MF format
    "application/vnd.ms-3mfdocument" = "PrusaSlicer.desktop";
    "model/3mf" = "PrusaSlicer.desktop";

    # OBJ format
    "application/prs.wavefront-obj" = "PrusaSlicer.desktop";
    "model/obj" = "PrusaSlicer.desktop";
    "text/prs.wavefront-obj" = "PrusaSlicer.desktop";

    # AMF format
    "application/x-amf" = "PrusaSlicer.desktop";
  };

  # Explicitly associate file extensions with PrusaSlicer
  # This helps when MIME detection fails or returns generic types
  xdg.mimeApps.associations.added = {
    "model/stl" = "PrusaSlicer.desktop";
    "application/vnd.ms-3mfdocument" = "PrusaSlicer.desktop";
    "application/prs.wavefront-obj" = "PrusaSlicer.desktop";
  };
}
