import base64

image = open('testimg.jpg', 'rb')

ir = image.read()
encoding = base64.b64encode(ir)
print(encoding)
