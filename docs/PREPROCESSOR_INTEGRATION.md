# Preprocessor Integration with Test Picker

The Yoda.nvim test picker can integrate with a custom `preprocessor.py` script to handle complex test setups and configurations. This allows you to perform custom preprocessing steps before running your tests.

## How It Works

1. **Auto-Detection**: The test picker automatically checks for a `preprocessor.py` file in your project root
2. **Smart Execution**: If found, it runs the preprocessor with Click command-line arguments instead of calling pytest directly
3. **Fallback**: If no preprocessor is found, it falls back to direct pytest execution

## Command Generation

### With Preprocessor (when `preprocessor.py` exists):
```bash
python preprocessor.py process -e qa -r auto -m bdd --allure
```

### Without Preprocessor (fallback):
```bash
pytest --tb=short -v -m bdd --alluredir=allure-results
```

## Terminal Output

The test picker displays a configuration header showing which mode is being used:

```
============================================================
TEST CONFIGURATION
============================================================
Environment: qa
Region: auto
Markers: bdd
Allure Report: Yes
Python Env: /path/to/venv
Execution Mode: Preprocessor Script  # or "Direct Pytest"
Command: /path/to/venv/bin/python preprocessor.py process -e qa -r auto -m bdd --allure
============================================================
```

## Creating Your Preprocessor

### Requirements

1. **File Location**: Must be named `preprocessor.py` in your project root
2. **Dependencies**: Requires Click for command-line parsing: `pip install click`
3. **Interface**: Must have a `process` command with these options:
   - `-e, --environment`: Test environment (qa, prod, etc.)
   - `-r, --region`: Test region (auto, us-east, etc.)  
   - `-m, --markers`: Pytest markers to run
   - `--allure`: Flag to enable Allure report generation

### Example Implementation

See `examples/preprocessor.py` for a complete working example. Here's the basic structure:

```python
#!/usr/bin/env python3
import click
import subprocess
import sys

@click.group()
def cli():
    """Test preprocessor with multiple commands."""
    pass

@cli.command()
@click.option("-e", "--environment", default="qa", help="Test environment")
@click.option("-r", "--region", default="auto", help="Test region")
@click.option("-m", "--markers", default="", help="Pytest markers")
@click.option("--allure", is_flag=True, help="Generate Allure report")
def process(environment, region, markers, allure):
    """Process tests with the given configuration."""
    
    # 1. Display configuration
    print(f"Environment: {environment}")
    print(f"Region: {region}")
    print(f"Markers: {markers or 'None'}")
    print(f"Allure: {'Yes' if allure else 'No'}")
    
    # 2. Perform preprocessing steps
    setup_test_environment(environment, region, markers)
    
    # 3. Build and run pytest command
    cmd = build_pytest_command(markers, allure)
    result = subprocess.run(cmd, check=False)
    
    # 4. Cleanup and exit
    cleanup_test_environment()
    sys.exit(result.returncode)

if __name__ == "__main__":
    cli()
```

## Use Cases for Preprocessor

### Environment Setup
- Configure API endpoints based on environment
- Set up test databases
- Configure authentication credentials
- Set region-specific settings

### Test Data Management
- Generate test fixtures
- Seed databases with test data
- Set up mock services
- Configure test-specific environment variables

### Advanced Configuration
- Dynamic pytest argument building
- Conditional test execution
- Custom report generation
- Integration with CI/CD systems

### Cleanup Tasks
- Tear down test resources
- Generate custom reports
- Upload test artifacts
- Send notifications

## Testing Your Preprocessor

You can test your preprocessor directly from the command line:

```bash
# Test with different configurations
python preprocessor.py process -e qa -r auto -m smoke
python preprocessor.py process -e prod -r us-east -m integration --allure

# Check help
python preprocessor.py --help
python preprocessor.py process --help
```

## Benefits

1. **Consistency**: Same interface for all test execution
2. **Flexibility**: Custom logic for different environments/regions
3. **Integration**: Seamless integration with Yoda.nvim test picker
4. **Fallback**: Graceful fallback to direct pytest if no preprocessor
5. **Visibility**: Clear indication of execution mode in terminal

## Environment Variables

When using a virtual environment, the preprocessor will have access to:
- `VIRTUAL_ENV`: Path to the virtual environment
- `PATH`: Updated PATH including the virtual environment

The test picker ensures these are set correctly before running your preprocessor.