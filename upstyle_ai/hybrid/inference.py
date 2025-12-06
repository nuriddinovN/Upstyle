# inference.py
import onnxruntime as ort
import numpy as np
from transformers import CLIPProcessor
import config

class AttributePredictor:
    def __init__(self, model_path, processor_id):
        # Set generic log level to 3 (Error) to reduce spam
        opts = ort.SessionOptions()
        opts.log_severity_level = 3 
        
        print("🧠 Loading ONNX Model...")
        self.session = ort.InferenceSession(model_path, sess_options=opts, providers=['CPUExecutionProvider'])
        self.processor = CLIPProcessor.from_pretrained(processor_id)
        
        # Dummy inputs for safe mode
        self.dummy_pixels = np.zeros((1, 3, 224, 224), dtype=np.float32)
        self.dummy_text_ids = np.zeros((1, 77), dtype=np.int64)
        self.dummy_text_mask = np.ones((1, 77), dtype=np.int64)
        
        self.attribute_embeds_map = {}

    def precompute_all_attributes(self, attribute_dict):
        """
        Loops through attributes and strictly processes text ONE BY ONE.
        This prevents the 'Shape Mismatch' error.
        """
        print("📝 Pre-computing text vectors (Safe Loop Mode)...")
        
        for category, candidates in attribute_dict.items():
            if not candidates: continue
            
            # Apply Template
            texts = [config.PROMPT_TEMPLATE.format(c) for c in candidates]
            
            # Strict Loop to satisfy ONNX fixed batch size
            embeds_list = []
            for t in texts:
                inputs = self.processor(text=[t], return_tensors="np", padding="max_length", max_length=77)
                
                ort_inputs = {
                    "pixel_values": self.dummy_pixels,
                    "input_ids": inputs["input_ids"].astype(np.int64),
                    "attention_mask": inputs["attention_mask"].astype(np.int64)
                }
                # Run single text
                out = self.session.run(["text_embeds"], ort_inputs)[0]
                embeds_list.append(out)
            
            # Stack into (N, 512) matrix
            self.attribute_embeds_map[category] = np.vstack(embeds_list)

    def get_image_embedding(self, image_np):
        ort_inputs = {
            "pixel_values": image_np.astype(np.float32),
            "input_ids": self.dummy_text_ids,
            "attention_mask": self.dummy_text_mask
        }
        return self.session.run(["image_embeds"], ort_inputs)[0]

    def classify_all(self, img_embeds):
        results = {}
        
        for category, text_matrix in self.attribute_embeds_map.items():
            # 1. Cosine Similarity (Dot Product)
            # Shapes: (1, 512) @ (N, 512).T -> (1, N)
            raw_logits = img_embeds @ text_matrix.T
            
            # 2. !!! APPLY SCALING !!! (The missing link)
            scaled_logits = raw_logits * config.LOGIT_SCALE
            
            # 3. Softmax
            exp_logits = np.exp(scaled_logits - np.max(scaled_logits)) # Subtract max for stability
            probs = exp_logits / np.sum(exp_logits, axis=1, keepdims=True)
            probs = probs[0]
            
            # 4. Result
            best_idx = np.argmax(probs)
            confidence = probs[best_idx]
            label = config.ATTRIBUTE_CANDIDATES[category][best_idx]
            
            results[category] = (label, confidence)
            
        return results