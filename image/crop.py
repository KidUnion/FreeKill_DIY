import os
from PIL import Image
from tqdm import tqdm

def resize_and_center_crop(image, target_width, target_height):
    original_width, original_height = image.size

    # 计算所需的最小缩放比例，使原图能完全包含目标尺寸
    scale = max(target_width / original_width, target_height / original_height)
    new_width = int(original_width * scale)
    new_height = int(original_height * scale)

    # 缩放图像
    resized_image = image.resize((new_width, new_height), Image.Resampling.LANCZOS)

    # 中心裁剪
    left = (new_width - target_width) // 2
    top = (new_height - target_height) // 2
    right = left + target_width
    bottom = top + target_height

    cropped_image = resized_image.crop((left, top, right, bottom))
    return cropped_image

def process_images(input_dir, output_dir, target_width=256, target_height=256):
    os.makedirs(output_dir, exist_ok=True)
    image_files = [f for f in os.listdir(input_dir) if f.lower().endswith(".jpg")]

    for filename in tqdm(image_files, desc="Processing images"):
        input_path = os.path.join(input_dir, filename)
        output_path = os.path.join(output_dir, filename)

        try:
            image = Image.open(input_path).convert("RGB")
            processed = resize_and_center_crop(image, target_width, target_height)
            processed.save(output_path, quality=95)
        except Exception as e:
            print(f"❌ Failed to process {filename}: {e}")

# 示例调用
if __name__ == "__main__":
    input_dir = "D:\FreeKill-release\packages\DIY\image\origin"              # 替换为你的源目录
    output_dir = "D:\FreeKill-release\packages\DIY\image\generals"        # 替换为输出目录
    target_width = 250                    # 自定义宽度
    target_height = 292                   # 自定义高度

    process_images(input_dir, output_dir, target_width, target_height)
