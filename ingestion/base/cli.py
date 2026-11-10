from datetime import UTC, datetime, timedelta

import click
import pendulum

# Relative date keywords and their resolution logic
_RELATIVE_KEYWORDS: dict[str, callable] = {
    "today": lambda: datetime.now(UTC).date(),
    "yesterday": lambda: datetime.now(UTC).date() - timedelta(days=1),
    "last-week": lambda: _last_week_range(),
    "last-month": lambda: _last_month_range(),
}


def _last_week_range() -> tuple[str, str]:
    """Return (start, end) for the Monday-Sunday of last week."""
    today = datetime.now(UTC).date()
    monday_last_week = today - timedelta(days=(today.weekday() + 7) % 7 - 7)
    sunday_last_week = monday_last_week + timedelta(days=6)
    return monday_last_week.isoformat(), sunday_last_week.isoformat()


def _last_month_range() -> tuple[str, str]:
    """Return (start, end) for the first to last day of the previous month."""
    today = datetime.now(UTC).date()
    first_of_current = today.replace(day=1)
    first_of_last_month = first_of_current - timedelta(days=1)
    last_day = pendulum.instance(first_of_last_month).add(months=1).day
    start = first_of_last_month.replace(day=1).isoformat()
    end = first_of_last_month.replace(day=last_day).isoformat()
    return start, end


def resolve_date_range(start: str | None, end: str | None) -> tuple[str, str]:
    """Resolve start and end date strings to ISO format dates.

    Handles both absolute dates (e.g., "2026-10-01") and relative keywords
    (e.g., "yesterday", "last-week"). When a relative keyword is used for
    a range (like last-week), both start and end are resolved.

    Args:
        start: Start date string or None.
        end: End date string or None.

    Returns:
        Tuple of (resolved_start, resolved_end) in ISO format.

    Raises:
        ValueError: If start is after end, or if a keyword is not recognized.
    """
    # Resolve start
    if start is None:
        start = "yesterday"
    resolved_start = _resolve_single_date(start)

    # Resolve end
    if end is None:
        end = "yesterday"
    resolved_end = _resolve_single_date(end)

    # Validate
    if resolved_start > resolved_end:
        raise ValueError(f"Start date ({resolved_start}) is after end date ({resolved_end})")

    return resolved_start.isoformat(), resolved_end.isoformat()


def _resolve_single_date(date_str: str) -> datetime:
    """Resolve a single date string (absolute or relative keyword)."""
    date_str = date_str.strip().lower()

    if date_str in _RELATIVE_KEYWORDS:
        return _RELATIVE_KEYWORDS[date_str]()

    # Try parsing as absolute date
    try:
        return pendulum.parse(date_str).in_timezone(UTC)
    except ValueError:
        raise ValueError(f"Unrecognized date value: {date_str}")


def create_pull_command() -> click.Command:
    """Create a Click command for the pull action.

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
