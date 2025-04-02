from fastapi import APIRouter, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import io
from PIL import Image
import tensorflow as tf
import numpy as np
import os

print(tf.__version__)

router = APIRouter()

current_dir = os.path.dirname(__file__)       
model_path = os.path.join(current_dir, "model.h5")
model = tf.keras.models.load_model(model_path)

class_indices = {
    0: "Blight",
    1: "Common Rust",
    2: "gray Leaf Spot",
    4: "Healthy"
}

def preprocess_image(image: Image.Image, target_size=(260, 260)):
    # Resize the image to the target size (should match the training input size)
    image = image.resize(target_size)
    image_array = np.array(image)
    
    # If the image has an alpha channel, remove it
    if image_array.shape[-1] == 4:
        image_array = image_array[..., :3]
    image_array = image_array / 255.0
    image_array = np.expand_dims(image_array, axis=0)
    return image_array


def predict_disease(image: Image.Image) -> str:
    # Preprocess the image for prediction
    processed_image = preprocess_image(image)
    
    # Get predictions from the model
    preds = model.predict(processed_image)
    
    # Get the index of the highest predicted probability
    pred_index = np.argmax(preds, axis=1)[0]
    
    # Map the index to the corresponding disease name
    disease_name = class_indices.get(pred_index, "Unknown")
    return disease_name


@router.post("/")
async def predict(file: UploadFile = File(...)):
    try:
        # Read the uploaded file and open it as an image
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        
        # Run the prediction
        prediction = predict_disease(image)
        return JSONResponse(content={"prediction": prediction})
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
