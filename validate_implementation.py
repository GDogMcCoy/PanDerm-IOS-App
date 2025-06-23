#!/usr/bin/env python3
"""
Validate PanDerm Implementation
This script validates the completed PanDerm application implementation.
"""

import os
import sys
from pathlib import Path

def check_file_exists(file_path, description=""):
    """Check if a file exists and return the result"""
    if os.path.exists(file_path):
        size = os.path.getsize(file_path)
        print(f"✅ {file_path} exists ({size} bytes) - {description}")
        return True
    else:
        print(f"❌ {file_path} not found - {description}")
        return False

def check_swift_files():
    """Check for Swift implementation files"""
    print("\n📱 Swift Implementation Files:")
    
    swift_files = [
        ("PanDerm/PanDermApp.swift", "Main app entry point"),
        ("PanDerm/ContentView.swift", "Main navigation view"),
        ("PanDerm/Services/LocalInferenceService.swift", "Core ML inference service"),
        ("PanDerm/Views/ImageAnalysisView.swift", "Image analysis interface"),
        ("PanDerm/Views/PatientListView.swift", "Patient management"),
        ("PanDerm/Views/PatientDetailView.swift", "Patient details"),
        ("PanDerm/Views/AnalysisHistoryView.swift", "Analysis history"),
        ("PanDerm/Views/InferenceSettingsView.swift", "Settings interface"),
        ("PanDerm/ViewModels/PatientViewModel.swift", "Patient data management"),
        ("PanDerm/ViewModels/SkinConditionViewModel.swift", "Analysis workflow"),
        ("PanDerm/Models/Patient.swift", "Patient data models"),
        ("PanDerm/Models/SkinCondition.swift", "Medical condition models"),
        ("PanDerm/Models/AnalysisModels.swift", "ML result models"),
    ]
    
    passed = 0
    total = len(swift_files)
    
    for file_path, description in swift_files:
        if check_file_exists(file_path, description):
            passed += 1
    
    return passed, total

def check_core_ml_models():
    """Check for Core ML model packages"""
    print("\n🧠 Core ML Models:")
    
    model_files = [
        ("PanDerm/PanDerm.mlpackage", "Primary classification model"),
        ("PanDerm/PanDerm 2.mlpackage", "Enhanced multi-task model"),
    ]
    
    passed = 0
    total = len(model_files)
    
    for file_path, description in model_files:
        if check_file_exists(file_path, description):
            passed += 1
    
    return passed, total

def check_project_structure():
    """Check overall project structure"""
    print("\n📁 Project Structure:")
    
    directories = [
        ("PanDerm", "Main app directory"),
        ("PanDerm/Views", "SwiftUI views"),
        ("PanDerm/ViewModels", "View models"),
        ("PanDerm/Models", "Data models"),
        ("PanDerm/Services", "Business logic services"),
        ("PanDerm/Assets.xcassets", "App assets"),
    ]
    
    passed = 0
    total = len(directories)
    
    for dir_path, description in directories:
        if os.path.exists(dir_path):
            print(f"✅ {dir_path}/ exists - {description}")
            passed += 1
        else:
            print(f"❌ {dir_path}/ not found - {description}")
    
    return passed, total

def check_documentation():
    """Check for documentation files"""
    print("\n📚 Documentation:")
    
    docs = [
        ("README.md", "Project overview"),
        ("PanDerm/README.md", "App documentation"),
        ("DATASET_SPECIFICATION.md", "Dataset requirements"),
        ("LOCAL_INFERENCE_IMPLEMENTATION_PLAN.md", "Implementation plan"),
        ("IMMEDIATE_IMPLEMENTATION_GUIDE.md", "Implementation guide"),
    ]
    
    passed = 0
    total = len(docs)
    
    for file_path, description in docs:
        if check_file_exists(file_path, description):
            passed += 1
    
    return passed, total

