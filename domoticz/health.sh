. ~/.config/telegram
url="http://localhost:26366/json.htm?type=command&param=getversion"
TIMEOUT=5

curl -m $TIMEOUT -sI $url  2>&1>/dev/null
error=$?
if [ $error -ne 0 ]; then
    curl "https://api.telegram.org/$TELEGRAM_API_BOT/sendMessage?chat_id=-709139270&text=Je%20crois%20que%20le%20serveur%20est%20cass%C3%A9%2C%20je%20ne%20vois%20plus%20rien..."
fi
