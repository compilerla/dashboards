"""Integration tests for CLI → resolve_date_range → Puller wiring using a test puller."""

import os
from unittest.mock import patch

import click
from click.testing import CliRunner

from ingestion.base import cli
from ingestion.base.puller import Puller


class MockPuller(Puller):
    """A test puller that records the arguments passed to pull()."""

    def __init__(self):
        self.pull_calls = []

    def pull(self, source: str, start_date: str | None = None, end_date: str | None = None):
        """Record the call instead of actually pulling."""
        self.pull_calls.append(
            {
                "source": source,
                "start_date": start_date,
                "end_date": end_date,
            }
        )


def _make_test_command(puller: MockPuller) -> click.Command:
    """Create a minimal CLI command that mimics register_source wiring.

    This mirrors what main.py does: resolve dates, then call puller.pull().
    """

    @click.command()
    @click.option("--start", "start_date", help="Start date")
    @click.option("--end", "end_date", help="End date")
    def pull(start_date: str | None, end_date: str | None):
        resolved_start, resolved_end = cli.resolve_date_range(start_date, end_date)
        puller.pull(source="test-source", start_date=resolved_start, end_date=resolved_end)

    return pull


class TestCLIPullerIntegration:
    """Test the full CLI → resolve_date_range → Puller chain."""

    def test_cli_passes_absolute_dates(self, fixed_time):
        """Test that absolute CLI args are resolved and passed to Puller."""
        with fixed_time("2026-11-10 12:00:00"):
            puller = MockPuller()
            runner = CliRunner()
            cmd = _make_test_command(puller)
            result = runner.invoke(cmd, ["--start", "2026-10-01", "--end", "2026-10-31"])

        assert result.exit_code == 0
        assert len(puller.pull_calls) == 1
        assert puller.pull_calls[0]["source"] == "test-source"
        assert puller.pull_calls[0]["start_date"] == "2026-10-01"
        assert puller.pull_calls[0]["end_date"] == "2026-10-31"

    def test_cli_passes_yesterday_keyword(self, fixed_time):
        """Test that 'yesterday' keyword resolves and is passed to Puller."""
        with fixed_time("2026-11-10 12:00:00"):
            puller = MockPuller()
            runner = CliRunner()
            cmd = _make_test_command(puller)
            result = runner.invoke(cmd, ["--start", "yesterday", "--end", "yesterday"])

        assert result.exit_code == 0
        assert len(puller.pull_calls) == 1
        assert puller.pull_calls[0]["start_date"] == "2026-11-09"
        assert puller.pull_calls[0]["end_date"] == "2026-11-09"

    def test_cli_defaults_to_yesterday_when_no_args(self, fixed_time):
        """Test that CLI defaults to yesterday when no args provided."""
        with fixed_time("2026-11-10 12:00:00"):
            puller = MockPuller()
            runner = CliRunner()
            cmd = _make_test_command(puller)
            result = runner.invoke(cmd, [])

        assert result.exit_code == 0
        assert len(puller.pull_calls) == 1
        assert puller.pull_calls[0]["start_date"] == "2026-11-09"
        assert puller.pull_calls[0]["end_date"] == "2026-11-09"

    def test_cli_env_var_fallback(self, fixed_time):
        """Test that env vars are used when CLI args are absent."""
        with fixed_time("2026-11-10 12:00:00"):
            with patch.dict(os.environ, {"INGESTION_START_DATE": "2026-09-01", "INGESTION_END_DATE": "2026-09-30"}):
                puller = MockPuller()
                runner = CliRunner()
                cmd = _make_test_command(puller)
                result = runner.invoke(cmd, [])

        assert result.exit_code == 0
        assert len(puller.pull_calls) == 1
        assert puller.pull_calls[0]["start_date"] == "2026-09-01"
        assert puller.pull_calls[0]["end_date"] == "2026-09-30"

    def test_cli_args_override_env_vars(self, fixed_time):
        """Test that CLI args take priority over env vars."""
        with fixed_time("2026-11-10 12:00:00"):
            with patch.dict(os.environ, {"INGESTION_START_DATE": "2026-01-01", "INGESTION_END_DATE": "2026-12-31"}):
                puller = MockPuller()
                runner = CliRunner()
                cmd = _make_test_command(puller)
                result = runner.invoke(cmd, ["--start", "2026-06-15", "--end", "2026-06-15"])

        assert result.exit_code == 0
        assert len(puller.pull_calls) == 1
        assert puller.pull_calls[0]["start_date"] == "2026-06-15"
        assert puller.pull_calls[0]["end_date"] == "2026-06-15"
