#!/usr/bin/env python3
"""
Create Test PanDerm Core ML Model
This script creates a simple test model for immediate implementation testing.
In production, this would be replaced with the actual trained PanDerm model.
"""

import coremltools as ct
import numpy as np
import os

def create_test_panderm_model():
    """Create a simple test model for immediate implementation"""
    
    print("Creating test PanDerm Core ML model...")
    
    # Define input shape
    input_shape = (1, 3, 512, 512)  # Batch, Channels, Height, Width
    
    # Create a simple neural network class
    class SimplePanDermModel:
        def __init__(self):
            self.model_name = "PanDerm-Test-v1.0"
            print(f"Initializing {self.model_name}")
        
        def predict(self, input_data):
            """Simulate model predictions"""
            batch_size = input_data.shape[0]
            
            # Classification output (15 classes)
            # Simulate probabilities for different skin conditions
            classification = np.random.rand(batch_size, 15)
            # Normalize to sum to 1
            classification = classification / np.sum(classification, axis=1, keepdims=True)
            
            # Segmentation output (binary mask)
            segmentation = np.random.rand(batch_size, 1, 512, 512)
            
            # Detection output (bounding boxes: x, y, width, height, confidence)
            detection = np.random.rand(batch_size, 10, 5)
            # Set confidence values (index 4) to reasonable range
            detection[:, :, 4] = np.random.rand(batch_size, 10) * 0.8 + 0.1
            
            return {
                'classification': classification,
                'segmentation': segmentation,
                'detection': detection
            }
    
    # Create model instance
    model = SimplePanDermModel()
    
    # Create sample input for conversion
    sample_input = np.random.rand(*input_shape).astype(np.float32)
    
    # Convert to Core ML
    print("Converting to Core ML format...")
    coreml_model = ct.convert(
        model,
        inputs=[ct.TensorType(name="input", shape=input_shape)],
        outputs=[
            ct.TensorType(name="classification"),
            ct.TensorType(name="segmentation"),
            ct.TensorType(name="detection")
        ],
        source="milinternal",
        compute_units=ct.ComputeUnit.ALL
    )
    
    # Add metadata
    coreml_model.author = "PanDerm Team"
    coreml_model.license = "Proprietary"
    coreml_model.short_description = "Test PanDerm model for local inference"
    coreml_model.version = "1.0.0"
    
    # Save model
    model_filename = "PanDerm-Test-v1.0.mlmodel"
    coreml_model.save(model_filename)
    
    print(f"Model saved as: {model_filename}")
    print(f"Model size: {os.path.getsize(model_filename) / (1024*1024):.2f} MB")
    
    # Test the model
    print("Testing model...")
    test_input = np.random.rand(*input_shape).astype(np.float32)
    test_output = coreml_model.predict({"input": test_input})
    
    print("Model test successful!")
    print(f"Classification output shape: {test_output['classification'].shape}")
    print(f"Segmentation output shape: {test_output['segmentation'].shape}")
    print(f"Detection output shape: {test_output['detection'].shape}")
    
    return coreml_model

