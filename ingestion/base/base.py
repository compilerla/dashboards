from dataclasses import dataclass


@dataclass
class PullConfig:
    """Configuration for a single ingestion pull.

    Attributes:
        source: Name of the ingestion source (e.g., "toggl").
        start_date: Start date string (absolute date or relative keyword).
        end_date: End date string (absolute date or relative keyword).
        output_bucket: GCS bucket name for output files.
        prefix: GCS prefix (default: "compiler-data-lake").
    """

    source: str
    start_date: str
    end_date: str
    output_bucket: str
    prefix: str = "compiler-data-lake"


class Puller:
    """Abstract base class for ingestion sources.

    Subclasses implement `pull()` to fetch data from a specific source,
    transform it, and upload it to GCS. The base class provides common
    utilities for config validation, date resolution, and file naming.
    """

    def pull(self, source: str, start_date: str | None = None, end_date: str | None = None) -> list[str]:
        """Pull data from the source and return list of uploaded GCS paths.

        Args:
            source: Name of the ingestion source.
            start_date: Start date (override CLI/env defaults).
            end_date: End date (override CLI/env defaults).

        Returns:
            List of GCS paths for uploaded files.

        Raises:
            NotImplementedError: Subclasses must implement this method.
        """
        raise NotImplementedError("Subclasses must implement pull()")
