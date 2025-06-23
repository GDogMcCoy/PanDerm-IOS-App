#!/usr/bin/env python3
"""
Create Test Model for PanDerm Local Inference
This script creates test Core ML models for immediate implementation and testing.
"""

import os
import sys
import numpy as np
from pathlib import Path

try:
    import coremltools as ct
    from coremltools.models import neural_network
    from coremltools import TensorType
    print("✅ CoreML Tools imported successfully")
except ImportError:
    print("❌ CoreML Tools not found. Installing...")
    os.system("pip install coremltools")
    import coremltools as ct
    from coremltools.models import neural_network
    from coremltools import TensorType

def create_panderm_classification_model():
    """Create a PanDerm classification model for skin condition analysis"""
    print("Creating PanDerm Classification Model...")
    
    # Model parameters
    input_size = (1, 3, 224, 224)  # Batch, Channels, Height, Width
    num_classes = 9  # Match the skin condition classes in LocalInferenceService
    
    # Create a simple but realistic model structure
    input_features = [
        ('input', TensorType(shape=input_size, dtype=np.float32))
    ]
    
    output_features = [
        ('linear_48', TensorType(shape=(1, num_classes), dtype=np.float32))
    ]
    
    # Create a mock model using a simple linear classifier
    class MockPanDermModel:
        def predict(self, inputs):
            # Simulate realistic predictions for skin conditions
            batch_size = inputs['input'].shape[0]
            
            # Generate more realistic probability distributions
            # Favor some classes over others to simulate real model behavior
            logits = np.random.randn(batch_size, num_classes)
            
            # Bias towards common skin conditions
            class_weights = np.array([0.8, 1.2, 0.6, 1.5, 1.0, 0.7, 0.9, 0.5, 0.4])
            logits = logits * class_weights
            
            # Apply softmax to get probabilities
            exp_logits = np.exp(logits - np.max(logits, axis=1, keepdims=True))
            probabilities = exp_logits / np.sum(exp_logits, axis=1, keepdims=True)
            
            return {'linear_48': probabilities}
    
    mock_model = MockPanDermModel()
    
    # Convert to Core ML
    coreml_model = ct.convert(
        mock_model,
        inputs=input_features,
        outputs=output_features,
        compute_units=ct.ComputeUnit.ALL,
        minimum_deployment_target=ct.target.iOS16
    )
    
    # Add metadata
    coreml_model.short_description = "PanDerm Skin Condition Classification Model"
    coreml_model.author = "PanDerm AI Team"
    coreml_model.license = "Educational Use Only"
    coreml_model.version = "1.0.0"
    
    # Add class labels
    skin_condition_classes = [
        "actinic_keratosis", "basal_cell_carcinoma", "dermatofibroma",
        "melanoma", "nevus", "pigmented_benign_keratosis",
        "seborrheic_keratosis", "squamous_cell_carcinoma", "vascular_lesion"
    ]
    
    # Set class labels for the output
    coreml_model.user_defined_metadata["classes"] = ",".join(skin_condition_classes)
    coreml_model.user_defined_metadata["model_type"] = "classification"
    coreml_model.user_defined_metadata["input_size"] = "224x224"
    coreml_model.user_defined_metadata["framework"] = "Core ML Test Model"
    
    return coreml_model, skin_condition_classes

def create_enhanced_panderm_model():
    """Create an enhanced multi-task PanDerm model"""
    print("Creating Enhanced PanDerm Multi-task Model...")
    
    input_size = (1, 3, 224, 224)
    num_classes = 15  # Extended classification
    
    input_features = [
        ('input', TensorType(shape=input_size, dtype=np.float32))
    ]
    
    output_features = [
        ('classification', TensorType(shape=(1, num_classes), dtype=np.float32)),
        ('confidence', TensorType(shape=(1, 1), dtype=np.float32)),
        ('risk_score', TensorType(shape=(1, 1), dtype=np.float32))
    ]
    
    class EnhancedPanDermModel:
        def predict(self, inputs):
            batch_size = inputs['input'].shape[0]
            
            # Generate classification probabilities
            logits = np.random.randn(batch_size, num_classes)
            
            # Enhanced class weights for 15 classes
            class_weights = np.array([
                0.8, 1.2, 0.6, 1.5, 1.0, 0.7, 0.9, 0.5, 0.4, 0.6,
                0.8, 0.9, 1.1, 0.7, 0.5
            ])
            logits = logits * class_weights
            
            # Apply softmax
            exp_logits = np.exp(logits - np.max(logits, axis=1, keepdims=True))
            probabilities = exp_logits / np.sum(exp_logits, axis=1, keepdims=True)
            
            # Generate confidence score (0-1)
            confidence = np.random.uniform(0.6, 0.95, (batch_size, 1))
            
            # Generate risk score (0-1, higher = more concerning)
            risk_score = np.random.uniform(0.1, 0.8, (batch_size, 1))
            
            return {
                'classification': probabilities.astype(np.float32),
                'confidence': confidence.astype(np.float32),
                'risk_score': risk_score.astype(np.float32)
            }
    
    enhanced_model = EnhancedPanDermModel()
    
    # Convert to Core ML
    coreml_model = ct.convert(
        enhanced_model,
        inputs=input_features,
        outputs=output_features,
        compute_units=ct.ComputeUnit.ALL,
        minimum_deployment_target=ct.target.iOS16
    )
    
    # Enhanced metadata
    coreml_model.short_description = "Enhanced PanDerm Multi-task Model"
    coreml_model.author = "PanDerm AI Research Team"
    coreml_model.license = "Research and Educational Use"
    coreml_model.version = "2.0.0"
    
    # Extended class labels
    extended_classes = [
        "actinic_keratosis", "basal_cell_carcinoma", "dermatofibroma",
        "melanoma", "nevus", "pigmented_benign_keratosis",
        "seborrheic_keratosis", "squamous_cell_carcinoma", "vascular_lesion",
        "eczema", "psoriasis", "contact_dermatitis", "hemangioma",
        "lipoma", "fibroma"
    ]
    
    coreml_model.user_defined_metadata["classes"] = ",".join(extended_classes)
    coreml_model.user_defined_metadata["model_type"] = "multi_task"
    coreml_model.user_defined_metadata["capabilities"] = "classification,confidence,risk_assessment"
    
    return coreml_model, extended_classes

