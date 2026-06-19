"""Run the FastAPI app via the bundled `fastapi` CLI.

PORT is read from .env through Settings, so dev, prod, and Docker all share
one source of truth. Usage:
    python scripts/serve.py --dev   # fastapi dev (reload)
    python scripts/serve.py         # fastapi run (production)
"""

import argparse
import subprocess
import sys
from pathlib import Path

# Ensure the project root is importable when running `python scripts/serve.py`.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.config import get_settings  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser(description="Run the FastAPI app")
    parser.add_argument(
        "--dev",
        action="store_true",
        help="Enable auto-reload (dev mode)",
    )
    args = parser.parse_args()

    settings = get_settings()
    subcmd = "dev" if args.dev else "run"
    cmd = ["fastapi", subcmd, "main.py", "--port", str(settings.port)]
    return subprocess.run(cmd, check=True).returncode


if __name__ == "__main__":
    sys.exit(main())
