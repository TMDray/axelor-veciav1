#!/usr/bin/env python3
"""
Axelor Custom Fields Importer via REST API

Creates custom fields (MetaJsonField) on Axelor models using REST API.
This script is external to the application - no rebuild needed.

Usage:
    python import-custom-fields.py [--config config.json]

Author: Claude Code (AI) + Tanguy
Date: 2025-10-06
"""

import requests
import json
import sys
import logging
from pathlib import Path
from typing import Dict, List, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(levelname)s] %(message)s'
)
logger = logging.getLogger(__name__)


class AxelorCustomFieldsImporter:
    """Import custom fields to Axelor via REST API"""

    def __init__(self, config_path: str = "config.json"):
        """
        Initialize importer with configuration

        Args:
            config_path: Path to config.json file
        """
        self.config_path = Path(__file__).parent / config_path
        self.config = self._load_config()
        self.session = requests.Session()
        self.base_url = self.config['axelor_url']

    def _load_config(self) -> Dict:
        """Load configuration from JSON file"""
        try:
            with open(self.config_path, 'r') as f:
                config = json.load(f)
                logger.info(f"Configuration loaded from {self.config_path}")
                return config
        except FileNotFoundError:
            logger.error(f"Config file not found: {self.config_path}")
            sys.exit(1)
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON in config file: {e}")
            sys.exit(1)

    def authenticate(self) -> bool:
        """
        Authenticate to Axelor using session-based auth

        Returns:
            True if authentication successful, False otherwise
        """
        logger.info(f"Connecting to Axelor at {self.base_url}...")

        auth_url = f"{self.base_url}/callback"
        auth_data = {
            "username": self.config['username'],
            "password": self.config['password']
        }

        try:
            response = self.session.post(
                auth_url,
                json=auth_data,
                headers={
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                }
            )

            if response.status_code == 200:
                logger.info("Authentication successful")
                return True
            else:
                logger.error(f"Authentication failed: {response.status_code}")
                logger.error(f"Response: {response.text}")
                return False

        except requests.RequestException as e:
            logger.error(f"Connection error: {e}")
            return False

    def field_exists(self, field_name: str, model: str) -> Optional[int]:
        """
        Check if custom field already exists

        Args:
            field_name: Name of the field
            model: Fully qualified model class name

        Returns:
            Field ID if exists, None otherwise
        """
        search_url = f"{self.base_url}/ws/rest/com.axelor.meta.db.MetaJsonField/search"

        search_data = {
            "offset": 0,
            "limit": 1,
            "fields": ["id", "name", "model"],
            "data": {
                "_domain": f"self.name = :name AND self.model = :model",
                "_domainContext": {
                    "name": field_name,
                    "model": model
                }
            }
        }

        try:
            response = self.session.post(
                search_url,
                json=search_data,
                headers={'Content-Type': 'application/json'}
            )

            if response.status_code == 200:
                result = response.json()
                if result.get('total', 0) > 0:
                    field_id = result['data'][0]['id']
                    logger.info(f"Field '{field_name}' already exists (ID: {field_id})")
                    return field_id
            return None

        except requests.RequestException as e:
            logger.warning(f"Could not check field existence: {e}")
            return None

    def create_custom_field(self, field_config: Dict) -> bool:
        """
        Create or update custom field via REST API

        Args:
            field_config: Field configuration dict

        Returns:
            True if successful, False otherwise
        """
        field_name = field_config['name']
        model = field_config['model']

        logger.info(f"Processing field '{field_name}' on {model.split('.')[-1]}...")

        # Check if field exists
        existing_id = self.field_exists(field_name, model)

        # Prepare field data
        field_data = {
            "name": field_config['name'],
            "title": field_config['title'],
            "type": field_config['type'],
            "model": field_config['model'],
            "modelField": field_config.get('modelField', 'attrs')
        }

        # Optional attributes
        optional_attrs = [
            'selection', 'widget', 'sequence', 'showIf', 'visibleInGrid',
            'required', 'readonly', 'hidden', 'help', 'large', 'multiline',
            'precision', 'scale', 'targetModel', 'targetName'
        ]

        for attr in optional_attrs:
            if attr in field_config and field_config[attr] is not None:
                field_data[attr] = field_config[attr]

        # If exists, add ID and version for update
        if existing_id:
            field_data['id'] = existing_id
            field_data['version'] = 0  # Axelor handles version automatically

        # Create/Update via REST API
        api_url = f"{self.base_url}/ws/rest/com.axelor.meta.db.MetaJsonField"

        try:
            response = self.session.put(
                api_url,
                json={"data": field_data},
                headers={'Content-Type': 'application/json'}
            )

            if response.status_code == 200:
                result = response.json()
                if result.get('status') == 0:  # Success
                    action = "updated" if existing_id else "created"
                    field_id = result['data'][0]['id']
                    logger.info(f"✓ Field '{field_name}' {action} successfully (ID: {field_id})")
                    return True
                else:
                    logger.error(f"✗ API error: {result.get('data', 'Unknown error')}")
                    return False
            else:
                logger.error(f"✗ HTTP {response.status_code}: {response.text}")
                return False

        except requests.RequestException as e:
            logger.error(f"✗ Request failed: {e}")
            return False

    def import_fields(self) -> Dict[str, int]:
        """
        Import all custom fields from configuration

        Returns:
            Dict with 'success' and 'failed' counts
        """
        fields = self.config.get('custom_fields', [])

        if not fields:
            logger.warning("No custom fields defined in configuration")
            return {'success': 0, 'failed': 0}

        logger.info(f"Found {len(fields)} field(s) to process")
        print()  # Blank line for readability

        success_count = 0
        failed_count = 0

        for field_config in fields:
            if self.create_custom_field(field_config):
                success_count += 1
            else:
                failed_count += 1
            print()  # Blank line between fields

        return {'success': success_count, 'failed': failed_count}

    def run(self) -> bool:
        """
        Main execution flow

        Returns:
            True if all fields imported successfully, False otherwise
        """
        # Authenticate
        if not self.authenticate():
            logger.error("Authentication failed. Exiting.")
            return False

        print()  # Blank line after auth

        # Import fields
        results = self.import_fields()

        # Summary
        logger.info("="*50)
        logger.info(f"SUMMARY: {results['success']} field(s) created/updated, {results['failed']} error(s)")
        logger.info("="*50)

        return results['failed'] == 0


def main():
    """Main entry point"""
    import argparse

    parser = argparse.ArgumentParser(
        description='Import Axelor custom fields via REST API'
    )
    parser.add_argument(
        '--config',
        default='config.json',
        help='Path to config file (default: config.json)'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Enable verbose logging'
    )

    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # Run importer
    importer = AxelorCustomFieldsImporter(config_path=args.config)
    success = importer.run()

    # Exit with appropriate code
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
