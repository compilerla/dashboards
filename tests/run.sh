#!/usr/bin/env bash
set -eu

# run normal pytests, skip e2e tests
coverage run -m pytest -m "not e2e"

# clean out old coverage results
rm -rf docs/reference/coverage

# regenerate coverage report
coverage html --directory docs/reference/coverage
