# Contributing to Sabre API Ruby

We love your input! We want to make contributing to Sabre API Ruby as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## We Develop with Github
We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

## We Use [Github Flow](https://guides.github.com/introduction/flow/index.html)
We use GitHub Flow, so all code changes happen through Pull Requests. Pull requests are the best way to propose changes to the codebase. We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## We Use [Github Issues](https://github.com/Sprint19/sabre_api_ruby/issues)
We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/Sprint19/sabre_api_ruby/issues/new); it's that easy!

## Write bug reports with detail, background, and sample code

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can.
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/sabre_api_ruby.git
   cd sabre_api_ruby
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Run the test suite**
   ```bash
   bundle exec rspec
   ```

4. **Run code quality checks**
   ```bash
   bundle exec rubocop
   ```

5. **Start the interactive console**
   ```bash
   bin/console
   ```

## Code Quality Standards

### Ruby Style Guide
We follow the [Ruby Style Guide](https://github.com/rubocop/ruby-style-guide) and enforce it with RuboCop. Before submitting a pull request, ensure your code passes all RuboCop checks:

```bash
bundle exec rubocop
```

### Testing
- Write tests for all new functionality
- Ensure all existing tests pass
- Aim for high test coverage (minimum 90%)
- Use descriptive test names
- Follow the existing test patterns

### Documentation
- Update README.md if you change public APIs
- Add YARD documentation for new public methods
- Update CHANGELOG.md for user-facing changes

## Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Make your changes**
   - Write your code
   - Add tests
   - Update documentation

3. **Run quality checks**
   ```bash
   bundle exec rake check
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add amazing feature"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **Create a Pull Request**
   - Use the provided PR template
   - Describe your changes clearly
   - Reference any related issues

## Pull Request Guidelines

### Before submitting a pull request, please:

1. **Test your changes**
   - Run the full test suite: `bundle exec rspec`
   - Run code quality checks: `bundle exec rubocop`
   - Test in both development and test environments

2. **Update documentation**
   - Update README.md if you've changed public APIs
   - Add examples for new features
   - Update CHANGELOG.md for user-facing changes

3. **Follow commit message conventions**
   - Use present tense ("Add feature" not "Added feature")
   - Use imperative mood ("Move cursor to..." not "Moves cursor to...")
   - Limit the first line to 72 characters or less
   - Reference issues and pull requests liberally after the first line

### Example commit messages:
```
Add support for new Sabre API endpoint

- Implement createBooking endpoint
- Add comprehensive error handling
- Include full test coverage
- Update documentation with examples

Closes #123
```

## Code Review Process

1. **Automated Checks**
   - All PRs must pass CI checks
   - Code coverage must remain above 90%
   - All RuboCop violations must be resolved

2. **Manual Review**
   - At least one maintainer must approve
   - All comments must be addressed
   - Tests must be comprehensive

3. **Merging**
   - Squash and merge for feature branches
   - Rebase and merge for hotfixes
   - Delete feature branches after merge

## Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps which reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps**
- **Explain which behavior you expected to see instead and why**
- **Include details about your configuration and environment**

## Suggesting Enhancements

If you have a suggestion for a new feature or enhancement, please:

1. **Check if the feature has already been requested**
2. **Use a clear and descriptive title**
3. **Provide a step-by-step description of the suggested enhancement**
4. **Provide specific examples to demonstrate the steps**
5. **Describe the current behavior and explain which behavior you expected to see instead**

## License
By contributing, you agree that your contributions will be licensed under its MIT License.

## Questions?

Don't hesitate to ask questions by opening an issue or reaching out to the maintainers. We're here to help!

## Recognition

Contributors will be recognized in the README.md file and release notes. We appreciate all contributions, big and small! 