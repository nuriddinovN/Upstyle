Upstyle — Fashion attribute extraction & image generation
Simple README that explains the repository architecture and usage.

Project summary
Upstyle extracts fashion attributes from clothing images (FashionCLIP) and includes an LLM-based image-generation helper for upcycling ideas. The repo is split into a lightweight API, local inference tools, and optional cloud deployment artifacts.

High-level architecture
API layer
FastAPI server (api_server.py) — exposes /analyze and health endpoints for image uploads.
Inference layer
inference.py — loads an ONNX FashionCLIP model and provides embedding/classification utilities.
data_pipeline.py — prepares image tensors (MindSpore or lightweight PIL alternative).
Hybrid/local runner
main.py — example single-file analyzer using the pipeline + predictor.
analysis.py — helper to profile/run the pipeline.
LLM utilities
llm/ — scripts for upcycling idea generation and final product image generation (uses Generative APIs).
Models and assets
models/ — ONNX model file(s).
Flow: client → FastAPI upload → preprocess → ONNX model (onnxruntime) → attribute classification → JSON response.

Where MindSpore is used
MindSpore Dataset & vision transforms are used in data_pipeline.py to decode, resize/crop, normalize and batch images.
Advantages:
Simple, declarative dataset + transform pipeline (generator → map → batch).
Efficient I/O and transform execution (reduced Python overhead).
Easy parallelism and consistent preprocessing semantics.
Good hardware acceleration on supported devices.
Conversion note: original model pipeline was adapted and the model was exported/converted to ONNX (via MindSpore / MindSpore-Lite) so inference runs with onnxruntime for portable, fast CPU/GPU execution.
Why ONNX
ONNX provides a portable inference format compatible with onnxruntime across platforms.
Converting from MindSpore to ONNX allows running the model without a full MindSpore runtime dependency during inference.
Quickstart (local)
Create & activate venv (example)

bash -lc "python -m venv .venv && source .venv/bin/activate"
Install requirements

bash -lc "pip install -r requirements.txt"
Ensure model path in config.py points to models/fashionclip.simplified.onnx
Run API locally

python api_server.py
Test with curl (example)

curl -X POST -F "file=@/path/to/img.jpg" http://127.0.0.1:8000/analyze
Docker & Cloud Run
Dockerfile provided for containerizing the API. It copies the ONNX model to /app/models/.
For Cloud Run: enable required Google APIs, set correct project ID, and deploy. Ensure the model path and env vars are correct.
Environment & credentials
LLM/vision APIs read keys from .env in llm/ (e.g., GEMINI_API_KEY, STABILITY_API_KEY).
For local ONNX inference no external API key is required.
Troubleshooting (common issues)
ModuleNotFoundError for fastapi: run with the venv python or install requirements into the interpreter you're using.
ONNX load error (NoSuchFile): ensure config.ONNX_MODEL_PATH is a relative path to the local models/ folder (no leading /).
Generative Vision access: if Google Gemini vision models are not listed, enable Generative Language API, enable billing, and request vision access via the Cloud Console.
Files to inspect
api_server.py — API endpoints and startup model load.
inference.py — ONNX runtime usage and classification logic.
data_pipeline.py — MindSpore transforms and batch pipeline.
models/ — contains ONNX artifact.
License
Add your license file (e.g., MIT) as needed.


GPT-5 mini • 1x
