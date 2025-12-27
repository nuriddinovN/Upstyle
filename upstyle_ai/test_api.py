#!/usr/bin/env python3
"""
FashionCLIP API Testing Script
Tests deployed API and shows detailed analytics
"""

import requests
import json
import time
import os
from pathlib import Path
from datetime import datetime
import sys

# ==================== CONFIGURATION ====================
API_URL = "https://fashionclip-api-ghrly4qhta-uc.a.run.app"
TEST_IMAGE_PATH = "/home/noor/A/projects/Upstyle/upstyle_ai/clothes_data/imgs/clothes8.jpg"

# ==================== HELPER FUNCTIONS ====================

def print_header(text):
    """Print formatted section header"""
    print("\n" + "=" * 70)
    print(f"  {text}")
    print("=" * 70)

def print_subheader(text):
    """Print formatted subsection header"""
    print(f"\n--- {text} ---")

def format_time(seconds):
    """Format time in human-readable format"""
    if seconds < 1:
        return f"{seconds * 1000:.2f}ms"
    return f"{seconds:.2f}s"

def format_size(bytes):
    """Format file size"""
    kb = bytes / 1024
    if kb < 1024:
        return f"{kb:.2f} KB"
    return f"{kb / 1024:.2f} MB"

# ==================== TEST FUNCTIONS ====================

def test_health_check():
    """Test 1: Health check endpoint"""
    print_subheader("Health Check")
    
    try:
        start = time.time()
        response = requests.get(f"{API_URL}/health", timeout=10)
        elapsed = time.time() - start
        
        print(f"✅ Status Code: {response.status_code}")
        print(f"⏱️  Response Time: {format_time(elapsed)}")
        print(f"📦 Response: {response.json()}")
        
        if response.status_code == 200:
            return True, elapsed
        return False, elapsed
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False, 0

def test_root_endpoint():
    """Test 2: Root endpoint"""
    print_subheader("Root Endpoint Check")
    
    try:
        start = time.time()
        response = requests.get(f"{API_URL}/", timeout=10)
        elapsed = time.time() - start
        
        print(f"✅ Status Code: {response.status_code}")
        print(f"⏱️  Response Time: {format_time(elapsed)}")
        print(f"📦 Response: {json.dumps(response.json(), indent=2)}")
        
        return response.status_code == 200, elapsed
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False, 0

def test_image_analysis(image_path):
    """Test 3: Image analysis endpoint"""
    print_subheader("Image Analysis Test")
    
    # Validate image exists
    if not os.path.exists(image_path):
        print(f"❌ Image not found: {image_path}")
        return False, 0, None
    
    file_size = os.path.getsize(image_path)
    print(f"📸 Image: {os.path.basename(image_path)}")
    print(f"📏 Size: {format_size(file_size)}")
    
    try:
        # Upload image
        print(f"\n🚀 Uploading to {API_URL}/analyze...")
        
        with open(image_path, 'rb') as f:
            files = {'file': (os.path.basename(image_path), f, 'image/jpeg')}
            
            start = time.time()
            response = requests.post(
                f"{API_URL}/analyze",
                files=files,
                timeout=60
            )
            elapsed = time.time() - start
        
        print(f"\n✅ Status Code: {response.status_code}")
        print(f"⏱️  Total Response Time: {format_time(elapsed)}")
        print(f"📊 Response Size: {format_size(len(response.content))}")
        
        if response.status_code == 200:
            result = response.json()
            return True, elapsed, result
        else:
            print(f"❌ Error Response: {response.text}")
            return False, elapsed, None
            
    except requests.exceptions.Timeout:
        print(f"❌ Request timed out after 60s")
        return False, 60, None
    except Exception as e:
        print(f"❌ Error: {e}")
        return False, 0, None

