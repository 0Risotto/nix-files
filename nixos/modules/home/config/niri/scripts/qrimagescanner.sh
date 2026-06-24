grim -g "$(slurp)" /tmp/qr.png

qr_data=$(zbarimg --quiet --raw /tmp/qr.png)

if [ -n "$qr_data" ]; then
    echo "QR Code detected: $qr_data"
    xdg-open "$qr_data"
else
    echo "No QR code found."
fi

rm /tmp/qr.png
