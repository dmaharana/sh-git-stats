# Git Commit Data Processor

This script processes bare Git repositories located in a specified base directory, collects commit information for each branch, and generates three CSV files summarizing the data.

## Usage

`./process_repos.sh <base_dir>                                                         
`

- Replace <base_dir> with the path to the directory containing your bare Git repositories.

## Prerequisites

- Git must be installed and available in your system's PATH.

## Input Structure

The base directory should contain one or more bare Git repositories. Each repository  
is a directory (without a .git suffix) containing the necessary Git files (e.g.,  
objects, refs, etc.).

## Output Files

1. commits_by_branch.csv  
    Contains the last commit date, repository name, branch name, and total commit count
   for each branch.  
    Format:

date,repo,branch,commit_count

2. commits_by_date.csv  
   Aggregates the total commit counts by date.  
   Format:

date,commit_count

3. commits_by_year.csv  
   Aggregates the total commit counts by year.  
   Format:

year,commit_count

### Example

Assuming the base directory contains a repository named example-repo with branches  
main and feature, the output might look like:

commits_by_branch.csv

2023-10-01,example-repo,main,42  
2023-10-05,example-repo,feature,15

commits_by_date.csv

2023-10-01,42  
2023-10-05,15

commits_by_year.csv

2023,57

## Notes

- The script processes each repository in parallel to improve performance. Locking is
  used to prevent race conditions when appending to the CSV files.
- Ensure that the script has execute permissions. You can set this with chmod +x  
  process_repos.sh.
- The CSV files are overwritten each time the script runs. Back up any important data
  before execution.
