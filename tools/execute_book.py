"""Execute each R notebook in a separate clean kernel, using the project root."""
from pathlib import Path
import importlib.metadata
import json
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
for key, suffix in {"JUPYTER_CONFIG_DIR": "config", "JUPYTER_DATA_DIR": "data",
                    "JUPYTER_RUNTIME_DIR": "runtime", "IPYTHONDIR": "ipython"}.items():
    folder = ROOT / ".jupyter" / suffix
    folder.mkdir(parents=True, exist_ok=True)
    os.environ[key] = str(folder)
os.environ["PATH"] = str(Path(sys.executable).parent) + os.pathsep + os.environ["PATH"]
if (ROOT / ".R-library").exists():
    os.environ["R_LIBS_USER"] = str(ROOT / ".R-library")

import nbformat
from nbclient import NotebookClient
from assemble_notebooks import LESSONS, assemble


def main():
    expression = f'IRkernel::installspec(prefix={json.dumps(sys.prefix)}, name="ir", displayname="R (microbial ML)")'
    subprocess.run(["Rscript", "--vanilla", "-e", expression], cwd=ROOT, check=True)
    assemble()
    rows = []
    for name in LESSONS:
        file = ROOT / "chapters" / f"{name}.ipynb"
        notebook = nbformat.read(file, as_version=4)
        NotebookClient(notebook, kernel_name="ir", timeout=120,
                       record_timing=False, allow_errors=False,
                       resources={"metadata": {"path": str(ROOT)}}).execute()
        nbformat.write(notebook, file)
        code = [cell for cell in notebook.cells if cell.cell_type == "code"]
        assert all(cell.execution_count is not None for cell in code)
        assert not any(out.output_type == "error" for cell in code for out in cell.outputs)
        rows.append({"notebook": file.name, "executed_code_cells": len(code), "unhandled_errors": 0})
        print(f"Executed {file.name}: {len(code)} R cells, zero unhandled errors", flush=True)
    validation = ROOT / "validation"
    validation.mkdir(exist_ok=True)
    info = {"separate_fresh_kernel_per_notebook": True, "notebooks": rows,
            "versions": {p: importlib.metadata.version(p) for p in ["jupyter-book", "nbformat", "nbclient", "jupyter-client"]}}
    (validation / "notebook-execution.json").write_text(json.dumps(info, indent=2))


if __name__ == "__main__":
    main()
