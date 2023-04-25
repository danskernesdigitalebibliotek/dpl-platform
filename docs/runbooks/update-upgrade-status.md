# Update the support workload upgrade status

## When to use

When you need to update the support workload version sheet.

## Prerequisites

* Access to the [version status sheet](https://docs.google.com/spreadsheets/d/15xLv-zhIL0g_gQaUfsslYVzAclrG-T5gkjII8mbRHoU)
* Access to run [dplsh](using-dplsh.md)

## Procedure

Run dplsh to extract the current and latest version for all support workloads

```shell
# First authenticate against the cluster
task cluster:auth
# Then pull the status
task ops:get-versions
```

Then access the [version status sheet](https://docs.google.com/spreadsheets/d/15xLv-zhIL0g_gQaUfsslYVzAclrG-T5gkjII8mbRHoU)
and update the status from the output.
