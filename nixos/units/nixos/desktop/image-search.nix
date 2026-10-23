# units/desktop/image-search.nix — region screenshot -> reverse image search
#
# Engine: Yandex by default.
#
# It used to upload to Google Lens (lens.google.com/v3/upload) and open the
# returned vsrid URL. That silently broke: the endpoint binds the stored image
# to the uploading HTTP session, so the vsrid resolves to a zero-byte image for
# any other session. The CLI uploads with curl's cookies, the browser opens the
# URL with its own, and Lens renders an empty picture (HTTP 200,
# `lens.usercontent.google.com/image?vsrid=...` with `content-length: 0`) even
# though the screenshot itself is fine. Yandex's search-by-image upload keys the
# result by cbir_id instead of a session cookie, so it works from a plain CLI
# upload and needs no third-party image host.
{ pkgs, ... }:
let
  image-search = pkgs.writeShellApplication {
    name = "image-search";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      grim
      jq
      slurp
      libnotify
      xdg-utils
    ];
    text = ''
      engine="''${IMAGE_SEARCH_ENGINE:-yandex}"
      image="''${1:-}"

      if [ -z "$image" ]; then
        image="$(mktemp --suffix=.png)"
        trap 'rm -f "$image"' EXIT
        region="$(slurp)" || exit 0
        grim -g "$region" "$image" || exit 0
      fi

      # A zero-byte or unreadable capture would upload as an empty image and
      # come back as "no results" with no hint about why.
      if [ ! -s "$image" ]; then
        notify-send "Image search" "The screenshot came out empty" || true
        exit 1
      fi

      ua="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"

      case "$engine" in
        yandex)
          # Search-by-image upload: returns JSON whose first block carries the
          # cbir_id the results page is keyed on. Formatting/request blob is the
          # site's own; only the cbir_id is read out.
          response="$(curl -sS --max-time 60 -A "$ua" \
            -F "upfile=@''${image};type=image/png" \
            "https://yandex.com/images/search?rpt=imageview&format=json&request=%7B%22blocks%22%3A%5B%7B%22block%22%3A%22b-page_type_search-by-image__link%22%7D%5D%7D" \
            || true)"
          cbir_id="$(printf '%s' "$response" | jq -r '.blocks[0].params.cbirId // empty' 2>/dev/null || true)"
          if [ -z "$cbir_id" ]; then
            notify-send "Image search" "Could not upload the image to Yandex" || true
            exit 1
          fi
          url="https://yandex.com/images/search?rpt=imageview&cbir_id=$cbir_id"
          ;;
        google)
          # Kept for completeness, but see the note above: Google binds the
          # uploaded image to the uploading session, so the browser usually
          # opens a blank picture.
          url="$(curl -sS --max-time 30 -o /dev/null -w '%{redirect_url}' \
            -F "encoded_image=@''${image};type=image/png;filename=image.png" \
            "https://lens.google.com/v3/upload?hl=en" || true)"
          if [ -z "$url" ]; then
            notify-send "Image search" "Could not upload the image to Google Lens" || true
            exit 1
          fi
          ;;
        *)
          notify-send "Image search" "Unknown engine: $engine" || true
          exit 1
          ;;
      esac

      if [ "''${IMAGE_SEARCH_PRINT:-}" = 1 ]; then
        echo "$url"
      else
        xdg-open "$url" >/dev/null 2>&1 &
      fi
    '';
  };
in
{
  environment.systemPackages = [ image-search ];
}
