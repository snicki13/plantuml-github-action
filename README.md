# PlantUML GitHub action

This action runs the [PlantUML](https://plantuml.com/) tool to generate images from PlantUML text diagrams.

## Inputs

### `args`

**Required** The arguments for PlantUML tool. Default `"-h"`.

## Outputs


## Example usage

This is an an example of a workflow which generates the svg and png images from PlantUML text digram. It will
trigger every time there is a change in a `puml` file.

`.github/worksflows/main.yml`:

```yaml
name: Generate PlantUML Diagrams
on:
  push:
    paths:
      - '**.puml'
    branches:
      - master
jobs:
  ci:
    runs-on: ubuntu-latest
    env:
        UML_FILES: "diagrams/*.puml"
    steps:
      - name: Checkout Source 
        uses: actions/checkout@v1
      - name: Generate SVG Diagrams
        uses: cloudbees/plantuml-github-action@master
        with:
            args: -v -tsvg $UML_FILES
      - name: Get changed UML files
        id: getfile
        run: |
          echo "::set-output name=files::$(git diff-tree -r --no-commit-id --name-only ${{ github.sha }} | grep ${{ env.UML_FILES }} | xargs)"
      - name: UML files considered echo output
        run: |
          echo ${{ steps.getfile.outputs.files }}
      - name: Generate PNG Diagrams
        uses: cloudbees/plantuml-github-action@master
        with:
            args: -v -tpng $UML_FILES
      - name: Push Local Changes
        uses:  stefanzweifel/git-auto-commit-action@v4.1.2 
        with: 
          commit_user_name: "my user name"
          commit_user_email: "me@email.org"
          commit_author: "My User <me@email.org>"
          commit_message: "Generate SVG and PNG images for PlantUML diagrams" 
          branch: ${{ github.head_ref }}
```

The last setp will commit the generated images back into the master branch.
