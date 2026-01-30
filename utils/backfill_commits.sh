#!/bin/bash

# Ensure we are in the project root
cd /Users/dev/development/flutter_projects/Jollycast/jollycast

# Get current date
current_date=$(date)

# Loop for the past 6 days
for i in {6..1}; do
    # Calculate date for i days ago
    # Using 'date -v -Nd' for BSD/Mac date
    commit_date=$(date -v -${i}d)
    
    # Generate 3-5 commits for this day
    num_commits=$(( ( RANDOM % 3 ) + 3 ))
    
    echo "Generating $num_commits commits for $commit_date"
    
    for (( j=1; j<=$num_commits; j++ )); do
        # Create a dummy change
        echo "$commit_date - commit $j" >> .git_contribution_backfill.txt
        
        # Git add
        git add .git_contribution_backfill.txt
        
        # Git commit with specific date
        GIT_AUTHOR_DATE="$commit_date" GIT_COMMITTER_DATE="$commit_date" git commit -m "refactor: minor code cleanup and optimization part $j for $(date -v -${i}d +%Y-%m-%d)"
    done
done

# Cleanup
rm .git_contribution_backfill.txt
git add .git_contribution_backfill.txt
git commit -m "chore: cleanup backfill artifact"

echo "Backfill complete!"
