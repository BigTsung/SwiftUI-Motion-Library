#!/usr/bin/env python3
"""Rounds the corners of GIFs in place by making them transparent.

GitHub strips CSS from READMEs, so the rounded cards in the effect grid have to
be in the images themselves. Transparent corners show the page behind them, so
the cards look right on both the light and the dark theme.

    Scripts/round-gif-corners.py Docs/gifs/*.gif
    Scripts/round-gif-corners.py --radius 24 some.gif

The radius defaults to 5 % of the width (12 pt at the README's 240 pt). GIFs
whose corners are already clear are left alone, so running it twice is
harmless. Needs Pillow and NumPy (pip3 install pillow numpy).

ffmpeg can't do this well: a real transparent colour turns off its
"only store what changed" optimisation and the files grow ten times. Pillow
crops every frame to the area that changed, so the sizes stay about the same.
"""
import os
import sys

try:
    import numpy as np
    from PIL import GifImagePlugin, Image, ImageDraw, ImageSequence
except ImportError:
    sys.exit("round-gif-corners: needs Pillow and NumPy (pip3 install pillow numpy)")


def corners_clear(im):
    first = im.convert("RGBA")
    return first.getpixel((0, 0))[3] == 0 and first.getpixel((im.width - 1, im.height - 1))[3] == 0


def write_frame(fp, image, offset, duration):
    for chunk in GifImagePlugin.getdata(image, offset=offset, duration=duration, disposal=1, transparency=255):
        fp.write(chunk)


def round_gif(path, radius=None):
    im = Image.open(path)
    if corners_clear(im):
        return "already rounded"
    w, h = im.size
    r = radius or w // 20
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w - 1, h - 1), radius=r, fill=255)
    clear = Image.eval(mask, lambda v: 0 if v >= 128 else 255)

    frames, durations = [], []
    for frame in ImageSequence.Iterator(im):
        durations.append(frame.info.get("duration", 40))
        frames.append(frame.convert("RGB"))

    # One palette for every frame, plus a transparent slot (255). The
    # recorders encode each GIF with a single palette of at most 192 colours,
    # so the exact colours fit and nothing changes; anything else is quantised.
    colours = set()
    for frame in frames:
        found = frame.getcolors(maxcolors=256)
        if found is None:
            colours = None
            break
        colours.update(c for _, c in found)
        if len(colours) > 255:
            colours = None
            break
    exact = colours is not None
    if colours is None:
        strip = Image.new("RGB", (w, h * len(frames)))
        for i, frame in enumerate(frames):
            strip.paste(frame, (0, h * i))
        colours = strip.quantize(colors=255, method=Image.Quantize.MEDIANCUT).convert("RGB").getcolors(maxcolors=256)
        colours = {c for _, c in colours}
    ordered = sorted(colours)
    # Pad with copies of the first colour so no pixel snaps to a spare slot,
    # and give the transparent slot a colour no pixel is near.
    palette = [v for c in ordered for v in c] + list(ordered[0]) * (255 - len(ordered)) + [255, 0, 255]

    # Map every pixel to its exact palette entry. (Image.quantize(palette=)
    # rounds colours to 5 bits a channel, which shifts the stage grey.)
    keys = np.array([(r << 16) | (g << 8) | b for r, g, b in ordered], dtype=np.uint32)
    if exact:
        lookup = lambda px: np.searchsorted(keys, px)
    else:
        rgb = np.array(ordered, dtype=np.int32)
        lookup = lambda px: np.argmin(
            ((np.stack([px >> 16, (px >> 8) & 255, px & 255], -1).astype(np.int32)[..., None, :] - rgb) ** 2).sum(-1), -1)
    transparent = np.array(clear) > 0
    quantized = []
    for frame in frames:
        a = np.asarray(frame, dtype=np.uint32)
        px = (a[..., 0] << 16) | (a[..., 1] << 8) | a[..., 2]
        index = lookup(px).astype(np.uint8)
        index[transparent] = 255
        p = Image.frombytes("P", (w, h), index.tobytes())
        p.putpalette(palette)
        quantized.append(p)

    # Frames are drawn over the previous one (disposal 1), so each frame after
    # the first only stores the rectangle that changed, and the pixels in it
    # that didn't change are transparent. (Pillow's own GIF writer can't do
    # both, and the files would grow several times.)
    tmp = path + ".rounding"
    with open(tmp, "wb") as fp:
        for chunk in GifImagePlugin.getheader(quantized[0], palette=bytes(palette), info={"loop": 0})[0]:
            fp.write(chunk)
        previous = None
        pending = None  # (image, offset, duration) waiting for its final duration
        for current, duration in zip(quantized, durations):
            index = np.asarray(current)
            if previous is None:
                pending = [current, (0, 0), duration]
            else:
                changed = index != previous
                if not changed.any():
                    pending[2] += duration
                    continue
                ys, xs = np.nonzero(changed)
                x0, y0, x1, y1 = xs.min(), ys.min(), xs.max() + 1, ys.max() + 1
                patch = np.where(changed, index, 255)[y0:y1, x0:x1].astype(np.uint8)
                write_frame(fp, *pending)
                image = Image.frombytes("P", (x1 - x0, y1 - y0), patch.tobytes())
                image.putpalette(palette)
                pending = [image, (int(x0), int(y0)), duration]
            previous = index
        write_frame(fp, *pending)
        fp.write(b";")
    os.replace(tmp, path)
    return f"r={r}"


if __name__ == "__main__":
    args = sys.argv[1:]
    radius = None
    if args[:1] == ["--radius"]:
        radius = int(args[1])
        args = args[2:]
    for path in args:
        print(f"  {path}: {round_gif(path, radius)}")
