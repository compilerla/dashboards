from datetime import UTC, datetime

from google.cloud import storage


def upload_to_gcs(
    data: str,
    bucket_name: str,
    source: str,
    filename: str,
    prefix: str = "compiler-data-lake",
) -> str:
    """Upload data to GCS with timestamped file naming.

    Files are written to the pattern:
    <prefix>/<source>/<YYYY>/<MM>/<DD>/<filename>_<timestamp>.<ext>

    Args:
        data: The data content to upload (string).
        bucket_name: Name of the GCS bucket.
        source: Source name (e.g., "toggl").
        filename: Base filename (e.g., "timesheets.csv").
        prefix: GCS prefix (default: "compiler-data-lake").

    Returns:
        The full GCS path of the uploaded file.
    """
    now = datetime.now(UTC)
    date_path = now.strftime("%Y/%m/%d")
    timestamp = now.strftime("%Y%m%dT%H%M%S")
    name, ext = filename.rsplit(".", 1)
    blob_name = f"{prefix}/{source}/{date_path}/{name}_{timestamp}.{ext}"

    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    blob.upload_from_string(data, content_type="text/plain")

    return blob_name
