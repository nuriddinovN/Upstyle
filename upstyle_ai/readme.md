## Upstyle — Fashion attribute extraction & image generation

Simple README that explains the repository architecture and usage.

## Project summary
Upstyle extracts fashion attributes from clothing images (FashionCLIP) and includes an LLM-based image-generation helper for upcycling ideas. The repo is split into a lightweight API, local inference tools, and optional cloud deployment artifacts.

## High-level architecture
- API layer
  - FastAPI server (api_server.py) — exposes `/analyze` and health endpoints for image uploads.
- Inference layer
  - inference.py — loads an ONNX FashionCLIP model and provides embedding/classification utilities.
  - data_pipeline.py — prepares image tensors (MindSpore or lightweight PIL alternative).
- Hybrid/local runner
  - main.py — example single-file analyzer using the pipeline + predictor.
  - analysis.py — helper to profile/run the pipeline.
- LLM utilities
  - llm/ — scripts for upcycling idea generation and final product image generation (uses Generative APIs).
- Models and assets
  - models/ — ONNX model file(s).

Flow: client → FastAPI upload → preprocess → ONNX model (onnxruntime) → attribute classification → JSON response.

## Where MindSpore is used
- MindSpore Dataset & vision transforms are used in data_pipeline.py to decode, resize/crop, normalize and batch images.
- Advantages:
  - Simple, declarative dataset + transform pipeline (generator → map → batch).
  - Efficient I/O and transform execution (reduced Python overhead).
  - Easy parallelism and consistent preprocessing semantics.
  - Good hardware acceleration on supported devices.
- Conversion note: original model pipeline was adapted and the model was exported/converted to ONNX (via MindSpore / MindSpore-Lite) so inference runs with onnxruntime for portable, fast CPU/GPU execution.

## Why ONNX
- ONNX provides a portable inference format compatible with onnxruntime across platforms.
- Converting from MindSpore to ONNX allows running the model without a full MindSpore runtime dependency during inference.

## Quickstart (local)
1. Create & activate venv (example)
````bash
bash -lc "python -m venv .venv && source .venv/bin/activate"
````
2. Install requirements
````bash
bash -lc "pip install -r requirements.txt"
````
3. Ensure model path in config.py points to `models/fashionclip.simplified.onnx`
4. Run API locally
````bash
python api_server.py
````
5. Test with curl (example)
````bash
curl -X POST -F "file=@/path/to/img.jpg" http://127.0.0.1:8000/analyze
````

## Docker & Cloud Run
- Dockerfile provided for containerizing the API. It copies the ONNX model to `/app/models/`.
- For Cloud Run: enable required Google APIs, set correct project ID, and deploy. Ensure the model path and env vars are correct.

## Environment & credentials
- LLM/vision APIs read keys from `.env` in llm/ (e.g., GEMINI_API_KEY, STABILITY_API_KEY).
- For local ONNX inference no external API key is required.

## Troubleshooting (common issues)
- ModuleNotFoundError for fastapi: run with the venv python or install requirements into the interpreter you're using.
- ONNX load error (NoSuchFile): ensure config.ONNX_MODEL_PATH is a relative path to the local `models/` folder (no leading `/`).
- Generative Vision access: if Google Gemini vision models are not listed, enable Generative Language API, enable billing, and request vision access via the Cloud Console.

## Files to inspect
- api_server.py — API endpoints and startup model load.
- inference.py — ONNX runtime usage and classification logic.
- data_pipeline.py — MindSpore transforms and batch pipeline.
- models/ — contains ONNX artifact.


# data_pipeline.md

## Overview
Creates a MindSpore Dataset pipeline to load, decode, transform, normalize, and batch a list of image file paths for model inference.

## Dependencies
- mindspore.dataset (ds) and mindspore.dataset.vision (vision)
- numpy
- project `config` module containing:
  - CLIP_MEAN, CLIP_STD, INPUT_SIZE

## Function
### create_batch_pipeline(image_paths_list)
- Input: list of image file paths (strings)
- Behavior:
  1. Validates non-empty input list.
  2. Defines a generator (`multi_image_generator`) that yields each image as a uint8 numpy array (read via `np.fromfile`).
  3. Wraps the generator with `ds.GeneratorDataset(..., column_names=["image"], shuffle=False)` — preserving input order.
  4. Applies a sequence of vision transforms and batches the dataset with batch size 1.
- Output: a MindSpore `Dataset` object ready to iterate for inference.

## Transforms applied (order matters)
- `vision.Decode()` — decode bytes to image.
- `vision.Resize(config.INPUT_SIZE)` — resize shorter/longer edge (MindSpore behavior).
- `vision.CenterCrop(config.INPUT_SIZE)` — center crop to INPUT_SIZE.
- `vision.Rescale(1.0 / 255.0, 0.0)` — scale pixels to [0,1].
- `vision.Normalize(mean=config.CLIP_MEAN, std=config.CLIP_STD, is_hwc=True)` — normalize using CLIP stats.
- `vision.HWC2CHW()` — convert HWC to CHW channel order required by many models.

## Usage example
````python
from data_pipeline import create_batch_pipeline

paths = ["/path/to/img1.jpg", "/path/to/img2.jpg"]
ds = create_batch_pipeline(paths)

for batch in ds.create_dict_iterator():
    image_tensor = batch["image"]  # shape: (1, C, H, W)
    # feed image_tensor to inference/session
````

## Notes & advantages
- Using MindSpore Dataset API gives efficient I/O, parallel map capability, and consistent transforms.
- `shuffle=False` preserves input order for deterministic results.
- The pipeline returns batched tensors (batch size 1) suitable for single-image inference loops.
- If you prefer to avoid the MindSpore dependency, equivalent preprocessing can be implemented with PIL + NumPy (resize, convert RGB, normalize, transpose).
