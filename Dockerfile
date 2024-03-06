FROM python:3.6

RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install food-volume-estimation package
ADD food_volume_estimation/ food_volume_estimation/
copy setup.py .
RUN python setup.py install

# Add model files to image
COPY models/fine_tune_food_videos/monovideo_fine_tune_food_videos.json models/depth_architecture.json
COPY models/fine_tune_food_videos/monovideo_fine_tune_food_videos.h5 models/depth_weights.h5
COPY models/segmentation/mask_rcnn_food_segmentation.h5 models/segmentation_weights.h5
COPY datasets/density_new_abi.xlsx datasets/density_db.xlsx

# Copy and execute server script
COPY food_volume_estimation_app.py .

CMD uvicorn food_volume_estimation_app:app --host 0.0.0.0 --port ${PORT:-7777}
