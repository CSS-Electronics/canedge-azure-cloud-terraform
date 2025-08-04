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

# Configure logging with explicit handlers for better visibility
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.StreamHandler(sys.stderr)
    ]
)

# Get our script logger
logger = logging.getLogger("test-container")

# Ensure all output is flushed immediately
def flush_all():
    """Flush all output streams"""
    sys.stdout.flush()
    sys.stderr.flush()

def main():
    """Main function to test logging"""
    print("=== CONTAINER APP JOB LOGGING TEST STARTED ===")
    logger.info("TEST CONTAINER: Starting test container")
    flush_all()
    
    # Log environment variables (excluding sensitive ones)
    logger.info("TEST CONTAINER: Environment variables:")
    env_count = 0
    for key, value in os.environ.items():
        if not any(sensitive in key.lower() for sensitive in ["password", "token", "secret", "key"]):
            logger.info(f"ENV: {key}={value}")
            env_count += 1
    logger.info(f"TEST CONTAINER: Found {env_count} non-sensitive environment variables")
    flush_all()
    
    # Log different severity levels with explicit flushing
    logger.debug("TEST CONTAINER: This is a DEBUG message")
    flush_all()
    logger.info("TEST CONTAINER: This is an INFO message")
    flush_all()
    logger.warning("TEST CONTAINER: This is a WARNING message")
    flush_all()
    logger.error("TEST CONTAINER: This is an ERROR message")
    flush_all()
    
    # Log to stdout and stderr directly with explicit flushing
    print("TEST CONTAINER: This is printed directly to stdout")
    flush_all()
    print("TEST CONTAINER: This is printed directly to stderr", file=sys.stderr)
    flush_all()
    
    # Additional test messages
    print("STDOUT: Container is running successfully", flush=True)
    print("STDERR: This should appear in error logs", file=sys.stderr, flush=True)
    
    # Wait for specified time to keep container running
    wait_time = 20
    logger.info(f"TEST CONTAINER: Waiting for {wait_time} seconds...")
    flush_all()
    
    for i in range(wait_time):
        if i % 5 == 0:
            message = f"TEST CONTAINER: Still waiting... {i}/{wait_time} seconds elapsed"
            logger.info(message)
            print(f"PROGRESS: {message}", flush=True)
            flush_all()
        time.sleep(1)
    
    final_message = "TEST CONTAINER: Test completed successfully"
    logger.info(final_message)
    print(f"SUCCESS: {final_message}", flush=True)
    print("=== CONTAINER APP JOB LOGGING TEST COMPLETED ===", flush=True)
    flush_all()

if __name__ == "__main__":
    main()
