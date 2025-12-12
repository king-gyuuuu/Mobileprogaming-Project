import argparse
import os
import platform
import subprocess
import zipfile

def run_command(command):
    try:
        result = subprocess.run(command, capture_output=True, text=True, shell=True)
        return result.stdout
    except Exception as e:
        return str(e)

def get_os_info():
    return f"OS: {platform.system()} {platform.release()}"

def get_flutter_info():
    return run_command("flutter --version")

def get_firebase_info():
    # This is a placeholder. In a real scenario, you might check for config files
    # or specific dependencies.
    firebase_files = ["android/app/google-services.json", "ios/Runner/GoogleService-Info.plist"]
    found_files = [f for f in firebase_files if os.path.exists(f)]
    return f"Firebase config files found: {found_files}"

def get_dependencies_info():
    return run_command("flutter pub deps")

def zip_project(zip_name):
    with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk('.'):
            # Ignore certain directories
            dirs[:] = [d for d in dirs if d not in ['.git', '.idea', 'build', '.dart_tool', 'diagnostics']]
            for file in files:
                zipf.write(os.path.join(root, file))

def run_diagnostics(zip_project_flag):
    print("--- OS Information ---")
    print(get_os_info())
    print("\n--- Flutter Information ---")
    print(get_flutter_info())
    print("\n--- Firebase Information ---")
    print(get_firebase_info())
    print("\n--- Dependencies Information ---")
    print(get_dependencies_info())

    if zip_project_flag:
        print("\n--- Zipping Project ---")
        zip_name = "project.zip"
        zip_project(zip_name)
        print(f"Project zipped as {zip_name}")

def main():
    parser = argparse.ArgumentParser(description="Run diagnostics for the Flutter project.")
    parser.add_argument("--zip", action="store_true", help="Zip the project files.")
    args = parser.parse_args()

    run_diagnostics(args.zip)

if __name__ == "__main__":
    main()
