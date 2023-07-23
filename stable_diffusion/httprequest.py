# app.py
from flask import Flask, jsonify
import base64
from generator import make_image

app = Flask(__name__)

def read_image_as_bytes():
    make_image()
    # Replace 'path/to/your/image.png' with the actual path to your .png file
    with open('displayed_image.png', 'rb') as image_file:
        return image_file.read()

@app.route('/generate_image', methods=['GET'])
def generate_image():
    image_data = read_image_as_bytes()
    image_base64 = base64.b64encode(image_data).decode('utf-8')
    return jsonify({'image': image_base64}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)