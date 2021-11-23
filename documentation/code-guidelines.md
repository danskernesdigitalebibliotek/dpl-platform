# Code guidelines

The following guidelines describe best practices for developing code for the DPL
Platform project. The guidelines should help achieve:

* A stable, secure and high quality foundation for building and maintaining
  the platform and its infrastructure.
* Consistency across multiple developers participating in the project

Contributions to the core DPL Platform project will be reviewed by members of the
Core team. These guidelines should inform contributors about what to expect in
such a review. If a review comment cannot be traced back to one of these
guidelines it indicates that the guidelines should be updated to ensure
transparency.

## Coding standards

The project follows the [Drupal Coding Standards](https://www.drupal.org/docs/develop/standards)
and best practices for all parts of the project: PHP, JavaScript and CSS. This
makes the project recognizable for developers with experience from other Drupal
projects. All developers are expected to make themselves familiar with these
standards.

The following lists significant areas where the project either intentionally
expands or deviates from the official standards or areas which developers should
be especially aware of.

### General

* The default language for all code and comments is English.

### Shell scripts

* Shell-scripts must pass a shellcheck validation

### Terraform

* Any Terraform HCL must be formatted to match the format required by `terraform fmt`
* Terraform configuration should be organized into submodules instantiated by
  root modules.

### Markdown

* Markdown must pass validation by [markdownlint](https://github.com/DavidAnson/markdownlint-cli2)

## Code comments

Code comments which describe _what_ an implementation does should only be used
for complex implementations usually consisting of multiple loops, conditional
statements etc.

Inline code comments should focus on _why_ an unusual implementation has been
implemented the way it is. This may include references to such things as
business requirements, odd system behavior or browser inconsistencies.

## Commit messages

Commit messages in the version control system help all developers understand the
current state of the code base, how it has evolved and the context of each
change. This is especially important for a project which is expected to have a
long lifetime.

Commit messages must follow these guidelines:

1. Each line must not be more than 72 characters long
2. The first line of your commit message (the subject) must contain a short
   summary of the change. The subject should be kept around 50 characters long.
3. The subject must be followed by a blank line
4. Subsequent lines (the body) should explain what you have changed and why the
   change is necessary. This provides context for other developers who have not
   been part of the development process. The larger the change the more
   description in the body is expected.
5. If the commit is a result of an issue in a public issue tracker,
   platform.dandigbib.dk, then the subject must start with the issue number
  followed by a colon (:). If the commit is a result of a private issue tracker
  then the issue id must be kept in the commit body.

When creating a pull request the pull request description should not contain any
information that is not already available in the commit messages.

Developers are encouraged to read [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/)
by Chris Beams.

## Tool support

The project aims to automate compliance checks as much as possible using static
code analysis tools. This should make it easier for developers to check
contributions before submitting them for review and thus make the review process
easier.

The following tools pay a key part here:

1. [terraform fmt](https://www.terraform.io/docs/cli/commands/fmt.html) for standard
   Terraform formatting.
2. [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) for
   linting markdown files. The tool is configured via /.markdownlint-cli2.yaml
3. [ShellCheck](https://github.com/koalaman/shellcheck) with its default configuration.

In general all tools must be able to run locally. This allows developers to get
quick feedback on their work.

Tools which provide automated fixes are preferred. This reduces the burden of
keeping code compliant for developers.

Code which is to be exempt from these standards must be marked accordingly in
the codebase - usually through inline comments ([markdownlint](https://github.com/DavidAnson/markdownlint/blob/main/README.md#configuration),
[ShellCheck](https://github.com/koalaman/shellcheck/wiki/Ignore)).
This must also include a human readable reasoning. This ensures that deviations
do not affect future analysis and the Core project should always pass through
static analysis.

If there are discrepancies between the automated checks and the standards
defined here then developers are encouraged to point this out so the automated
checks or these standards can be updated accordingly.
