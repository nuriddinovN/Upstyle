import sys
import platform
import mindspore
from mindspore import context

def display_mindspore_info():
    """
    Checks and displays detailed information about the MindSpore installation,
    Python environment, and current MindSpore context settings.
    """
    print("=" * 50)
    print(" MindSpore Installation and Environment Check")
    print("=" * 50)

    # 1. MindSpore Version
    try:
        ms_version = mindspore.__version__
        print(f"MindSpore Version: {ms_version}")
    except Exception as e:
        print(f"ERROR: Failed to retrieve MindSpore version. {e}")
        return

    # 2. Python Environment Details
    print("\n--- Python Environment ---")
    print(f"Python Executable: {sys.executable}")
    print(f"Python Version: {sys.version.splitlines()[0]}")
    print(f"Operating System: {platform.system()} {platform.release()} ({platform.machine()})")

    # 3. MindSpore Context/Device
    print("\n--- MindSpore Runtime Context ---")
    try:
        # Get the default configuration (usually CPU if not explicitly set)
        current_context = context.get_context()
        
        # Note: MindSpore's context is often configured before running a model.
        # This shows the current default/configured settings.

        # Safely try to access commonly configured parameters
        device_target = current_context.get('device_target', 'Not Configured (Default)')
        print(f"Device Target (Backend): {device_target}")

        if device_target.lower() in ['gpu', 'ascend']:
            device_id = current_context.get('device_id', 'N/A')
            print(f"Device ID: {device_id}")

        mode = "GRAPH_MODE (0)" if current_context.get('mode') == context.GRAPH_MODE else \
               "PYNATIVE_MODE (1)" if current_context.get('mode') == context.PYNATIVE_MODE else \
               f"Unknown ({current_context.get('mode')})"
        print(f"Execution Mode: {mode}")

    except Exception as e:
        print(f"WARNING: Could not retrieve MindSpore context details (e.g., no context set). Error: {e}")
    
    print("=" * 50)
    print("Check complete. If Device Target shows 'Not Configured (Default)',")
    print("MindSpore is using its default (often CPU).")
    print("=" * 50)


if __name__ == "__main__":
    display_mindspore_info()
