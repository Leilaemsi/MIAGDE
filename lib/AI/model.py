import tensorflow as tf
import numpy as np

class ImageClassifier:
    def __init__(self):
        # Load the pre-trained Fashion MNIST model
        self.model = tf.keras.models.load_model('keras_model.h5')
    
    def classify(self, img):
        # Predict the class of the image
        predictions = self.model.predict(img)
        class_idx = np.argmax(predictions)

        return class_idx
