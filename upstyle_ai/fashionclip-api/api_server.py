from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
import uuid
import io
import os
from PIL import Image
import logging

from inference import AttributePredictor
import config

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="FashionCLIP API",
    description="Fashion attribute extraction using FashionCLIP",
    version="1.0.0"
)

# CORS for Firebase/Mobile apps
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global model (loaded once at startup)
predictor = None

@app.on_event("startup")
async def load_model():
    """Load model once when server starts - avoids 27s per request"""
    global predictor
    logger.info("🚀 Loading FashionCLIP model...")
    try:
        predictor = AttributePredictor(config.ONNX_MODEL_PATH, config.HF_MODEL_ID)
        predictor.precompute_all_attributes(config.ATTRIBUTE_CANDIDATES)
        logger.info("✅ Model loaded successfully!")
    except Exception as e:
        logger.error(f"❌ Failed to load model: {e}")
        raise

def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """
    Convert uploaded image to model-ready numpy array.
    Replaces your data_pipeline.py logic.
    """
    # Open image
    img = Image.open(io.BytesIO(image_bytes))
    
    # Convert to RGB
    if img.mode != 'RGB':
        img = img.convert('RGB')
    
    # Resize and crop
    img = img.resize((config.INPUT_SIZE, config.INPUT_SIZE), Image.BILINEAR)
    
    # To numpy
    img_np = np.array(img, dtype=np.float32)
    
    # Normalize (same as your pipeline)
    img_np = img_np / 255.0
    img_np = (img_np - np.array(config.CLIP_MEAN)) / np.array(config.CLIP_STD)
    
    # HWC to CHW
    img_np = np.transpose(img_np, (2, 0, 1))
    
    # Add batch dimension
    img_np = np.expand_dims(img_np, axis=0)
    
    return img_np.astype(np.float32)

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "online",
        "service": "FashionCLIP API",
        "model_loaded": predictor is not None
    }

@app.get("/health")
async def health_check():
    """Detailed health check"""
    if predictor is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    return {"status": "healthy", "model": "ready"}

@app.post("/analyze")
async def analyze_fashion_image(file: UploadFile = File(...)):
    """
    Main endpoint: Upload image, get fashion attributes JSON
    
    Usage from mobile:
    POST https://your-api-url.com/analyze
    Body: multipart/form-data with 'file' field
    """
    if predictor is None:
        raise HTTPException(status_code=503, detail="Model not initialized")
    
    # Validate image
    if not file.content_type.startswith('image/'):
        raise HTTPException(
            status_code=400, 
            detail=f"Invalid file type: {file.content_type}"
        )
    
    try:
        # Read image
        image_bytes = await file.read()
        logger.info(f"📸 Processing: {file.filename} ({len(image_bytes)} bytes)")
        
        # Preprocess
        image_np = preprocess_image(image_bytes)
        
        # Run inference (same as your main.py)
        img_vector = predictor.get_image_embedding(image_np)
        raw_attributes = predictor.classify_all(img_vector)
        
        # Format response
        response = {
            "id": str(uuid.uuid4()),
            "filename": file.filename,
            "status": "success"
        }
        
        # Add attributes with confidence scores
        for key, (label, confidence) in raw_attributes.items():
            response[key] = {
                "value": label,
                "confidence": float(confidence)
            }
        
        logger.info(f"✅ Done: {response['category']['value']}")
        return JSONResponse(content=response)
        
    except Exception as e:
        logger.error(f"❌ Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)