def analyze_results(result):
    """Analyze and display fashion attributes"""
    print_header("FASHION ANALYSIS RESULTS")
    
    if not result:
        print("❌ No results to analyze")
        return
    
    # Basic info
    print(f"\n🆔 Analysis ID: {result.get('id', 'N/A')}")
    print(f"📁 Filename: {result.get('filename', 'N/A')}")
    print(f"✅ Status: {result.get('status', 'N/A')}")
    
    # Core attributes
    print_subheader("Core Attributes")
    
    core_attrs = ['category', 'sub_category', 'gender', 'style', 'occasion']
    for attr in core_attrs:
        if attr in result:
            data = result[attr]
            value = data.get('value', 'N/A')
            conf = data.get('confidence', 0) * 100
            print(f"  • {attr.replace('_', ' ').title()}: {value} ({conf:.1f}% confidence)")
    
    # Colors
    print_subheader("Colors")
    color_attrs = ['primary_color', 'secondary_color', 'accent_color']
    for attr in color_attrs:
        if attr in result:
            data = result[attr]
            value = data.get('value', 'N/A')
            conf = data.get('confidence', 0) * 100
            print(f"  • {attr.replace('_', ' ').title()}: {value} ({conf:.1f}% confidence)")
    
    # Design details
    print_subheader("Design Details")
    design_attrs = ['pattern', 'material', 'fit', 'neckline', 'sleeve', 'length']
    for attr in design_attrs:
        if attr in result:
            data = result[attr]
            value = data.get('value', 'N/A')
            conf = data.get('confidence', 0) * 100
            print(f"  • {attr.replace('_', ' ').title()}: {value} ({conf:.1f}% confidence)")
    
    # Sustainability
    print_subheader("Sustainability Metrics")
    sust_attrs = ['upcycling_potential', 'repairability', 'sustainability']
    for attr in sust_attrs:
        if attr in result:
            data = result[attr]
            value = data.get('value', 'N/A')
            conf = data.get('confidence', 0) * 100
            print(f"  • {attr.replace('_', ' ').title()}: {value} ({conf:.1f}% confidence)")
    
    # All other attributes
    print_subheader("Additional Attributes")
    
    displayed = set(core_attrs + color_attrs + design_attrs + sust_attrs + ['id', 'filename', 'status'])
    other_attrs = [k for k in result.keys() if k not in displayed]
    
    for attr in sorted(other_attrs):
        data = result[attr]
        if isinstance(data, dict):
            value = data.get('value', 'N/A')
            conf = data.get('confidence', 0) * 100
            print(f"  • {attr.replace('_', ' ').title()}: {value} ({conf:.1f}% confidence)")

def calculate_confidence_stats(result):
    """Calculate confidence statistics"""
    print_header("CONFIDENCE STATISTICS")
    
    if not result:
        print("❌ No results to analyze")
        return
    
    confidences = []
    
    for key, value in result.items():
        if isinstance(value, dict) and 'confidence' in value:
            confidences.append((key, value['confidence']))
    
    if not confidences:
        print("❌ No confidence scores found")
        return
    
    # Sort by confidence
    confidences.sort(key=lambda x: x[1], reverse=True)
    
    # Calculate stats
    conf_values = [c[1] for c in confidences]
    avg_conf = sum(conf_values) / len(conf_values)
    min_conf = min(conf_values)
    max_conf = max(conf_values)
    
    print(f"\n📊 Total Attributes Analyzed: {len(confidences)}")
    print(f"📈 Average Confidence: {avg_conf * 100:.2f}%")
    print(f"🔝 Highest Confidence: {max_conf * 100:.2f}%")
    print(f"🔻 Lowest Confidence: {min_conf * 100:.2f}%")
    
    # Top 5 most confident predictions
    print(f"\n🏆 Top 5 Most Confident Predictions:")
    for i, (attr, conf) in enumerate(confidences[:5], 1):
        print(f"  {i}. {attr.replace('_', ' ').title()}: {conf * 100:.2f}%")
    
    # Bottom 5 least confident predictions
    print(f"\n⚠️  Top 5 Least Confident Predictions:")
    for i, (attr, conf) in enumerate(confidences[-5:], 1):
        print(f"  {i}. {attr.replace('_', ' ').title()}: {conf * 100:.2f}%")
    
    # Confidence distribution
    print(f"\n📊 Confidence Distribution:")
    high = sum(1 for c in conf_values if c >= 0.8)
    medium = sum(1 for c in conf_values if 0.5 <= c < 0.8)
    low = sum(1 for c in conf_values if c < 0.5)
    
    print(f"  • High (≥80%):   {high} attributes ({high/len(conf_values)*100:.1f}%)")
    print(f"  • Medium (50-80%): {medium} attributes ({medium/len(conf_values)*100:.1f}%)")
    print(f"  • Low (<50%):    {low} attributes ({low/len(conf_values)*100:.1f}%)")

