"""Tests for GCS upload helper."""

from ingestion.base import gcs


class TestUploadToGcs:
    """Tests for the upload_to_gcs function."""

    def test_upload_creates_correct_path(self, mocker):
        """Test that the GCS path follows the expected pattern."""
        mock_bucket = mocker.MagicMock()
        mock_blob = mocker.MagicMock()

        mock_client_cls = mocker.patch.object(gcs.storage, "Client")
        mock_client_cls.return_value.bucket.return_value = mock_bucket
        mock_bucket.blob.return_value = mock_blob

        result = gcs.upload_to_gcs("test data", "my-bucket", "toggl", "timesheets.csv")

        # Verify the blob name follows the pattern
        assert result.startswith("compiler-data-lake/toggl/")
        assert "/20" in result  # year in path
        assert "timesheets_" in result
        assert result.endswith(".csv")

    def test_upload_uses_default_prefix(self, mocker):
        """Test that the default prefix is used when not specified."""
        mock_bucket = mocker.MagicMock()
        mock_blob = mocker.MagicMock()

        mock_client_cls = mocker.patch.object(gcs.storage, "Client")
        mock_client_cls.return_value.bucket.return_value = mock_bucket
        mock_bucket.blob.return_value = mock_blob

        gcs.upload_to_gcs("test data", "my-bucket", "source", "file.txt")

        blob_name = mock_bucket.blob.call_args[0][0]
        assert blob_name.startswith("compiler-data-lake/source/")

    def test_upload_uses_custom_prefix(self, mocker):
        """Test that a custom prefix is used when specified."""
        mock_bucket = mocker.MagicMock()
        mock_blob = mocker.MagicMock()

        mock_client_cls = mocker.patch.object(gcs.storage, "Client")
        mock_client_cls.return_value.bucket.return_value = mock_bucket
        mock_bucket.blob.return_value = mock_blob

        gcs.upload_to_gcs("test data", "my-bucket", "source", "file.txt", prefix="my-prefix")

        blob_name = mock_bucket.blob.call_args[0][0]
        assert blob_name.startswith("my-prefix/source/")
