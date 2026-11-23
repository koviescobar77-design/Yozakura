"""Windows desktop macro. Install Pillow, pyautogui, pytesseract and Tesseract OCR.
Run with Python. Capture a button while it is enabled; its visible appearance
must still match before each click. Keep the Roblox window at the calibrated size.
"""
import ctypes
import os
import re
import time
import threading
import tkinter as tk
from tkinter import ttk
from collections import Counter
from urllib.request import Request, urlopen
import json

ctypes.windll.user32.SetProcessDPIAware()
import pyautogui as mouse
from PIL import ImageChops, ImageStat
import pytesseract

engine = os.path.join(os.environ.get("ProgramFiles", ""), "Tesseract-OCR", "tesseract.exe")
if os.path.isfile(engine):
    pytesseract.pytesseract.tesseract_cmd = engine

root = tk.Tk()
root.title("Yozakura · Tap Simulator Reborn")
status = tk.StringVar(value="Capture a visible button, then tick its action.")
actions = ("Tap", "Hatch", "Open area")
enabled = {name: tk.BooleanVar() for name in actions}
samples = {}
corners = {}
active = False
next_due = Counter()
candidate = None
seen_count = 0
reported = set()
next_scan = 0
hook = tk.StringVar()
rarities = tk.StringVar(value="Mythic, Secret")
feedback = []
feedback_lock = threading.Lock()

def game_window():
    hwnd = ctypes.windll.user32.GetForegroundWindow()
    title = ctypes.create_unicode_buffer(512)
    ctypes.windll.user32.GetWindowTextW(hwnd, title, len(title))
    return title.value.strip().lower() == "roblox"

def capture(name):
    global active
    active = False
    status.set("Switch to Roblox and hover over " + name + " within 4 seconds.")
    def finish():
        if not game_window():
            status.set("Capture cancelled. Roblox must be in front.")
            return
        x, y = mouse.position()
        if name in actions:
            box = (x - 36, y - 13, 72, 26)
            samples[name] = (x, y, box, mouse.screenshot(region=box).convert("RGB"))
        else:
            corners[name] = (x, y)
        status.set("Captured " + name)
    root.after(4000, finish)

def post(url, rarity):
    try:
        data = json.dumps({"content": "Hatch result: " + rarity,
                           "allowed_mentions": {"parse": []}}).encode()
        with urlopen(Request(url, data=data, headers={"Content-Type": "application/json",
                     "User-Agent": "YozakuraDesktop/1"}), timeout=5):
            pass
        message = "Rarity alert sent: " + rarity
    except Exception:
        message = "Webhook delivery failed. Check the URL and connection."
    with feedback_lock:
        feedback.append(message)

def scan():
    global candidate, seen_count
    (x, y), (right, bottom) = corners["Result top left"], corners["Result bottom right"]
    image = mouse.screenshot(region=(x, y, right-x, bottom-y))
    words = pytesseract.image_to_string(image, config="--psm 6", timeout=2).lower()
    matches = [r.strip() for r in rarities.get().split(",") if r.strip()
               and re.search(r"\b" + re.escape(r.strip().lower()) + r"\b", words)]
    value = matches[0] if len(matches) == 1 else None
    seen_count = seen_count + 1 if value == candidate else 1
    candidate = value
    if value and seen_count >= 2 and value not in reported:
        reported.add(value)
        threading.Thread(target=post, args=(hook.get().strip(), value), daemon=True).start()

def start():
    global active, candidate, seen_count
    missing = [n for n in actions if enabled[n].get() and n not in samples]
    if missing:
        status.set("Capture first: " + ", ".join(missing))
        return
    if hook.get().strip():
        if not re.fullmatch(r"https://discord\.com/api/webhooks/\d+/[\w-]+", hook.get().strip()):
            status.set("Enter a Discord webhook URL or leave it blank.")
            return
        if len(corners) != 2 or any(b <= a for a,b in zip(corners["Result top left"], corners["Result bottom right"])):
            status.set("Capture the result region from top left to bottom right.")
            return
        try:
            pytesseract.get_tesseract_version()
        except Exception:
            status.set("Install Tesseract OCR for alerts or clear the webhook.")
            return
    active = True
    reported.clear()
    candidate, seen_count = None, 0
    status.set("Running when Roblox is focused. Press F8 to stop.")

def tick():
    global active, next_scan, candidate, seen_count
    try:
        with feedback_lock:
            if feedback:
                status.set(feedback.pop(0))
        if active and ctypes.windll.user32.GetAsyncKeyState(0x77) & 0x8000:
            active = False
            status.set("Stopped.")
        if active and game_window():
            now = time.monotonic()
            if hook.get().strip() and now >= next_scan:
                scan()
                next_scan = time.monotonic() + .25
            for name, interval in (("Open area", 3), ("Hatch", 3), ("Tap", .4)):
                if not enabled[name].get() or now < next_due[name]:
                    continue
                x, y, box, sample = samples[name]
                current = mouse.screenshot(region=box).convert("RGB")
                diff = ImageStat.Stat(ImageChops.difference(sample, current)).mean
                if max(diff) <= 7 and game_window():
                    mouse.click(x, y)
                    next_due[name] = now + interval
                    if name == "Hatch":
                        reported.clear()
                        candidate, seen_count = None, 0
                    break
    except Exception as error:
        active = False
        status.set("Stopped: " + type(error).__name__)
    root.after(80, tick)

for i, name in enumerate(actions):
    ttk.Checkbutton(root, text=name, variable=enabled[name]).grid(row=i, column=0, sticky="w")
    ttk.Button(root, text="Capture enabled button", command=lambda n=name: capture(n)).grid(row=i, column=1)
for i, name in enumerate(("Result top left", "Result bottom right"), 3):
    ttk.Button(root, text="Capture " + name, command=lambda n=name: capture(n)).grid(row=i, columnspan=2)
for i, (label, var) in enumerate((("Alert rarities (comma separated)", rarities), ("Discord webhook (optional)", hook)), 5):
    ttk.Label(root, text=label).grid(row=i, column=0)
    ttk.Entry(root, textvariable=var, show="*" if var is hook else "").grid(row=i, column=1)
ttk.Button(root, text="Start", command=start).grid(row=7, columnspan=2)
ttk.Label(root, textvariable=status, wraplength=410).grid(row=8, columnspan=2, padx=8, pady=8)
root.after(80, tick)
root.mainloop()
