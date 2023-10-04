from requests_html import HTMLSession
from pprint import pprint

session = HTMLSession()
r = session.get("https://www.leboncoin.fr/recherche?category=9&text=jardin%20-rue&locations=Lille__50.6324301076244_3.06379545019679_8344_50000&price=123-200000&square=22-98765&rooms=5-5&land_plot_surface=22-876543")
r.html.render()
pprint(r.html.html)
iframe = r.html.find("iframe")[0]
pprint(iframe.attrs['src'])




