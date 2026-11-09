"""
download_images.py - saves every motionsites.ai preview GIF used in index.html into assets/work/

Run it ONCE from the same folder as index.html:
    python download_images.py
"""
import re, os, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "assets", "work")
os.makedirs(OUT, exist_ok=True)

html = open(os.path.join(HERE, "index.html"), encoding="utf-8").read()
# every full motionsites.ai GIF address in the page
urls = set(re.findall(r'https://motionsites\.ai/assets/[^"\']+?\.gif', html))
# the package samples only store the file name, so add those too
for name in re.findall(r'"(hero-[^"]+?\.gif)"', html):
    urls.add("https://motionsites.ai/assets/" + name)

ok, failed = 0, []
for url in sorted(urls):
    dest = os.path.join(OUT, url.split("/")[-1])
    if os.path.exists(dest):
        ok += 1
        continue
    # a browser-like User-Agent and Referer, because some hosts refuse plain scripts
    req = urllib.request.Request(url, headers={
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36",
        "Referer": "https://motionsites.ai/",
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as r, open(dest, "wb") as f:
            f.write(r.read())
        ok += 1
        print("saved ", url.split("/")[-1])
    except Exception as e:
        failed.append(url)
        print("FAILED", url, "->", e)

print(f"\nDone: {ok} saved, {len(failed)} failed")
if failed:
    print("Open the failed links in your browser, right-click > Save image as, and put them in assets/work/")
