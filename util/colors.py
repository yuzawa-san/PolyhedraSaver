import json
from hsluv import hsluv_to_rgb

# run from root of project:
# pip3 install -r util/requirements.txt
# python3 util/colors.py

out = []
for x in range(0,360):
    (r,g,b) = hsluv_to_rgb([x, 100, 50])
    r = int(abs(r) * 255)
    g = int(abs(g) * 255)
    b = int(abs(b) * 255)
    out.append(f"{r:02x}{g:02x}{b:02x}")

with open('Polyhedra/colors.json', 'w') as f:
    json.dump(out, f)