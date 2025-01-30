#!/usr/bin/env zsh

# Source zsh configuration to get proper environment
source ~/.zshrc 2>/dev/null

# Check if repository is provided as argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 OWNER/REPO"
    echo "Example: $0 facebook/react"
    exit 1
fi

REPO="$1"

# Function to get day of week that works on both macOS and Linux
get_day_of_week() {
    local date_str="$1"
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS version
        date -jf "%Y-%m-%dT%H:%M:%SZ" "$date_str" "+%u" 2>/dev/null
    else
        # Linux version
        date -d "$date_str" "+%u" 2>/dev/null
    fi
}

# Function to create a progress bar
create_progress_bar() {
    local percent=$1
    local width=50
    local filled=$(printf "%.0f" $(echo "$width * $percent / 100" | bc))
    printf "["
    printf "%${filled}s" | tr ' ' '🔥'
    printf "%$(($width-$filled))s" | tr ' ' '-'
    printf "] "
}

echo "Fetching releases from $REPO..."
echo "----------------------------------------"

# Initialize counters
friday_releases=0
total_releases=0

gh release list -R "$REPO" --limit 1000 --json tagName,publishedAt,name | \
    jq -r '.[] | [.tagName, .publishedAt, .name] | @tsv' | \
    while IFS=$'\t' read -r tag date name; do
        # Get day of week (1-7, where 5 is Friday)
        day_of_week=$(get_day_of_week "$date")
        
        # Increment counters
        ((total_releases++))
        if [ "$day_of_week" -eq 5 ]; then
            ((friday_releases++))
            printf "📅 Friday Release: Tag: %-15s Date: %-25s Name: %s\n" "$tag" "$date" "$name"
        else
            printf "   Regular Release: Tag: %-15s Date: %-25s Name: %s\n" "$tag" "$date" "$name"
        fi
done

echo "----------------------------------------"
echo "Statistics:"
echo "Total releases: $total_releases"
echo "Friday releases: $friday_releases"
if [ "$total_releases" -gt 0 ]; then
    if command -v bc >/dev/null 2>&1; then
        # Use bc if available
        friday_ratio=$(echo "scale=2; $friday_releases / $total_releases" | bc)
        percentage=$(echo "scale=2; $friday_ratio * 100" | bc)
    else
        # Fallback to zsh arithmetic (less precise)
        friday_ratio=$(( friday_releases * 100 / total_releases ))
        percentage=$friday_ratio
    fi
    
    echo -n "Craziness level: "
    create_progress_bar $percentage
    echo "($percentage%)"
    
    # Add a fun message based on the percentage
    if (( $(echo "$percentage > 50" | bc -l) )); then
        message="🤪 Certifiably crazy!"
    elif (( $(echo "$percentage > 20" | bc -l) )); then
        message="😅 I also like to live dangerously!"
    elif (( $(echo "$percentage > 10" | bc -l) )); then
        message="😏 I'm pretty much normal!"
    else
        message="😌 Pretty sane!"
    fi
    echo "$message"

    # Twitter-friendly summary
    echo "\n----------------------------------------"
    echo "📋 Twitter-friendly summary (copy this):"
    echo "----------------------------------------"
    echo "Analyzed $REPO: $friday_releases/$total_releases ($percentage%) releases on Fridays! $message #FridayDeploy"
fi

