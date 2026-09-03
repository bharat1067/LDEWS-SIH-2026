import os
import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, transforms, models
from torch.utils.data import DataLoader
import joblib

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
REGISTRY_DIR = os.path.join(BASE_DIR, "model_registry")

def train_image_model():
    print("--- STARTING BACKGROUND IMAGE TRAINING WORKER ---")
    data_dir = os.path.join(BASE_DIR, "data/Lumpy Skin Images Dataset")
    
    if not os.path.exists(data_dir):
        print(f"Error: {data_dir} not found!")
        return

    # 1. Transforms (ResNet requires 224x224 and specific normalization)
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ])

    # 2. Load Dataset
    print("Loading Image Dataset...")
    dataset = datasets.ImageFolder(root=data_dir, transform=transform)
    dataloader = DataLoader(dataset, batch_size=32, shuffle=True)
    
    class_names = dataset.classes
    print(f"Found {len(dataset)} images belonging to {len(class_names)} classes: {class_names}")

    # 3. Model Architecture (Transfer Learning)
    print("Downloading pre-trained ResNet18...")
    model = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)
    
    # Replace final layer for our 2 classes
    num_ftrs = model.fc.in_features
    model.fc = nn.Linear(num_ftrs, len(class_names))
    
    # 4. Training
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = model.to(device)
    
    print(f"Training on {device} (5 epochs)...")
    
    num_epochs = 5
    for epoch in range(num_epochs):
        model.train()
        running_loss = 0.0
        for inputs, labels in dataloader:
            inputs, labels = inputs.to(device), labels.to(device)
            
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
            
        print(f"Epoch {epoch+1}/{num_epochs} Complete! Loss: {running_loss/len(dataloader):.4f}")
    
    print("Training Complete!")
    
    # 5. Save to Model Registry
    os.makedirs(REGISTRY_DIR, exist_ok=True)
    
    # Save the PyTorch weights
    torch.save(model.state_dict(), os.path.join(REGISTRY_DIR, "lumpy_cnn_v1.pth"))
    
    # Save the class names so the API knows what index 0 and 1 mean
    joblib.dump(class_names, os.path.join(REGISTRY_DIR, "lumpy_class_names.joblib"))
    
    print("--- TRAINING COMPLETE ---")
    print(f"Image Model weights successfully saved to {REGISTRY_DIR}/lumpy_cnn_v1.pth!")

if __name__ == "__main__":
    train_image_model()
