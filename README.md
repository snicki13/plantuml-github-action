# PlantUML GitHub action

This action runs the [PlantUML](https://plantuml.com/) tool to generate images from PlantUML text diagrams.

## Inputs

### `args`

**Required** The arguments for PlantUML tool. Default `"-h"`.

## Outputs


## Example usage

This is an workflow example which generates the svg and png images from PlantUML digrams.

`.github/worksflows/main.yml`:

```yaml
name: Generate PlantUML Diagrams
on:
  push:
    branches:
      - master
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source 
        uses: actions/checkout@v2
      - name: Checkout Master Branch
        run: git checkout master
      - name: Generate SVG Diagrams
        uses: cloudbees/plantuml-github-action@master
        with:
            args: -v -tsvg *.puml
      - name: Generate PNG Diagrams
        uses: cloudbees/plantuml-github-action@master
        with:
            args: -v -tpng *.puml
      - name: Push Local Changes
        env: 
          COMMIT_USERNAME: "My user name"
          COMMIT_EMAIL: "my-email@cloudbees.com"
          COMMIT_MESSAGE: "Generate SVG and PNG images for PlantUML diagrams" 
        run: |
          scripts/push-local-changes.sh
```

The script which commits the generated images into master can be found in [scripts](scripts/push-local-changes.sh) folder.