def create_enhanced_test_model():
    """Create a more sophisticated test model with better simulation"""
    
    print("Creating enhanced test PanDerm Core ML model...")
    
    class EnhancedPanDermModel:
        def __init__(self):
            self.model_name = "PanDerm-Enhanced-Test-v1.0"
            self.class_names = [
                "melanoma", "basal_cell_carcinoma", "squamous_cell_carcinoma",
                "dysplastic_nevus", "compound_nevus", "seborrheic_keratosis",
                "hemangioma", "dermatofibroma", "eczema", "psoriasis",
                "contact_dermatitis", "acne", "rosacea", "vitiligo", "other"
            ]
        
        def predict(self, input_data):
            batch_size = input_data.shape[0]
            
            # More realistic classification probabilities
            # Bias toward benign conditions (as they're more common)
            classification = np.zeros((batch_size, 15))
            
            for i in range(batch_size):
                # Simulate more realistic probability distribution
                # Higher probability for benign conditions
                benign_probs = np.random.beta(2, 1, 8)  # Benign conditions
                malignant_probs = np.random.beta(1, 3, 3)  # Malignant conditions
                inflammatory_probs = np.random.beta(1.5, 2, 4)  # Inflammatory conditions
                
                classification[i, :8] = benign_probs  # Benign
                classification[i, 8:11] = malignant_probs  # Malignant
                classification[i, 11:] = inflammatory_probs  # Inflammatory
                
                # Normalize
                classification[i] = classification[i] / np.sum(classification[i])
            
            # Segmentation with more realistic patterns
            segmentation = np.zeros((batch_size, 1, 512, 512))
            for i in range(batch_size):
                # Create circular lesion-like patterns
                center_x, center_y = np.random.randint(100, 412, 2)
                radius = np.random.randint(20, 80)
                
                y, x = np.ogrid[:512, :512]
                mask = (x - center_x)**2 + (y - center_y)**2 <= radius**2
                segmentation[i, 0] = mask.astype(np.float32) * np.random.uniform(0.7, 1.0)
            
            # Detection with realistic bounding boxes
            detection = np.zeros((batch_size, 10, 5))
            for i in range(batch_size):
                num_detections = np.random.randint(1, 6)
                for j in range(num_detections):
                    # Generate realistic bounding box
                    x = np.random.uniform(50, 462)
                    y = np.random.uniform(50, 462)
                    width = np.random.uniform(20, 100)
                    height = np.random.uniform(20, 100)
                    confidence = np.random.uniform(0.6, 0.95)
                    
                    detection[i, j] = [x, y, width, height, confidence]
            
            return {
                'classification': classification,
                'segmentation': segmentation,
                'detection': detection
            }
    
    # Create model
    model = EnhancedPanDermModel()
    
    # Convert to Core ML
    input_shape = (1, 3, 512, 512)
    coreml_model = ct.convert(
        model,
        inputs=[ct.TensorType(name="input", shape=input_shape)],
        outputs=[
            ct.TensorType(name="classification"),
            ct.TensorType(name="segmentation"),
            ct.TensorType(name="detection")
        ],
        source="milinternal",
        compute_units=ct.ComputeUnit.ALL
    )
    
    # Add metadata
    coreml_model.author = "PanDerm Team"
    coreml_model.license = "Proprietary"
    coreml_model.short_description = "Enhanced test PanDerm model with realistic simulation"
    coreml_model.version = "1.0.0"
    
    # Save model
    model_filename = "PanDerm-Enhanced-Test-v1.0.mlmodel"
    coreml_model.save(model_filename)
    
    print(f"Enhanced model saved as: {model_filename}")
    print(f"Model size: {os.path.getsize(model_filename) / (1024*1024):.2f} MB")
    
    return coreml_model

if __name__ == "__main__":
    print("PanDerm Test Model Generator")
    print("=" * 40)
    
    # Create basic test model
    basic_model = create_test_panderm_model()
    
    print("\n" + "=" * 40)
    
    # Create enhanced test model
    enhanced_model = create_enhanced_test_model()
    
    print("\n" + "=" * 40)
    print("Model generation complete!")
    print("\nNext steps:")
    print("1. Add the .mlmodel files to your Xcode project")
    print("2. Update LocalInferenceService to load the actual model")
    print("3. Test the inference pipeline")
    print("4. Replace simulation methods with real model calls")

    # Create a minimal, valid model
    input = ct.ImageType(shape=(1, 224, 224, 3))
    output = ct.TensorType(shape=(1, 5))
    mlmodel = ct.converters.convert(
        lambda x: np.zeros((1, 5), dtype=np.float32),
        inputs=[input],
        outputs=[output]
    )
    mlmodel.save("PanDerm/PanDerm/PanDerm-Placeholder-v1.0.mlmodel") 