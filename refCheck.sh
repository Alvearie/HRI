#!/bin/bash

# print out all the images not referenced in any of the markdown files in the base directory.
echo "Checking for images that are not being used"

images=$(ls documentation/images/)

for image in $images; do
  if ! grep $image documentation/*.md &> /dev/null; then
    echo "$image is not being used"
  fi
done

echo ""
echo "Checking for markdown references to files that don't exist"
# Find references that don't point to a file
imageRefs=$(grep -Eoh '[a-zA-Z0-9:\/_\.-]+\.md|images/[a-zA-Z0-9\/_\.-]+' documentation/*.md)

for ref in $imageRefs; do
  if [[ $ref == http* ]]; then 
    #skip web references
    continue
  elif ! ls documentation/$ref &> /dev/null; then
    printf "\n*********************************************************\n"
    echo "$ref does not exist. Listing occurances..."
    grep -n "$ref" *.md | sed 's/^/    /'
#  else
#    echo "$ref is good"
  fi
done

