# Deploy & Pray 🙏

Are your deploys blessed by the Friday gods? This tool counts your prayers... ahm, releases to find out!

## What does it do?

This script analyzes a GitHub repository's release history and calculates your "craziness level" based on the percentage of releases done on Fridays. It features:

- 📊 Detailed list of all releases with dates
- 📅 Special highlighting for Friday releases
- 🔥 Visual "craziness meter" showing your Friday deployment ratio
- 😅 Feedback on your deployment practices

## Requirements

- zsh
- GitHub CLI (`gh`) installed and authenticated
- `bc` for precise calculations (optional)
- `jq` for JSON parsing

## Installation

1. Clone this repository:
```bash
git clone git@github.com:bonomat/deploy-n-pray.git
```

2. Make the script executable:
```bash
chmod +x deploy-n-pray-checker.sh
```

## Usage

```bash
./deploy-n-pray-checker.sh OWNER/REPO
```

Example:
```bash
./deploy-n-pray-checker.sh facebook/react
```

## Output Example

```
Fetching releases from facebook/react...
----------------------------------------
📅 Friday Release: Tag: v18.2.0       Date: 2022-06-14T19:45:14Z     Name: React v18.2.0
   Regular Release: Tag: v18.1.0       Date: 2022-04-26T19:47:42Z     Name: React v18.1.0
----------------------------------------
Statistics:
Total releases: 41
Friday releases: 5
Craziness level: [🔥🔥🔥🔥🔥🔥--------------------------------------------] (12.00%)
😏 A bit risky!

----------------------------------------
📋 Twitter-friendly summary (copy this):
----------------------------------------
Analyzed facebook/react: 5/41 (12.00%) releases on Fridays! 😏 I also like to live dangerously! 
```

## Why?

"It's Friday 4 PM, what could possibly go wrong?" - Developer, moments before a disaster.

This tool was created as a fun way to check if your team might be living too dangerously with Friday deployments. 
Remember the golden rule: Friday is for bug fixes and documentation, not for major deployments!

## Contributing

Feel free to submit pull requests or rant if things are not working. I probably won't fix any issues though as this was just a quick hack 😅


