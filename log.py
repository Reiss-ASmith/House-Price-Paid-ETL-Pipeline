import logging
from pathlib import Path

def setup_logging(level: str = "INFO"):
    log_dir = Path("./logs")
    log_dir.mkdir(exist_ok=True)

    logging.basicConfig(
        level=getattr(logging, level.upper(), logging.INFO),
        format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler(log_dir / "pipeline.log", encoding="utf-8"),
        ],
    )