def save_results(result, elapsed_time):
    """Save test results to JSON file"""
    print_subheader("Saving Results")
    
    if not result:
        print("❌ No results to save")
        return
    
    # Create output directory
    output_dir = Path("api_test_results")
    output_dir.mkdir(exist_ok=True)
    
    # Generate filename with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = output_dir / f"test_result_{timestamp}.json"
    
    # Add metadata
    output_data = {
        "test_metadata": {
            "api_url": API_URL,
            "test_time": datetime.now().isoformat(),
            "response_time_seconds": elapsed_time,
            "image_path": TEST_IMAGE_PATH
        },
        "analysis_result": result
    }
    
    # Save to file
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Results saved to: {filename}")
    print(f"📝 File size: {format_size(os.path.getsize(filename))}")

def test_multiple_requests():
    """Test 4: Multiple requests performance"""
    print_header("MULTIPLE REQUESTS TEST")
    
    num_requests = 3
    print(f"🔄 Sending {num_requests} health check requests...\n")
    
    times = []
    for i in range(num_requests):
        try:
            start = time.time()
            response = requests.get(f"{API_URL}/health", timeout=10)
            elapsed = time.time() - start
            times.append(elapsed)
            
            status = "✅" if response.status_code == 200 else "❌"
            print(f"  Request {i+1}: {status} {format_time(elapsed)}")
            
            time.sleep(0.5)  # Small delay between requests
            
        except Exception as e:
            print(f"  Request {i+1}: ❌ Error: {e}")
            times.append(0)
    
    if times:
        avg_time = sum(times) / len(times)
        min_time = min(times)
        max_time = max(times)
        
        print(f"\n📊 Statistics:")
        print(f"  • Average: {format_time(avg_time)}")
        print(f"  • Fastest: {format_time(min_time)}")
        print(f"  • Slowest: {format_time(max_time)}")

# ==================== MAIN TEST RUNNER ====================

def main():
    """Run all tests"""
    print("=" * 70)
    print("  🧪 FashionCLIP API Testing Suite")
    print("=" * 70)
    print(f"📍 API URL: {API_URL}")
    print(f"📸 Test Image: {TEST_IMAGE_PATH}")
    print(f"🕐 Test Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Track overall results
    all_tests_passed = True
    total_start = time.time()
    
    # Test 1: Health Check
    print_header("TEST 1: Health Check")
    passed, elapsed = test_health_check()
    all_tests_passed = all_tests_passed and passed
    
    # Test 2: Root Endpoint
    print_header("TEST 2: Root Endpoint")
    passed, elapsed = test_root_endpoint()
    all_tests_passed = all_tests_passed and passed
    
    # Test 3: Image Analysis (Main Test)
    print_header("TEST 3: Image Analysis")
    passed, elapsed, result = test_image_analysis(TEST_IMAGE_PATH)
    all_tests_passed = all_tests_passed and passed
    
    if passed and result:
        # Analyze results
        analyze_results(result)
        
        # Calculate statistics
        calculate_confidence_stats(result)
        
        # Save results
        print_header("SAVING RESULTS")
        save_results(result, elapsed)
    
    # Test 4: Multiple Requests
    test_multiple_requests()
    
    # Summary
    total_elapsed = time.time() - total_start
    
    print_header("TEST SUMMARY")
    status = "✅ ALL TESTS PASSED" if all_tests_passed else "❌ SOME TESTS FAILED"
    print(f"\n{status}")
    print(f"⏱️  Total Test Duration: {format_time(total_elapsed)}")
    print(f"🔗 API URL: {API_URL}")
    
    print("\n" + "=" * 70)
    
    return 0 if all_tests_passed else 1

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n\n⚠️  Test interrupted by user")
        sys.exit(130)
    except Exception as e:
        print(f"\n\n❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)