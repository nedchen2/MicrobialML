"""Assemble lessons from prose plus named cells in the canonical R scripts."""
from pathlib import Path
import hashlib
import re
import nbformat

ROOT = Path(__file__).resolve().parents[1]
REAL_STAGES = {
    "05-meet-real-data": ["source", "raw-preview", "assays", "select", "quality",
                          "usable-preview", "target", "log-intuition", "prepare-audit", "save-prepared"],
    "06-split-farms": ["load-prepared", "split", "overlap", "save-split"],
    "07-baseline": ["load-split", "baseline", "baseline-scale", "metrics", "independent", "sensitivity",
                    "save", "plot", "audit-save"],
}
TREE_STAGES = {
    "08-first-tree": ["tree-load", "hand-tree", "survey-source", "predictor-audit", "save-tree-input"],
    "09-choose-tree": ["load-tree-input", "tree-formula", "training-folds", "validate-depth",
                        "choose-depth", "fit-tree", "training-check", "save-tree-fit"],
    "10-test-tree": ["load-tree-fit", "predict-tree", "tree-test-scores", "check-leaves",
                      "trace-one", "save-tree-results", "new-samples", "plot-tree"],
}
WORKFLOWS = {"worked-example.R": REAL_STAGES, "tree-workflow.R": TREE_STAGES}
LESSONS = ["01-first-run", "02-minimum-r", "03-working-with-ai", "04-small-farm-example", *REAL_STAGES, *TREE_STAGES]

# Supplied operational code can be inspected on demand. Scientific rules and
# their outputs remain in the lesson; these tags never skip execution.
CELL_DISPLAY = {
    "02-minimum-r": {"export": ["hide-input"], "exercise-copy": ["hide-input"],
                      "exercise-check": ["hide-input"]},
    "03-working-with-ai": {"runtime-error": ["hide-input"],
                           "verify-repair": ["hide-input"], "save-evidence": ["hide-input"]},
    "04-small-farm-example": {"toy-guess": ["hide-input"], "toy-errors": ["hide-input"],
                             "toy-leakage": ["hide-input"], "toy-wrong-split": ["hide-input"],
                             "toy-save": ["hide-input"]},
    "05-meet-real-data": {"source": ["hide-input"], "assays": ["hide-input", "hide-output"], "log-intuition": ["hide-input"],
                          "prepare-audit": ["hide-input"], "save-prepared": ["hide-input"]},
    "06-split-farms": {"load-prepared": ["hide-input"], "split": ["hide-input"],
                       "save-split": ["hide-input"]},
    "07-baseline": {"load-split": ["hide-input"], "baseline-scale": ["hide-input"], "independent": ["hide-input"],
                    "sensitivity": ["hide-input", "hide-output"], "save": ["hide-input"],
                    "plot": ["hide-input"], "audit-save": ["hide-input"]},
    "08-first-tree": {"tree-load": ["hide-input"], "hand-tree": ["hide-input"],
                       "survey-source": ["hide-input"], "predictor-audit": ["hide-input"], "save-tree-input": ["hide-input"]},
    "09-choose-tree": {"load-tree-input": ["hide-input"], "training-folds": ["hide-input"],
                        "validate-depth": ["hide-input", "hide-output"], "choose-depth": ["hide-input"],
                        "training-check": ["hide-input"], "save-tree-fit": ["hide-input"]},
    "10-test-tree": {"load-tree-fit": ["hide-input"], "check-leaves": ["hide-input"],
                      "trace-one": ["hide-input"], "save-tree-results": ["hide-input"], "plot-tree": ["hide-input"]},
}


def read_cells(path):
    cells = {}
    current = None
    for line in path.read_text().splitlines():
        match = re.fullmatch(r"# %% (\S+)", line)
        if match:
            current = match.group(1)
            if current in cells:
                raise ValueError(f"Duplicate code cell {current}")
            cells[current] = []
        elif current:
            cells[current].append(line)
    return {key: "\n".join(lines).strip() for key, lines in cells.items()}


def assemble():
    for workflow, stages in WORKFLOWS.items():
        full = read_cells(ROOT / "scripts" / workflow)
        assert [key for keys in stages.values() for key in keys] == list(full), "Stages must partition the complete workflow in order"
        for name, keys in stages.items():
            script = f"# Generated from {workflow} for Chapter {name[:2]}; edit that canonical source as author.\n"
            script += "# Students: save a working copy as my-" + name + ".R; follow the matching page.\n"
            for key in keys:
                script += f"# %% {key}\n{full[key]}\n"
            (ROOT / "scripts" / f"{name}.R").write_text(script)
    for name in LESSONS:
        target = ROOT / "chapters" / f"{name}.ipynb"
        previous = nbformat.read(target, as_version=4) if target.exists() else None
        cached = {cell.id: cell for cell in previous.cells} if previous else {}
        prose = (ROOT / "authoring" / f"{name}.md").read_text()
        code = read_cells(ROOT / "scripts" / f"{name}.R")
        parts = re.split(r"\{\{r:([^}]+)\}\}", prose)
        cells = []
        used = []
        for i, part in enumerate(parts):
            if i % 2:
                if part not in code:
                    raise ValueError(f"Missing R cell {name}:{part}")
                cell = nbformat.v4.new_code_cell(code[part])
                tags = CELL_DISPLAY.get(name, {}).get(part, [])
                if tags:
                    cell.metadata["tags"] = tags
                used.append(part)
            else:
                if not part.strip():
                    continue
                cell = nbformat.v4.new_markdown_cell(part.strip())
            cell.id = hashlib.sha256(f"{name}:{i}:{part[:40]}".encode()).hexdigest()[:12]
            old = cached.get(cell.id)
            if old and cell.cell_type == "code" and old.cell_type == "code" and old.source == cell.source:
                cell.outputs = old.outputs
                cell.execution_count = old.execution_count
            cells.append(cell)
        if set(used) != set(code) or len(used) != len(code):
            raise ValueError(f"Code/prose cell mapping is not one-to-one for {name}")
        assert set(CELL_DISPLAY.get(name, {})) <= set(code), "Unknown cell visibility setting"
        notebook = nbformat.v4.new_notebook(cells=cells, metadata={
            "kernelspec": {"name": "ir", "display_name": "R", "language": "R"},
            "language_info": {"name": "R", "file_extension": ".r", "mimetype": "text/x-r-source"},
        })
        nbformat.write(notebook, target)
        print(f"Assembled {target.name}: {len(code)} executable R cells")


if __name__ == "__main__":
    assemble()
