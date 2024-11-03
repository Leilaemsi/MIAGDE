import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import numpy as np

# Load the Fashion MNIST dataset
fashion_mnist = keras.datasets.fashion_mnist
(train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()

# Normalize and resize the images
train_images = np.expand_dims(train_images, -1)  # Add channel dimension
test_images = np.expand_dims(test_images, -1)    # Add channel dimension
train_images = np.repeat(train_images, 3, axis=-1)  # Convert to 3 channels
test_images = np.repeat(test_images, 3, axis=-1)    # Convert to 3 channels

# Resize images to (96, 96)
train_images = tf.image.resize(train_images, [96, 96]) / 255.0
test_images = tf.image.resize(test_images, [96, 96]) / 255.0

# Convert labels to categorical
train_labels = keras.utils.to_categorical(train_labels, 10)
test_labels = keras.utils.to_categorical(test_labels, 10)

# Load the MobileNetV2 model, excluding the top layer
base_model = keras.applications.MobileNetV2(input_shape=(96, 96, 3), include_top=False, weights='imagenet')
base_model.trainable = False  # Freeze the base model

# Create the model
model = keras.Sequential([
    base_model,
    layers.GlobalAveragePooling2D(),
    layers.Dense(10, activation='softmax')  # 10 classes for Fashion MNIST
])

# Compile the model
model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              metrics=['accuracy'])

# Train the model
model.fit(train_images, train_labels, epochs=10, validation_data=(test_images, test_labels))

# Save the model
model.save('fashion_mobilenetv2.h5')
