import Image
import os

image_name = "arrow_tip@3x.png"

im = Image.open(image_name)
im = im.rotate(180)

image_name = "arrow_tip_inverse@3x.png"

f, e = os.path.splitext(image_name)
outfilename = f[:-3] + "@3x" + ".png"
out = im
try:
    out.save(outfilename)
except IOError as e:
    print e

f, e = os.path.splitext(image_name)
outfilename = f[:-3] + "@2x" + ".png"
x, y = im.size
print(x*2/3, y*2/3)
out = im.resize((x*2/3, y*2/3), Image.ANTIALIAS)
try:
    out.save(outfilename)
except IOError as e:
    print e

outfilename = f[:-3] + ".png"
out = im.resize((x*1/3, y*1/3), Image.ANTIALIAS)
try:
    out.save(outfilename)
except IOError as e:
    print e