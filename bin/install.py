#!/usr/bin/env python3

import os
import platform
from urllib import request
from zipfile import ZipFile
import psutil
import re as regex
from io import BytesIO
from json import load as load_json

# get OS related information
os_name = None

if psutil.MACOS == True:
    os_name = "mac"
elif psutil.LINUX == True:
    os_name = "linux"
else:
    print(f"Operating system is not supported.")
    exit(1)

# get CPU information
original_cpu_architecture = platform.processor()
supported_architectures = dict({
    "x86_64": "x64",
    "arm": "arm",
    "armv*": "arm",
    "aarch*": "arm"
})

cpu_architecture = None
for key in supported_architectures.keys():
    # already detected. skip others
    if cpu_architecture is not None:
        continue
    if key == original_cpu_architecture or regex.match(key, original_cpu_architecture) == True:
        cpu_architecture = supported_architectures[key]

if cpu_architecture is None:
    print(f"CPU architecture of {original_cpu_architecture} is not supported.")
    exit(1)

# get latest release version
print(f"Finding the latest version...")
release_api_response = request.urlopen(url="https://api.github.com/repos/getignore/getignore/releases/latest")

if release_api_response.status < 200 or release_api_response.status > 299:
    print(f"Failed to communicate with GitHub release API.")
    print(release_api_response.read())
    exit(2)

release_api_result_json = load_json(release_api_response)
latest_version = release_api_result_json['tag_name']

# download os-specific artifact file
print(f"Downloading artifact '{latest_version}' for {os_name}_{cpu_architecture} ...")
artifact_url = f"https://github.com/GetIgnore/getignore/releases/download/{latest_version}/getignore-{os_name}_{cpu_architecture}.zip"
artifact_api_response = request.urlopen(url=artifact_url)

if artifact_api_response.status < 200 or artifact_api_response.status > 299:
    print(f"Failed to download artifact from '{artifact_url}'")
    print(artifact_api_response.read())
    exit(2)

# extract artifact to the OS-specific bin directory
os_bin_dir = dict({
    "linux": os.path.join("~/", "usr", "local", "bin"),
    "mac": os.path.join("~"),
})

extract_target_path = os_bin_dir.get(os_name)

print(f"Extracting artifact to '{extract_target_path}' ...")
with ZipFile(BytesIO(artifact_api_response.read()), mode='r') as zipFile:
    zipFile.extractall(path=extract_target_path)
    
    # make the code executable
    exec_file_path = os.path.join(extract_target_path, "getignore")
    os.system(f"chmod +x {exec_file_path}")

print("Done!")
