from flask import Flask, request, jsonify
from PIL import Image
import numpy as np
from model import ImageClassifier

app = Flask(__name__)


classifier = ImageClassifier()

class_names = ['Chaussures','Pantalon', 'Veste','T-shirt']

@app.route('/classify', methods=['POST'])
def classify_image():
    if 'file' not in request.files:
        return jsonify({'error': 'Aucun fichier trouvé'}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({'error': 'Aucun fichier sélectionné'}), 400

    try:

        img = Image.open(file.stream).convert('RGB')  

        img = img.resize((224, 224)) 
        
        img_array = np.array(img).astype(np.float32) / 255.0

        if img_array.shape[-1] == 1:
            img_array = np.repeat(img_array, 3, axis=-1) 

        img_array = np.expand_dims(img_array, axis=0) 

        class_idx = classifier.classify(img_array)

    
        class_idx = int(class_idx)

        return jsonify({'class_id': class_idx, 'class_name': class_names[class_idx]})

    except Exception as e:
        return jsonify({'error': str(e)}), 500 

if __name__ == '__main__':
    app.run(debug=True)
