#!/usr/bin/env python3
"""
Test Container for Azure Container App Job Logging

This script is a simple test to verify that logs are properly captured
in Azure Container App Jobs. It generates various log messages and then waits
for a specified amount of time before exiting.
"""

import os
import sys
import time
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Get our script logger
logger = logging.getLogger("test-container")

def main():
    """Main function to test logging"""
    logger.info("TEST CONTAINER: Starting test container")
    
    # Log environment variables (excluding sensitive ones)
    logger.info("TEST CONTAINER: Environment variables:")
    for key, value in os.environ.items():
        if not any(sensitive in key.lower() for sensitive in ["password", "token", "secret", "key"]):
            logger.info(f"ENV: {key}={value}")
    
    # Log different severity levels
    logger.debug("TEST CONTAINER: This is a DEBUG message")
    logger.info("TEST CONTAINER: This is an INFO message")
    logger.warning("TEST CONTAINER: This is a WARNING message")
    logger.error("TEST CONTAINER: This is an ERROR message")
    
    # Log to stdout directly
    print("TEST CONTAINER: This is printed directly to stdout")
    
    # Log to stderr directly
    print("TEST CONTAINER: This is printed directly to stderr", file=sys.stderr)
    
    # Wait for specified time to keep container running
    wait_time = 20
    logger.info(f"TEST CONTAINER: Waiting for {wait_time} seconds...")
    for i in range(wait_time):
        if i % 5 == 0:
            logger.info(f"TEST CONTAINER: Still waiting... {i}/{wait_time} seconds elapsed")
        time.sleep(1)
    
    logger.info("TEST CONTAINER: Test completed successfully")

if __name__ == "__main__":
    main()
