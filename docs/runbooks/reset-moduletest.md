# Reset moduletest site

## When to use

When a moduletest site need reseting

## Procedure

1. Find the moduletest site of the project that need reseting in the Lagoon UI
2. Go to tasks
3. Select "Copy files between environments", and set the source
  to "main" and run the task
4. Select "Copy database between environments", and set the source
  to "main" and run the task
5. Select "Clear Drupal Caches" and run the task
6. Go the page URL and check that it looks alright

The moduletest site is now reset
