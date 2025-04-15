{ stdenv, lib }:
stdenv.mkDerivation rec {
  name = "TA-p-4025w-${version}";
  version = "1.0";

  src = ./.;

  installPhase = ''
    mkdir -p $out/share/cups/model/
    mkdir -p $out/lib/cups/filter/

    # Copy the PPD file
    cp TA-p-4025w.ppd $out/share/cups/model/

    # Copy the filter binaries
    cp kyofilter_H $out/lib/cups/filter/
    cp kyofilter_kpsl_H $out/lib/cups/filter/
    cp kyofilter_pdf_H $out/lib/cups/filter/
    cp kyofilter_pre_H $out/lib/cups/filter/
    cp kyofilter_ras_H $out/lib/cups/filter/

    # Make the binaries executable
    chmod +x $out/lib/cups/filter/kyofilter_*

    # Patch the PPD file to use the correct paths
    substituteInPlace $out/share/cups/model/TA-p-4025w.ppd \
      --replace "/usr/lib/cups/filter/kyofilter_H" "$out/lib/cups/filter/kyofilter_H" \
      --replace "kyofilter_pre_H" "$out/lib/cups/filter/kyofilter_pre_H"
  '';
}


*cupsFilter: "application/vnd.cups-postscript 0 /usr/lib/cups/filter/kyofilter_H"
