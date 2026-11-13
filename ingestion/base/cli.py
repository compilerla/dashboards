import os
from datetime import UTC, timedelta

import click
import pendulum

# Environment variable names
_ENV_START = "INGESTION_START_DATE"
_ENV_END = "INGESTION_END_DATE"

# Relative date keywords that produce a date range (start, end)
_RANGE_KEYWORDS = ("last-week", "last-month")

# Relative date keywords that produce a single date
_SINGLE_KEYWORDS = ("today", "yesterday")


def _last_week_range() -> tuple[str, str]:
    """Return (start, end) for the Monday-Sunday of last week."""
    today = pendulum.now(UTC).date()
    # Go to the Monday of last week
    monday_this_week = today - timedelta(days=today.weekday())
    monday_last_week = monday_this_week - timedelta(days=7)
    sunday_last_week = monday_last_week + timedelta(days=6)
    return monday_last_week.isoformat(), sunday_last_week.isoformat()


def _last_month_range() -> tuple[str, str]:
    """Return (start, end) for the first to last day of the previous month."""
    today = pendulum.now(UTC).date()
    # First day of current month, then subtract 1 day to get last day of last month
    first_of_current = today.replace(day=1)
    last_of_last_month = first_of_current - timedelta(days=1)
    first_of_last_month = last_of_last_month.replace(day=1)
    return first_of_last_month.isoformat(), last_of_last_month.isoformat()


def _resolve_single_date(date_str: str) -> str:
    """Resolve a single date string (absolute or relative keyword) to ISO format.

    Args:
        date_str: A date string (absolute or relative keyword).

    Returns:
        ISO format date string (e.g., "2026-11-10").

    Raises:
        ValueError: If the keyword is not recognized.
    """
    date_str = date_str.strip().lower()

    if date_str == "today":
        return pendulum.now(UTC).date().isoformat()
    if date_str == "yesterday":
        return (pendulum.now(UTC).date() - timedelta(days=1)).isoformat()

    # Try parsing as absolute date
    try:
        return pendulum.parse(date_str).in_timezone(UTC).date().isoformat()
    except ValueError:
        raise ValueError(f"Unrecognized date value: {date_str}")


def resolve_date_range(start: str | None, end: str | None) -> tuple[str, str]:
    """Resolve start and end date strings to ISO format dates.

    Resolution priority:
    1. CLI arguments (if provided)
    2. Environment variables (INGESTION_START_DATE / INGESTION_END_DATE)
    3. Default: "yesterday" for both

    Handles both absolute dates (e.g., "2026-10-01") and relative keywords
    (e.g., "yesterday", "last-week"). When a relative keyword is used for
    a range (like last-week), both start and end are resolved together.

    Args:
        start: Start date string, env var value, or None.
        end: End date string, env var value, or None.

    Returns:
        Tuple of (resolved_start, resolved_end) in ISO format.

    Raises:
        ValueError: If start is after end, or if a keyword is not recognized.
    """
    # Resolve start
    if start is None:
        start = os.environ.get(_ENV_START)
    if start is None:
        start = "yesterday"

    # Resolve end
    if end is None:
        end = os.environ.get(_ENV_END)
    if end is None:
        end = "yesterday"

    # Handle range keywords that produce (start, end) tuples
    start_lower = start.lower()
    end_lower = end.lower()

    if start_lower in _RANGE_KEYWORDS and end_lower in _RANGE_KEYWORDS:
        # Both are range keywords — use the same one
        if start_lower == "last-week":
            return _last_week_range()
        if start_lower == "last-month":
            return _last_month_range()
    else:
        # Resolve individually
        resolved_start = _resolve_single_date(start)
        resolved_end = _resolve_single_date(end)

        # Validate
        if resolved_start > resolved_end:
            raise ValueError(f"Start date ({resolved_start}) is after end date ({resolved_end})")

        return resolved_start, resolved_end

    # If we get here, we have mismatched range/single keywords
    raise ValueError(f"Cannot mix range keyword '{start}' with single keyword '{end}'")


def create_pull_command() -> click.Command:
    """Create a Click command for the pull action.

    Resolves dates from CLI args, env vars, or defaults to yesterday.

    Returns:
        A Click Command with --start and --end options.
    """

    @click.command()
    @click.option("--start", "start_date", help="Start date (absolute or relative keyword)")
    @click.option("--end", "end_date", help="End date (absolute or relative keyword)")
    def pull(start_date: str | None, end_date: str | None):
        """Pull data for the given date range."""
        start, end = resolve_date_range(start_date, end_date)
        click.echo(f"Pulling {start} -> {end}")
        # Subclasses will override this to implement actual pulling logic
        return start, end

    return pull