def create_model_package(model, model_name, output_dir):
    """Create a .mlpackage for the model"""
    package_path = output_dir / f"{model_name}.mlpackage"
    
    # Remove existing package if it exists
    if package_path.exists():
        import shutil
        shutil.rmtree(package_path)
        print(f"Removed existing package: {package_path}")
    
    # Save as .mlpackage
    model.save(package_path)
    print(f"✅ Created model package: {package_path}")
    
    return package_path

def validate_model(model_path, test_image_shape=(1, 3, 224, 224)):
    """Validate the created model"""
    print(f"Validating model: {model_path}")
    
    try:
        # Load the model
        model = ct.models.MLModel(model_path)
        
        # Get model info
        spec = model.get_spec()
        print(f"  Model description: {spec.description}")
        
        # Test prediction with dummy data
        test_input = np.random.rand(*test_image_shape).astype(np.float32)
        test_dict = {'input': test_input}
        
        result = model.predict(test_dict)
        print(f"  Test prediction successful")
        print(f"  Output keys: {list(result.keys())}")
        
        for key, value in result.items():
            if hasattr(value, 'shape'):
                print(f"    {key}: shape {value.shape}")
            else:
                print(f"    {key}: {type(value)}")
        
        return True
        
    except Exception as e:
        print(f"  ❌ Validation failed: {e}")
        return False

def main():
    """Main function to create all test models"""
    print("🚀 Creating PanDerm Test Models for Local Inference")
    print("=" * 60)
    
    # Create output directory
    output_dir = Path("PanDerm")
    output_dir.mkdir(exist_ok=True)
    
    try:
        # Create basic classification model
        print("\n1. Creating Basic Classification Model...")
        basic_model, basic_classes = create_panderm_classification_model()
        basic_path = create_model_package(basic_model, "PanDerm", output_dir)
        
        print(f"   Classes: {', '.join(basic_classes)}")
        print(f"   Model saved to: {basic_path}")
        
        # Validate basic model
        if validate_model(basic_path):
            print("   ✅ Basic model validation passed")
        else:
            print("   ❌ Basic model validation failed")
        
        # Create enhanced model
        print("\n2. Creating Enhanced Multi-task Model...")
        enhanced_model, enhanced_classes = create_enhanced_panderm_model()
        enhanced_path = create_model_package(enhanced_model, "PanDerm 2", output_dir)
        
        print(f"   Classes: {', '.join(enhanced_classes[:5])}... (+{len(enhanced_classes)-5} more)")
        print(f"   Model saved to: {enhanced_path}")
        
        # Validate enhanced model
        if validate_model(enhanced_path):
            print("   ✅ Enhanced model validation passed")
        else:
            print("   ❌ Enhanced model validation failed")
        
        # Create models info file
        info_file = output_dir / "models_info.txt"
        with open(info_file, 'w') as f:
            f.write("PanDerm Test Models Information\n")
            f.write("=" * 40 + "\n\n")
            f.write(f"Basic Model: PanDerm.mlpackage\n")
            f.write(f"  - Classes: {len(basic_classes)}\n")
            f.write(f"  - Input: 224x224x3 RGB image\n")
            f.write(f"  - Output: Classification probabilities\n\n")
            f.write(f"Enhanced Model: PanDerm 2.mlpackage\n")
            f.write(f"  - Classes: {len(enhanced_classes)}\n")
            f.write(f"  - Input: 224x224x3 RGB image\n")
            f.write(f"  - Outputs: Classification, Confidence, Risk Score\n\n")
            f.write("Model Classes:\n")
            for i, cls in enumerate(basic_classes, 1):
                f.write(f"  {i}. {cls.replace('_', ' ').title()}\n")
        
        print(f"\n📝 Models information saved to: {info_file}")
        
        print("\n" + "=" * 60)
        print("🎉 Model creation completed successfully!")
        print("\nNext steps:")
        print("1. Add the .mlpackage files to your Xcode project")
        print("2. Ensure they're included in the app bundle")
        print("3. Update the model names in LocalInferenceService.swift if needed")
        print("4. Test the app with image analysis")
        
        return True
        
    except Exception as e:
        print(f"\n❌ Error creating models: {e}")
        print(f"Error type: {type(e).__name__}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1) 