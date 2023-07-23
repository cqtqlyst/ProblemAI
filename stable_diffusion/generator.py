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


import torch
import safetensors
from diffusers import DiffusionPipeline
from safetensors.torch import load_file


def load_lora_weights(pipeline, checkpoint_path):
    # load base model
    pipeline.to("mps")
    LORA_PREFIX_UNET = "lora_unet"
    LORA_PREFIX_TEXT_ENCODER = "lora_te"
    alpha = 0.75
    # load LoRA weight from .safetensors
    state_dict = load_file(checkpoint_path, device="mps")
    visited = []

    # directly update weight in diffusers model
    for key in state_dict:
        # it is suggested to print out the key, it usually will be something like below
        # "lora_te_text_model_encoder_layers_0_self_attn_k_proj.lora_down.weight"

        # as we have set the alpha beforehand, so just skip
        if ".alpha" in key or key in visited:
            continue

        if "text" in key:
            layer_infos = key.split(".")[0].split(LORA_PREFIX_TEXT_ENCODER + "_")[-1].split("_")
            curr_layer = pipeline.text_encoder
        else:
            layer_infos = key.split(".")[0].split(LORA_PREFIX_UNET + "_")[-1].split("_")
            curr_layer = pipeline.unet

        # find the target layer
        temp_name = layer_infos.pop(0)
        while len(layer_infos) > -1:
            try:
                curr_layer = curr_layer.__getattr__(temp_name)
                if len(layer_infos) > 0:
                    temp_name = layer_infos.pop(0)
                elif len(layer_infos) == 0:
                    break
            except Exception:
                if len(temp_name) > 0:
                    temp_name += "_" + layer_infos.pop(0)
                else:
                    temp_name = layer_infos.pop(0)

        pair_keys = []
        if "lora_down" in key:
            pair_keys.append(key.replace("lora_down", "lora_up"))
            pair_keys.append(key)
        else:
            pair_keys.append(key)
            pair_keys.append(key.replace("lora_up", "lora_down"))

        # update weight
        if len(state_dict[pair_keys[0]].shape) == 4:
            weight_up = state_dict[pair_keys[0]].squeeze(3).squeeze(2).to(torch.float32)
            weight_down = state_dict[pair_keys[1]].squeeze(3).squeeze(2).to(torch.float32)
            curr_layer.weight.data += alpha * torch.mm(weight_up, weight_down).unsqueeze(2).unsqueeze(3)
        else:
            weight_up = state_dict[pair_keys[0]].to(torch.float32)
            weight_down = state_dict[pair_keys[1]].to(torch.float32)
            curr_layer.weight.data += alpha * torch.mm(weight_up, weight_down)

        # update visited list
        for item in pair_keys:
            visited.append(item)

    return pipeline

device = "mps"

pipe = DiffusionPipeline.from_pretrained("runwayml/stable-diffusion-v1-5")
pipe = pipe.to(device)

# Recommended if your computer has < 64 GB of RAM
pipe.enable_attention_slicing()

#pipe.unet.load_attn_procs("30-60-90 triangle.safetensors")

pipe.load_lora_weights("30-60-90 triangle.safetensors")

#pipe = load_lora_weights(pipe, "30-60-90 triangle.safetensors")

prompt = "very clear and obvious mathematical geometric diagram of a right_triangle 30-60-90 triangle with angles of 90 degrees, 60 degrees, and 30 degrees"
#prompt = "a mathematical geometric diagram of a right triangle with angles 30, 60, and 90 clearly labelled with black lines making up the triangle and pure white in the background"

# First-time "warmup" pass if PyTorch version is 1.13 (see explanation above)
# _ = pipe(prompt, num_inference_steps=1)

# Results match those from the CPU device after the warmup pass.
image = pipe(prompt, num_inference_steps=25, guidance_scale=7.5, cross_attention_kwargs={"scale": 1}).images[0]

image.save("displayed_image4.png")

'''
def make_image():
    from diffusers import DiffusionPipeline

    device = "mps"

    pipe = DiffusionPipeline.from_pretrained("runwayml/stable-diffusion-v1-5")
    pipe = pipe.to(device)

    # Recommended if your computer has < 64 GB of RAM
    pipe.enable_attention_slicing()

    pipe.unet.load_attn_procs("30-60-90 triangle.safetensors")

    prompt = "30-60-90 triangle"
    #prompt = "a mathematical geometric diagram of a right triangle with angles 30, 60, and 90 clearly labelled with black lines making up the triangle and pure white in the background"

    # First-time "warmup" pass if PyTorch version is 1.13 (see explanation above)
    _ = pipe(prompt, num_inference_steps=1)

    # Results match those from the CPU device after the warmup pass.
    image = pipe(prompt).images[0]

    image.save("displayed_image.png")
'''