def analyze_code_quality():
    """Analyze code quality indicators"""
    print("\n🔍 Code Quality Analysis:")
    
    quality_indicators = []
    
    # Check for MVVM architecture
    if (os.path.exists("PanDerm/ViewModels/PatientViewModel.swift") and 
        os.path.exists("PanDerm/Views/PatientListView.swift") and
        os.path.exists("PanDerm/Models/Patient.swift")):
        quality_indicators.append("✅ MVVM Architecture implemented")
    else:
        quality_indicators.append("❌ MVVM Architecture incomplete")
    
    # Check for error handling
    if os.path.exists("PanDerm/Services/LocalInferenceService.swift"):
        with open("PanDerm/Services/LocalInferenceService.swift", 'r') as f:
            content = f.read()
            if "LocalInferenceError" in content and "do {" in content and "catch" in content:
                quality_indicators.append("✅ Error handling implemented")
            else:
                quality_indicators.append("❌ Error handling needs improvement")
    
    # Check for data persistence
    if os.path.exists("PanDerm/ViewModels/PatientViewModel.swift"):
        with open("PanDerm/ViewModels/PatientViewModel.swift", 'r') as f:
            content = f.read()
            if "UserDefaults" in content or "savePatients" in content:
                quality_indicators.append("✅ Data persistence implemented")
            else:
                quality_indicators.append("❌ Data persistence needs implementation")
    
    # Check for modern SwiftUI practices
    if os.path.exists("PanDerm/Views/ImageAnalysisView.swift"):
        with open("PanDerm/Views/ImageAnalysisView.swift", 'r') as f:
            content = f.read()
            if "@EnvironmentObject" in content and "@StateObject" in content:
                quality_indicators.append("✅ Modern SwiftUI practices used")
            else:
                quality_indicators.append("❌ SwiftUI practices need improvement")
    
    for indicator in quality_indicators:
        print(f"  {indicator}")
    
    passed = len([i for i in quality_indicators if i.startswith("✅")])
    total = len(quality_indicators)
    
    return passed, total

def main():
    """Main validation function"""
    print("🚀 PanDerm Implementation Validation")
    print("=" * 50)
    
    # Run all checks
    results = []
    
    # Check Swift files
    swift_passed, swift_total = check_swift_files()
    results.append(("Swift Implementation", swift_passed, swift_total))
    
    # Check Core ML models
    ml_passed, ml_total = check_core_ml_models()
    results.append(("Core ML Models", ml_passed, ml_total))
    
    # Check project structure
    structure_passed, structure_total = check_project_structure()
    results.append(("Project Structure", structure_passed, structure_total))
    
    # Check documentation
    docs_passed, docs_total = check_documentation()
    results.append(("Documentation", docs_passed, docs_total))
    
    # Check code quality
    quality_passed, quality_total = analyze_code_quality()
    results.append(("Code Quality", quality_passed, quality_total))
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 Validation Summary:")
    
    total_passed = 0
    total_checks = 0
    
    for category, passed, total in results:
        percentage = (passed / total * 100) if total > 0 else 0
        status = "✅ PASS" if percentage >= 80 else "⚠️  PARTIAL" if percentage >= 50 else "❌ FAIL"
        print(f"  {category}: {passed}/{total} ({percentage:.1f}%) {status}")
        total_passed += passed
        total_checks += total
    
    overall_percentage = (total_passed / total_checks * 100) if total_checks > 0 else 0
    print(f"\n🎯 Overall: {total_passed}/{total_checks} ({overall_percentage:.1f}%)")
    
    if overall_percentage >= 80:
        print("🎉 Implementation is ready for testing!")
        print("\n✅ Next Steps:")
        print("1. Open PanDerm.xcodeproj in Xcode")
        print("2. Add Core ML models to the project bundle")
        print("3. Configure signing and capabilities")
        print("4. Build and test on device")
        print("5. Test image analysis functionality")
        return True
    elif overall_percentage >= 50:
        print("⚠️  Implementation is partially complete")
        print("\n🔧 Action Items:")
        print("1. Complete missing components")
        print("2. Add Core ML models")
        print("3. Test critical functionality")
        return False
    else:
        print("❌ Implementation needs significant work")
        print("\n🚨 Critical Issues:")
        print("1. Many core files are missing")
        print("2. Review implementation plan")
        print("3. Complete basic structure first")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)