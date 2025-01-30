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

# Function to get hour (0-23) that works on both macOS and Linux
get_hour() {
    local date_str="$1"
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS version
        date -jf "%Y-%m-%dT%H:%M:%SZ" "$date_str" "+%H" 2>/dev/null
    else
        # Linux version
        date -d "$date_str" "+%H" 2>/dev/null
    fi
}

# Function to assess time-based risk level
get_time_risk() {
    local hour=$1
    if [ $hour -ge 16 ]; then
        echo "🔥 DANGER ZONE (After 4 PM)"
    elif [ $hour -ge 14 ]; then
        echo "⚠️  Risky (2-4 PM)"
    elif [ $hour -ge 12 ]; then
        echo "😰 Cutting it close (12-2 PM)"
    else
        echo "👍 Early bird (Before noon)"
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
danger_zone_releases=0

gh release list -R "$REPO" --limit 1000 --json tagName,publishedAt,name | \
    jq -r '.[] | [.tagName, .publishedAt, .name] | @tsv' | \
    while IFS=$'\t' read -r tag date name; do
        # Get day of week and hour
        day_of_week=$(get_day_of_week "$date")
        hour=$(get_hour "$date")
        
        # Increment counters
        ((total_releases++))
        if [ "$day_of_week" -eq 5 ]; then
            ((friday_releases++))
            risk_level=$(get_time_risk $hour)
            if [ $hour -ge 16 ]; then
                ((danger_zone_releases++))
            fi
            printf "📅 Friday Release: Tag: %-15s Date: %-25s Name: %-20s %s\n" "$tag" "$date" "$name" "$risk_level"
        else
            printf "   Regular Release: Tag: %-15s Date: %-25s Name: %s\n" "$tag" "$date" "$name"
        fi
done

echo "----------------------------------------"
echo "Statistics:"
echo "Total releases: $total_releases"
if [ "$total_releases" -gt 0 ]; then
    if command -v bc >/dev/null 2>&1; then
        # Calculate all percentages
        friday_ratio=$(echo "scale=2; $friday_releases / $total_releases" | bc)
        percentage=$(echo "scale=2; $friday_ratio * 100" | bc)
        danger_percentage=0
        total_danger_percentage=0
        if [ "$friday_releases" -gt 0 ]; then
            danger_percentage=$(echo "scale=2; $danger_zone_releases / $friday_releases * 100" | bc)
            total_danger_percentage=$(echo "scale=2; $danger_zone_releases / $total_releases * 100" | bc)
        fi
    else
        friday_ratio=$(( friday_releases * 100 / total_releases ))
        percentage=$friday_ratio
        danger_percentage=0
        total_danger_percentage=0
        if [ "$friday_releases" -gt 0 ]; then
            danger_percentage=$(( danger_zone_releases * 100 / friday_releases ))
            total_danger_percentage=$(( danger_zone_releases * 100 / total_releases ))
        fi
    fi
    
    # Display all statistics
    echo "Friday releases: $friday_releases/$total_releases ($percentage%)"
    echo "Danger zone releases (after 4 PM):"
    echo "  - $danger_zone_releases of all releases ($total_danger_percentage%)"
    echo "  - $danger_zone_releases of Friday releases ($danger_percentage%)"
    
    echo -n "\nCraziness level: "
    create_progress_bar $percentage
    echo "($percentage%)"
    
    echo -n "Danger zone level: "
    create_progress_bar $total_danger_percentage
    echo "($total_danger_percentage%)"
    
    # Add a fun message based on percentages
    if (( $(echo "$percentage > 50" | bc -l) )); then
        message="🤪 Certifiably crazy!"
    elif (( $(echo "$percentage > 25" | bc -l) )); then
        message="😅 Living dangerously!"
    elif (( $(echo "$percentage > 10" | bc -l) )); then
        message="😏 A bit risky!"
    else
        message="😌 Pretty sane!"
    fi
    
    # Add danger zone modifier
    if [ "$friday_releases" -gt 0 ] && (( $(echo "$danger_percentage > 50" | bc -l) )); then
        message="$message And you LOVE the danger zone! 🎸"
    elif [ "$friday_releases" -gt 0 ] && (( $(echo "$danger_percentage > 25" | bc -l) )); then
        message="$message Plus you're flirting with the danger zone! ⚠️"
    fi
    echo "$message"

    # Twitter-friendly summary
    echo "\n----------------------------------------"
    echo "📋 Twitter-friendly summary (copy this):"
    echo "----------------------------------------"
    echo "Analyzed $REPO: $friday_releases/$total_releases ($percentage%) releases on Fridays with $danger_zone_releases in the danger zone! $message #DeployAndPray"
fi