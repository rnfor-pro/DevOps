#!/bin/bash
NAMESPACE="np-keyston"
OUTPUT_FILE="obervability_tools_versions.json"
echo "collecting tool versions for observability statefulsets in namespace: $NAMESPACE"
echo "{" > "$OUTPUT_FILE"
statefulsets=(
    "grafana-statefulset"
    "np-loki-chunks-cache"
    "np-loki-compactor"
    "np-loki-index-gateway"
    "np-loki-ingester-zone-a"
    "np-loki-ingester-zone-b"
    "np-loki-ingester-zone-c"
    "np-loki-results-cache"
    "np-loki-ruler"
    "np-redpanda"
    "np-tempo-ingester"
    "np-tempo-memcached"
    "np-victoriametrics-victoria-metrics-single-server"
)

for i in "${!statefulsets[@]}"; do
statefulset="${statefulsets[$i]}"
IMAGE=$(kubectl get statefulset "$statefulset" -n "NAMESPACE" -o jsonpath='{.spec.template.spec.containers[*].image}' 2> /dev/null)
if [ -n "$IMAGE"]; then

#extract the version tag from the image (everything after colon)
VERSION=$(echo "$IMAGE" | awk -F: '{if (NF>1) print $NF; else print "latest"}')

else
   IMAGE="Not Found"

   VERSION="Not Found"

fi 

#Add comma only if it's not the latest element

if [ "$i" -lt $((${#statefulsets[@]} - 1))]; then 
  COMMA=","

else 
  COMMA=""

fi 

cat <<EOF >>"$OUTPUT_FILE"

   {
     "statefulset": "$statefulset",

     "image": "$IMAGE"
     "version": "$VERSION"
   }$COMMA

 EOF

done

echo " ]" >> "OUTPUT_FILE"
echo " }" >> "OUTPUT_FILE"

echo "Tool versions have been consolidated into $OUTPUT_FILE"
