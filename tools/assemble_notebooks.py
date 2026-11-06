"""Assemble lessons from prose plus named cells in the canonical R scripts."""
from pathlib import Path
import hashlib
import re
import nbformat

ROOT = Path(__file__).resolve().parents[1]
LESSONS = ["01-first-run", "02-minimum-r", "03-working-with-ai", "worked-example"]


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
        notebook = nbformat.v4.new_notebook(cells=cells, metadata={
            "kernelspec": {"name": "ir", "display_name": "R", "language": "R"},
            "language_info": {"name": "R", "file_extension": ".r", "mimetype": "text/x-r-source"},
        })
        nbformat.write(notebook, target)
        print(f"Assembled {target.name}: {len(code)} executable R cells")


if __name__ == "__main__":
    assemble()
