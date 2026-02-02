{ ... }:

{
  # Set Okular as the default PDF and document viewer
  # Handles PDFs, ebooks, and other document formats

  xdg.mimeApps.defaultApplications = {
    # PDF
    "application/pdf" = "org.kde.okular.desktop";
    "application/x-pdf" = "org.kde.okular.desktop";

    # eBooks
    "application/epub+zip" = "okularApplication_epub.desktop";
    "application/x-mobipocket-ebook" = "okularApplication_mobi.desktop";
    "application/x-fictionbook+xml" = "okularApplication_fb.desktop";

    # DjVu (scanned documents)
    "image/vnd.djvu" = "okularApplication_djvu.desktop";
    "image/x-djvu" = "okularApplication_djvu.desktop";

    # PostScript
    "application/postscript" = "okularApplication_ghostview.desktop";

    # XPS (Microsoft document format)
    "application/oxps" = "okularApplication_xps.desktop";
    "application/vnd.ms-xpsdocument" = "okularApplication_xps.desktop";

    # Comic book archives
    "application/x-cbr" = "okularApplication_comicbook.desktop";
    "application/x-cbz" = "okularApplication_comicbook.desktop";
    "application/x-cb7" = "okularApplication_comicbook.desktop";
    "application/x-cbt" = "okularApplication_comicbook.desktop";
  };
}
