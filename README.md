# Voice Teleprompter

A teleprompter that listens to you read and scrolls the script to keep up.
No install, no account, no network — it is one HTML file.

## Run it

Double-click **start-teleprompter.bat**.

It serves the folder on `http://127.0.0.1:8777` and opens Chrome. Allow the
microphone when asked. Press any key in the black console window to stop.

> Open `teleprompter.html` directly if you like, but Chrome usually blocks the
> microphone on `file://` pages, so the voice tracking will not start. The `.bat`
> exists to get around exactly that.

What you need:

- **Chrome or Edge on desktop** — speech recognition is not in Firefox or Safari,
  and it does not work in embedded browsers (VS Code previews, Electron apps).
- **Python or Node** installed — either one; the `.bat` finds whichever you have
  and uses it to serve the folder. If it finds neither, it tells you.
- **Internet** while prompting — Chrome's speech recognition runs on Google's
  servers.

Not on Windows? Skip the `.bat`: run `python3 -m http.server 8777` in this
folder and open `http://127.0.0.1:8777/teleprompter.html` in Chrome.

## Using it

1. Paste your script into the box.
2. Set text size, and the reading line — the height on screen where the word you
   are about to say sits.
3. **Start reading.** Just read normally; the highlighted word tracks your voice.

Spoken words go grey, the next word is amber, the rest stay white.

| Key | Does |
| --- | --- |
| `Space` | pause / resume listening |
| `↑` `↓` | nudge the cursor a word |
| `PgUp` `PgDn` | nudge a dozen words |
| `+` `−` | text size |
| `M` | auto-scroll at a fixed speed (`[` `]` change wpm) |
| `R` | back to the top |
| `D` | diagnostics overlay - shows what the recogniser is hearing and any errors |
| `Esc` | back to the script editor |

Click any word to move the cursor straight to it — the quickest fix if you go
badly off-script.

Your script and settings are saved in the browser, so closing the tab loses nothing.

## If tracking drifts

- **Nothing happens at all** — check the dot in the bottom bar is green and says
  Listening. Red means Chrome blocked the mic; click the padlock in the address
  bar and allow it.
- **Pausing is fine** — the prompter holds still and shows "Waiting for your
  voice" until you carry on.
- **Ad-libbing is fine too** — off-script talk holds position. If you skip to a
  different part of the script, keep reading it: after a few words the prompter
  searches the whole text and re-syncs to where you are ("Re-synced" flashes in
  the pill). Clicking a word still jumps instantly if you prefer.
- **Wrong language** — set it in the dropdown before starting.
- **Nothing works** — press `M` for plain timed auto-scroll and drive it with `[` and `]`.

## How the tracking works

Two positions are tracked. The **voice position** is where the alignment says
you actually are: the last six recognised words are matched against a window of
the script (12 words behind, 70 ahead) with a weighted local sequence
alignment. Recent words count more; gaps on either side are allowed but cost
something, so dropped words, filler, and contractions like "wanna" for "want to"
do not throw it off. A match only moves the position if it clears a confidence
threshold — off-script talk and room noise leave it alone. Numerals match how
they are actually said, so `2019` matches "twenty nineteen".

The **highlight you see** walks toward the voice position one word at a time at
your measured reading speed (shown live as wpm in the status pill), rather than
leaping whenever recognition flushes a burst of words. It never runs ahead of
your voice, so a pause simply stops it; it trails by at most a few words and
closes big jumps quickly.

If you speak eight-plus words that match nothing near the cursor, the whole
script is searched with a stricter confidence bar. A strong hit re-syncs to
wherever you resumed; anything weaker — chatter, ad-libs — leaves the prompter
parked.

Measured on a full read-through of the sample script: the voice position stays
within one word throughout; the pace estimate converges on the true reading
speed for both fast and slow readers; the highlight never overtakes the voice;
and each alignment pass takes ~0.03 ms on a 3000-word script.

## Files

- `teleprompter.html` — the whole app
- `start-teleprompter.bat` — serves it on localhost and opens Chrome
- `server.js` — tiny static server, only used if Python is missing
