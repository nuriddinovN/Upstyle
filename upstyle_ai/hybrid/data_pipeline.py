# data_pipeline.py
import mindspore.dataset as ds
import mindspore.dataset.vision as vision
import numpy as np
import config

def create_batch_pipeline(image_paths_list):
    """
    Creates a MindSpore pipeline for a LIST of images.
    """
    if not image_paths_list:
        raise ValueError("Image path list is empty!")

    # 1. Create a Generator that yields images one by one from the list
    def multi_image_generator():
        for path in image_paths_list:
            # Read file as binary
            yield (np.fromfile(path, dtype=np.uint8),)

    # 2. Create Dataset
    # shuffle=False is CRITICAL to keep the output order matching the input list
    dataset = ds.GeneratorDataset(
        source=multi_image_generator, 
        column_names=["image"], 
        shuffle=False 
    )

    # 3. Define Transforms
    transforms_list = [
        vision.Decode(),                    
        vision.Resize(config.INPUT_SIZE),   
        vision.CenterCrop(config.INPUT_SIZE),
        vision.Rescale(1.0 / 255.0, 0.0),   
        vision.Normalize(mean=config.CLIP_MEAN, std=config.CLIP_STD, is_hwc=True),
        vision.HWC2CHW()                    
    ]

    # 4. Apply Map & Batch
    dataset = dataset.map(operations=transforms_list, input_columns=["image"])
    dataset = dataset.batch(1) 
    
    return dataset