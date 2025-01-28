import subprocess
import sys
import json
import re
import requests
import time

# Function to dynamically install and import libraries
def install_and_import(package):
    try:
        __import__(package)
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
    finally:
        globals()[package] = __import__(package)

# Ensure 'requests' is installed
install_and_import("requests")

# Namespace and output file
NAMESPACES = ["prod-keystone", "np-keystone"]
OUTPUT_FILE = "observability_tools_versions.json"

# Tool-specific GitHub repositories
GITHUB_REPOS = {
    "grafana": "grafana/grafana",
    "loki": "grafana/loki",
    "redpanda": "redpanda-data/redpanda",
    "tempo": "grafana/tempo",
    "victoria-metrics": "VictoriaMetrics/VictoriaMetrics",
    "memcached": "memcached/memcached",
    "memcached_exporter": "prometheus/memcached_exporter",
    "opentelemetry-collector": "open-telemetry/opentelemetry-collector"
}

# Function to get the latest version from GitHub API based on repository path
def get_latest_version(repo, retries=3):
    headers = {"User-Agent": "k8s-tool-version-checker"}
    if repo == "memcached/memcached":
        # Special case for Memcached: Fetch the latest tag
        url = f"https://api.github.com/repos/{repo}/tags"
    else:
        url = f"https://api.github.com/repos/{repo}/releases/latest"

    for attempt in range(retries):
        try:
            response = requests.get(url, headers=headers)
            response.raise_for_status()
            data = response.json()
            if repo == "memcached/memcached":
                return extract_semver(data[0].get("name", "Unknown")) if data else "Unknown"
            return extract_semver(data.get("tag_name", "Unknown"))
        except requests.exceptions.RequestException as e:
            if response.status_code == 403 and "X-RateLimit-Reset" in response.headers:
                reset_time = int(response.headers["X-RateLimit-Reset"])
                wait_time = reset_time - int(time.time())
                print(f"\nRate limit hit. Waiting for {wait_time} seconds before retrying...")
                time.sleep(wait_time + 1)
            else:
                print(f"\nError fetching latest version for {repo}: {e}")
                time.sleep(2 ** attempt)  # Exponential backoff
    return "Unknown"

# Function to extract semantic versioning from a string
def extract_semver(version):
    match = re.search(r"v?\d+\.\d+\.\d+", version)
    return match.group(0) if match else "latest"

# Function to get images from a Kubernetes resource
def get_images(resource_type, namespace):
    try:
        output = subprocess.check_output(
            ["kubectl", "get", resource_type, "-n", namespace, "-o", "json"],
            stderr=subprocess.DEVNULL
        )
        data = json.loads(output)
        images = {}
        for item in data.get("items", []):
            name = item["metadata"]["name"]
            containers = item["spec"]["template"]["spec"]["containers"]
            images[name] = [container["image"] for container in containers]
        return images
    except subprocess.CalledProcessError:
        return {}

# Function to identify tool name and GitHub repo from an image
def identify_tool_and_repo(image, name):
    if "loki" in name and "cache" in name:
        tool_name = "memcached"
        repo = "memcached/memcached"
    elif "loki" in name:
        tool_name = "loki"
        repo = "grafana/loki"
    elif "docker.artifactory.sherwin.com/sherwin-williams-co" in image:
        tool_name = image.split('/')[2].split(':')[0]
        repo = "open-telemetry/opentelemetry-collector"
    elif "redpanda" in name:
        tool_name = "redpanda"
        repo = "redpanda-data/redpanda"
    elif "tempo" in name:
        tool_name = "tempo"
        repo = "grafana/tempo"
    elif "victoriametrics" in name:
        tool_name = "victoria-metrics"
        repo = "VictoriaMetrics/VictoriaMetrics"
    elif "otel" in name:
        tool_name = "opentelemetry-collector"
        repo = "open-telemetry/opentelemetry-collector"
    elif "grafana" in name:
        tool_name = "grafana"
        repo = "grafana/grafana"
    else:
        tool_name = image.split('/')[-1].split(':')[0]
        repo = "Unknown"

    return tool_name, repo

# Function to get current version from the image
def get_current_version(image):
    match = re.search(r":([^:]+)$", image)
    version = extract_semver(match.group(1)) if match else "latest"
    return "latest" if version == "latest" else version

# Function to display a progress bar
def show_progress(current, total):
    percent = int((current / total) * 100)
    bar = f"[{'=' * (percent // 2)}{' ' * (50 - percent // 2)}] {percent}%"
    print(f"\r{bar}", end='', flush=True)

def main():
    results = []
    processed_local_names = set()  # Keep track of which local_tool_name has been added to results

    for namespace in NAMESPACES:
        # Get StatefulSets and Deployments
        statefulset_images = get_images("statefulsets", namespace)
        deployment_images = get_images("deployments", namespace)

        all_images = list(statefulset_images.items()) + list(deployment_images.items())
        total = len(all_images)
        current = 0

        for name, images in all_images:
            # If we've already used this local_tool_name, skip it
            if name in processed_local_names:
                current += 1
                show_progress(current, total)
                continue

            # Process each container image in this resource
            for image in images:
                tool_name, github_repo = identify_tool_and_repo(image, name)
                current_version = get_current_version(image)
                latest_version = get_latest_version(github_repo) if github_repo != "Unknown" else "Not Found"

                # Append "-image-renderer" if the image contains "grafana-image-renderer"
                patched_name = name
                if "grafana-image-renderer" in image.lower():
                    patched_name += "-image-renderer"

                # ----------------------- NEW ADDITION HERE -----------------------
                # Append "-exporter" if the image contains "exporter"
                if "exporter" in image.lower():
                    patched_name += "-exporter"
                # ---------------------------------------------------------------

                results.append({
                    "namespace": namespace,
                    "local_tool_name": patched_name,
                    "tool_name": tool_name,
                    "current_version": current_version,
                    "latest_version": latest_version,
                    "image": image
                })

            # Mark this local_tool_name as processed after we've added it
            processed_local_names.add(name)
            current += 1
            show_progress(current, total)

    # Write results to a JSON file
    with open(OUTPUT_FILE, "w") as f:
        json.dump(results, f, indent=2)

    print(f"\nTool versions have been consolidated into {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
