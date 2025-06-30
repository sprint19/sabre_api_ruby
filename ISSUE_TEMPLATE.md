## Issue Type
<!-- Please delete options that are not relevant -->

- [ ] Bug report
- [ ] Feature request
- [ ] Documentation issue
- [ ] Performance issue
- [ ] Security issue
- [ ] Other (please describe)

## Environment Information

**Sabre API Ruby Version:** <!-- e.g., 0.1.0 -->
**Ruby Version:** <!-- e.g., 2.7.0 -->
**Rails Version:** <!-- e.g., 6.1.0 (if applicable) -->
**Operating System:** <!-- e.g., macOS 12.0, Ubuntu 20.04 -->

## Description

<!-- Please provide a clear and concise description of the issue -->

## Steps to Reproduce

<!-- Please provide detailed steps to reproduce the issue -->

1. 
2. 
3. 

## Expected Behavior

<!-- Please describe what you expected to happen -->

## Actual Behavior

<!-- Please describe what actually happened -->

## Code Example

<!-- Please provide a code example that demonstrates the issue -->

```ruby
# Your code here
SabreApiRuby.configure do |config|
  config.client_id = "your_client_id"
  config.client_secret = "your_client_secret"
  config.environment = :test
end

# This causes the issue
booking = SabreApiRuby.create_booking(params)
```

## Error Messages

<!-- Please include any error messages, stack traces, or logs -->

```
Error message here
```

## Configuration

<!-- Please share your configuration (without sensitive credentials) -->

```ruby
SabreApiRuby.configure do |config|
  config.client_id = "your_client_id"
  config.client_secret = "your_client_secret"
  config.environment = :test
  config.timeout = 30
  config.open_timeout = 10
end
```

## Additional Context

<!-- Add any other context about the problem here -->

## Possible Solution

<!-- If you have suggestions on a fix for the bug, please describe it here -->

## Checklist

<!-- Please ensure you've completed the following -->

- [ ] I have searched existing issues to avoid duplicates
- [ ] I have provided all requested information
- [ ] I have tested with the latest version of the gem
- [ ] I have included relevant code examples
- [ ] I have included error messages and stack traces
- [ ] I have checked the documentation for similar issues

---

## For Feature Requests

<!-- If this is a feature request, please provide the following additional information -->

### Use Case

<!-- Please describe the use case for this feature -->

### Proposed Solution

<!-- Please describe your proposed solution -->

### Alternative Solutions

<!-- Please describe any alternative solutions you've considered -->

### Impact

<!-- Please describe the impact this feature would have -->

---

## For Documentation Issues

<!-- If this is a documentation issue, please provide the following additional information -->

### Documentation Location

<!-- Please specify where the documentation issue is located -->

### Current Documentation

<!-- Please paste the current documentation that needs to be updated -->

### Suggested Changes

<!-- Please describe what changes should be made to the documentation -->

---

**Thank you for taking the time to report this issue!** 