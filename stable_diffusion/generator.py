# required libraries for import on requirements.txt
# torch, diffusers, transformers, accelerate

# windows/linux/apple intel code
'''
import torch
from diffusers import StableDiffusionPipeline

model_id = "CompVis/stable-diffusion-v1-4"
device = "cpu"


pipe = StableDiffusionPipeline.from_pretrained(model_id, torch_dtype=torch.float32)
pipe = pipe.to(device)

prompt = "a photo of an astronaut riding a horse on mars"
image = pipe(prompt).images[0]  
    
image.save("astronaut_rides_horse.png")
'''

# apple silicon code
from diffusers import DiffusionPipeline

device = "mps"

pipe = DiffusionPipeline.from_pretrained("runwayml/stable-diffusion-v1-5")
pipe = pipe.to(device)

# Recommended if your computer has < 64 GB of RAM
pipe.enable_attention_slicing()

# pipe.load_textual_inversion("./dkjkd.pt")

prompt = "A right triangle"
#prompt = "a mathematical geometric diagram of a right triangle with angles 30, 60, and 90 clearly labelled with black lines making up the triangle and pure white in the background"

# First-time "warmup" pass if PyTorch version is 1.13 (see explanation above)
_ = pipe(prompt, num_inference_steps=1)

# Results match those from the CPU device after the warmup pass.
image = pipe(prompt).images[0]

image.save("testimage3.png")