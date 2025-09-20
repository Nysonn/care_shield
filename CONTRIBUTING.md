# Contributing to CareShield

We love your input! We want to make contributing to CareShield as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

## Pull Requests Process

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Any contributions you make will be under the MIT Software License

In short, when you submit code changes, your submissions are understood to be under the same [MIT License](http://choosealicense.com/licenses/mit/) that covers the project. Feel free to contact the maintainers if that's a concern.

## Report bugs using GitHub's [issue tracker](https://github.com/your-username/care_shield/issues)

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/your-username/care_shield/issues/new); it's that easy!

## Write bug reports with detail, background, and sample code

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## Development Guidelines

### Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` to format your code
- Run `flutter analyze` to check for any issues

### Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

### Flutter/Dart Specific Guidelines

- Use `const` constructors wherever possible
- Prefer `final` over `var` when the variable won't be reassigned
- Use meaningful widget names
- Break large widgets into smaller, reusable components
- Add documentation comments for public APIs

### Testing

- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for user flows
- Aim for high test coverage

### Accessibility

- Ensure all interactive elements are accessible
- Provide semantic labels for screen readers
- Test with accessibility tools
- Support different text scales

## Healthcare & Privacy Considerations

When contributing to CareShield, please keep in mind:

- **Patient Privacy**: Never log or expose sensitive health information
- **Security**: Follow security best practices for healthcare applications
- **Compliance**: Ensure changes maintain HIPAA compliance standards
- **Cultural Sensitivity**: Be mindful of cultural considerations for Ugandan users
- **Medical Accuracy**: Verify any health-related information with healthcare professionals

## Feature Requests

We welcome feature requests! Please:

1. Check if the feature has already been requested
2. Provide a clear description of the problem you're trying to solve
3. Describe your proposed solution
4. Consider the impact on user privacy and security
5. Think about how it fits with the overall app vision

## Documentation

- Update documentation for any new features
- Include code examples where helpful
- Keep README.md current
- Document any breaking changes

## Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

Examples of behavior that contributes to creating a positive environment include:

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

### Enforcement

Project maintainers are responsible for clarifying the standards of acceptable behavior and are expected to take appropriate and fair corrective action in response to any instances of unacceptable behavior.

## Questions?

Don't hesitate to reach out! You can:

- Open an issue with the `question` label
- Contact the maintainers directly
- Join our community discussions

Thank you for contributing to CareShield! 🏥❤️
