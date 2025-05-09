from fastapi import APIRouter, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import io
from PIL import Image
import tensorflow as tf
import numpy as np
import os
import requests

print(tf.__version__)

router = APIRouter()

# Constants
MODEL_URL = "https://github.com/SaviNimz/Agro-Scan/releases/download/v1/model.h5"
MODEL_FILE = "model.h5"
MODEL_PATH = os.path.join(os.path.dirname(__file__), MODEL_FILE)

# Download the model file if not already present
def download_model_if_needed():
    if not os.path.exists(MODEL_PATH):
        print("Downloading model...")
        response = requests.get(MODEL_URL)
        if response.status_code == 200:
            with open(MODEL_PATH, "wb") as f:
                f.write(response.content)
            print("Model downloaded successfully.")
        else:
            raise RuntimeError(f"Failed to download model: {response.status_code}")

# Ensure model is available
download_model_if_needed()

# Load model
model = tf.keras.models.load_model(MODEL_PATH)

# Class labels
class_indices = {
    0: "Blight",
    1: "Common Rust",
    2: "gray Leaf Spot",
    4: "Healthy"
}

# Preprocessing logic
def preprocess_image(image: Image.Image, target_size=(260, 260)):
    image = image.resize(target_size)
    image_array = np.array(image)
    if image_array.shape[-1] == 4:  # Remove alpha if present
        image_array = image_array[..., :3]
    image_array = image_array / 255.0
    image_array = np.expand_dims(image_array, axis=0)
    return image_array

# Prediction logic
def predict_disease(image: Image.Image) -> str:
    processed_image = preprocess_image(image)
    preds = model.predict(processed_image)
    pred_index = np.argmax(preds, axis=1)[0]
    return class_indices.get(pred_index, "Unknown")

# API endpoint
@router.post("/")
async def predict(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        prediction = predict_disease(image)
        return JSONResponse(content={"prediction": prediction})
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
