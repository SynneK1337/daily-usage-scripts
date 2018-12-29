# Simply boost views of your auction on allegro.pl
# Developed with <3 by SynneK1337

import requests

url = input("Podaj link do aukcji: ")
views = int(input("Ile wyświetleń dodać (0 = ∞): "))

if views > 0:
    for x in range(0, views):
        requests.get(url)

else:
    while 1:
        requests.get(url)