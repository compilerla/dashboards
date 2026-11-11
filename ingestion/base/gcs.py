import io
from datetime import UTC, datetime

import pandas as pd
from google.cloud import storage

# Environment variable names
_ENV_START = "INGESTION_START_DATE"
_ENV_END = "INGESTION_END_DATE"


def _add_pull_date_csv(data: str, pull_date: str) -> str:
    """Add pull_date column to CSV data.

    Args:
        data: CSV content as string.
        pull_date: ISO date string (e.g., "2026-11-10").

    Returns:
        CSV with pull_date column added.
    """
    df = pd.read_csv(io.StringIO(data))
    df["pull_date"] = pull_date
    return df.to_csv(index=False)


def _add_pull_date_jsonl(data: str, pull_date: str) -> str:
    """Add pull_date key to each JSONL record.

    Args:
        data: JSONL content as string (one JSON object per line).
        pull_date: ISO date string (e.g., "2026-11-10").

    Returns:
        JSONL with pull_date key added to each record.
    """
    import json

    lines = []
    for line in data.strip().splitlines():
        if not line.strip():
            continue
        record = json.loads(line)
        record["pull_date"] = pull_date
        lines.append(json.dumps(record))
    return "\n".join(lines) + "\n"


def upload_to_gcs(
    data: str,
    bucket_name: str,
    source: str,
    filename: str,
    prefix: str = "compiler-data-lake",
    pull_date: str | None = None,
) -> str:
    """Upload data to GCS with timestamped file naming.

    Files are written to the pattern:
    <prefix>/<source>/<YYYY>/<MM>/<DD>/<filename>_<timestamp>.<ext>

    For CSV files, a `pull_date` column is injected.
    For JSONL files, a `pull_date` key is added to each record.

    Args:
        data: The data content to upload (string).
        bucket_name: Name of the GCS bucket.
        source: Source name (e.g., "toggl").
        filename: Base filename (e.g., "timesheets.csv").
        prefix: GCS prefix (default: "compiler-data-lake").
        pull_date: ISO date string for the pull_date column/key.
            Defaults to today's date.

    Returns:
        The full GCS path of the uploaded file.
    """
    now = datetime.now(UTC)
    date_path = now.strftime("%Y/%m/%d")
    timestamp = now.strftime("%Y%m%dT%H%M%S")

    if pull_date is None:
        pull_date = now.strftime("%Y-%m-%d")

    name, ext = filename.rsplit(".", 1)
    blob_name = f"{prefix}/{source}/{date_path}/{name}_{timestamp}.{ext}"

    # Inject pull_date
    ext_lower = ext.lower()
    if ext_lower == "csv":
        data = _add_pull_date_csv(data, pull_date)
    elif ext_lower == "jsonl":
        data = _add_pull_date_jsonl(data, pull_date)

    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    blob.upload_from_string(data, content_type="text/plain")

    return blob_name
