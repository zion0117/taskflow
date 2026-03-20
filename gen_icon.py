from PIL import Image, ImageDraw
import math

SIZE = 1024

def make_icon(size=SIZE):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    s = size

    # Background: soft indigo → muted blue-purple gradient
    bg = Image.new("RGBA", (s, s))
    bd = ImageDraw.Draw(bg)
    for y in range(s):
        t = y / s
        r = int(72  + (95  - 72)  * t)
        g = int(85  + (75  - 85)  * t)
        b = int(160 + (145 - 160) * t)
        bd.line([(0, y), (s, y)], fill=(r, g, b, 255))
    img.paste(bg, (0, 0))

    # Draw 3 flowing bezier-like curves using polylines
    draw = ImageDraw.Draw(img, "RGBA")

    def bezier_points(p0, p1, p2, p3, steps=300):
        pts = []
        for i in range(steps + 1):
            t = i / steps
            x = (1-t)**3*p0[0] + 3*(1-t)**2*t*p1[0] + 3*(1-t)*t**2*p2[0] + t**3*p3[0]
            y = (1-t)**3*p0[1] + 3*(1-t)**2*t*p1[1] + 3*(1-t)*t**2*p2[1] + t**3*p3[1]
            pts.append((x, y))
        return pts

    # Curve 1 — wide S-curve, top
    c1 = bezier_points(
        (s*0.05, s*0.30),
        (s*0.35, s*0.05),
        (s*0.65, s*0.55),
        (s*0.95, s*0.30),
    )
    draw.line(c1, fill=(255, 255, 255, 200), width=int(s*0.055))

    # Curve 2 — mid S-curve
    c2 = bezier_points(
        (s*0.05, s*0.52),
        (s*0.30, s*0.30),
        (s*0.70, s*0.74),
        (s*0.95, s*0.52),
    )
    draw.line(c2, fill=(255, 255, 255, 130), width=int(s*0.04))

    # Curve 3 — bottom faint curve
    c3 = bezier_points(
        (s*0.05, s*0.72),
        (s*0.40, s*0.58),
        (s*0.60, s*0.86),
        (s*0.95, s*0.72),
    )
    draw.line(c3, fill=(255, 255, 255, 70), width=int(s*0.028))

    return img

icon = make_icon(1024)
out = "/Users/a1/Library/Mobile Documents/com~apple~CloudDocs/TaskFlow/TaskFlow/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
icon.save(out, "PNG")
print("saved:", out)
