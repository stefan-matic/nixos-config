{ stdenv, patchelf, glibc, zlib, file, cups, ghostscript }:
stdenv.mkDerivation rec {
  name = "TA-p-4025w-${version}";
  version = "1.0";

  src = ./.;

  nativeBuildInputs = [ patchelf file ];
  buildInputs = [ cups ghostscript ];

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

    # Debug: Print file types
    echo "Checking file types:"
    for filter in $out/lib/cups/filter/kyofilter_*; do
      echo "$filter:"
      file "$filter"
    done

    # Process each filter
    for filter in $out/lib/cups/filter/kyofilter_*; do
      # First check if it's an ELF file
      if file "$filter" | grep -q "ELF"; then
        echo "Patching ELF file: $filter"
        patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 $filter
        patchelf --set-rpath ${glibc}/lib:${zlib}/lib:${cups}/lib $filter
        mv $filter $filter.real
      else
        echo "Creating wrapper for non-ELF file: $filter"
        mv $filter $filter.real
      fi

      # Create wrapper script
      cat > $filter <<EOF
#!/bin/sh
export LD_LIBRARY_PATH=${glibc}/lib:${zlib}/lib:${cups}/lib
export PATH=${ghostscript}/bin:\$PATH
echo "Running filter: $filter.real" >&2
echo "LD_LIBRARY_PATH=\$LD_LIBRARY_PATH" >&2
echo "PATH=\$PATH" >&2
if [ -x "$filter.real" ]; then
  exec "$filter.real" "\$@"
else
  echo "Error: $filter.real is not executable" >&2
  exit 1
fi
EOF
      chmod +x $filter
    done

    # Patch the PPD file to use the correct paths in the Nix store
    substituteInPlace $out/share/cups/model/TA-p-4025w.ppd \
      --replace "kyofilter_H" "$out/lib/cups/filter/kyofilter_H" \
      --replace "kyofilter_pre_H" "$out/lib/cups/filter/kyofilter_pre_H" \
      --replace "kyofilter_kpsl_H" "$out/lib/cups/filter/kyofilter_kpsl_H" \
      --replace "kyofilter_pdf_H" "$out/lib/cups/filter/kyofilter_pdf_H" \
      --replace "kyofilter_ras_H" "$out/lib/cups/filter/kyofilter_ras_H"

    # Debug: Show final PPD file
    echo "Final PPD file:"
    cat $out/share/cups/model/TA-p-4025w.ppd
  '';
}
