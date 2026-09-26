# units/desktop/image-search.nix — region screenshot -> Google Lens reverse image search
{ pkgs, ... }:
let
  image-search = pkgs.writeShellApplication {
    name = "image-search";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      grim
      slurp
      libnotify
      xdg-utils
    ];
    text = ''
      image="''${1:-}"
      if [ -z "$image" ]; then
        image="$(mktemp --suffix=.png)"
        trap 'rm -f "$image"' EXIT
        region="$(slurp)" || exit 0
        grim -g "$region" "$image" || exit 0
      fi

      url="$(curl -sS --max-time 30 -o /dev/null -w '%{redirect_url}' \
        -F "encoded_image=@''${image}" "https://lens.google.com/v3/upload?hl=en" || true)"

      if [ -z "$url" ]; then
        notify-send "Image search" "Could not upload the image to Google Lens" || true
        exit 1
      fi

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
