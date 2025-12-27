# main.py
import time
import os
import json
import uuid
import config
from data_pipeline import create_batch_pipeline
from inference import AttributePredictor

# Helper to check extensions
def is_image_file(filename):
    return filename.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.webp'))

def main():
    print(f"⚔️  FashionCLIP Single File Analyzer")
    print(f"   📸 Source: {config.SINGLE_IMAGE_PATH}")
    print(f"   📂 Output: {config.OUTPUT_DIR}")
    
    # 1. Validate Input and Setup Output Directory
    if not os.path.exists(config.SINGLE_IMAGE_PATH) or not is_image_file(config.SINGLE_IMAGE_PATH):
        print(f"❌ Error: Source image not found or is not a valid image file.")
        return

    # Create output directory if it doesn't exist
    if not os.path.exists(config.OUTPUT_DIR):
        os.makedirs(config.OUTPUT_DIR)
        print(f"   ✅ Created output directory: {config.OUTPUT_DIR}")

    # 2. Init Model (Load once)
    predictor = AttributePredictor(config.ONNX_MODEL_PATH, config.HF_MODEL_ID)
    predictor.precompute_all_attributes(config.ATTRIBUTE_CANDIDATES)

    # 3. Init Pipeline for a single image
    # The pipeline function expects a list of paths
    pipeline = create_batch_pipeline([config.SINGLE_IMAGE_PATH])
    iterator = pipeline.create_dict_iterator(output_numpy=True)

    # 4. Process the single image
    print("\n🔮 Starting Inference...")
    start_time = time.time()
    
    filename = os.path.basename(config.SINGLE_IMAGE_PATH)
    try:
        # Get the single item from the iterator
        data = next(iter(iterator))
        image_np = data['image'] # Shape (1, 3, 224, 224)
        
        # --- Inference ---
        img_vector = predictor.get_image_embedding(image_np)
        raw_attributes = predictor.classify_all(img_vector)
        
        # --- Formatting (Maintains original structure) ---
        record = {
            "id": str(uuid.uuid4()),
            "filename": filename
        }
        
        for key, (label, score) in raw_attributes.items():
            record[key] = label

        # --- Save Individual JSON ---
        base_name = os.path.splitext(filename)[0]
        json_filename = f"{base_name}.json"
        output_path = os.path.join(config.OUTPUT_DIR, json_filename)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(record, f, indent=4)
        
        print(f"   ✅ Saved: {output_path}")
        
    except Exception as e:
        print(f"   ❌ Error processing {filename}: {e}")

    end_time = time.time()

    print(f"\n✨ Done! Processed 1 image.")
    print(f"📊 Total Time: {end_time - start_time:.2f}s")

if __name__ == "__main__":
    main()