"""Tests for CLI date range resolution and env var fallback."""

import os
from unittest.mock import patch

import pytest

from ingestion.base import cli


class TestResolveDateRange:
    """Tests for resolve_date_range."""

    def test_absolute_dates(self):
        """Test absolute date strings are resolved."""
        start, end = cli.resolve_date_range("2026-10-01", "2026-10-31")
        assert start == "2026-10-01"
        assert end == "2026-10-31"

    def test_defaults_to_yesterday(self, fixed_time):
        """Test that both defaults to yesterday when None."""
        with fixed_time("2026-11-10 12:00:00"):
            start, end = cli.resolve_date_range(None, None)
        assert start == "2026-11-09"
        assert end == "2026-11-09"

    def test_relative_keyword_today(self, fixed_time):
        """Test 'today' resolves to today's date."""
        with fixed_time("2026-11-10 12:00:00"):
            start, end = cli.resolve_date_range("today", "today")
        assert start == "2026-11-10"
        assert end == "2026-11-10"

    def test_relative_keyword_yesterday(self, fixed_time):
        """Test 'yesterday' resolves to yesterday's date."""
        with fixed_time("2026-11-10 12:00:00"):
            start, end = cli.resolve_date_range("yesterday", "yesterday")
        assert start == "2026-11-09"
        assert end == "2026-11-09"

    def test_relative_keyword_last_week(self, fixed_time):
        """Test 'last-week' returns Monday-Sunday range."""
        # Nov 11 is Wednesday (weekday=2), so last week is Nov 2-8
        with fixed_time("2026-11-11 12:00:00"):
            start, end = cli.resolve_date_range("last-week", "last-week")
        assert start == "2026-11-02"
        assert end == "2026-11-08"

    def test_relative_keyword_last_month(self, fixed_time):
        """Test 'last-month' returns first-to-last day of previous month."""
        with fixed_time("2026-11-10 12:00:00"):
            start, end = cli.resolve_date_range("last-month", "last-month")
        # Previous month is October (1st to 31st)
        assert start == "2026-10-01"
        assert end == "2026-10-31"

    def test_start_after_end_raises(self):
        """Test that start > end raises ValueError."""
        with pytest.raises(ValueError, match="after"):
            cli.resolve_date_range("2026-10-31", "2026-10-01")

    def test_env_var_fallback_start(self, fixed_time):
        """Test INGESTION_START_DATE env var is used as fallback."""
        with fixed_time("2026-11-10 12:00:00"):
            with patch.dict(os.environ, {"INGESTION_START_DATE": "2026-09-01"}):
                start, end = cli.resolve_date_range(None, None)
        assert start == "2026-09-01"
        assert end == "2026-11-09"

    def test_env_var_fallback_end(self, fixed_time):
        """Test INGESTION_END_DATE env var is used as fallback."""
        with fixed_time("2026-11-10 12:00:00"):
            with patch.dict(os.environ, {"INGESTION_END_DATE": "2026-12-15"}):
                start, end = cli.resolve_date_range(None, None)
        assert start == "2026-11-09"
        assert end == "2026-12-15"

    def test_env_var_both(self):
        """Test both env vars are used as fallback."""
        with patch.dict(os.environ, {"INGESTION_START_DATE": "2026-09-01", "INGESTION_END_DATE": "2026-09-30"}):
            start, end = cli.resolve_date_range(None, None)
        assert start == "2026-09-01"
        assert end == "2026-09-30"

    def test_cli_args_override_env_vars(self):
        """Test CLI args take priority over env vars."""
        with patch.dict(os.environ, {"INGESTION_START_DATE": "2026-01-01", "INGESTION_END_DATE": "2026-12-31"}):
            start, end = cli.resolve_date_range("2026-06-01", "2026-06-30")
        assert start == "2026-06-01"
        assert end == "2026-06-30"

    def test_unrecognized_keyword_raises(self):
        """Test unrecognized keywords raise ValueError."""
        with pytest.raises(ValueError, match="Unrecognized"):
            cli.resolve_date_range("not-a-date", "2026-10-31")


class TestCreatePullCommand:
    """Tests for the Click pull command."""

    def test_command_exists(self):
        """Test that create_pull_command returns a Click command."""
        cmd = cli.create_pull_command()
        assert cmd.name == "pull"
