## 1. Title and Video:
- The project is called "ATTENDANCE TRACKER DEPLOY AGENT"
.Here there is video link https://youtu.be/bOKtptdemgc

## 2. Requirements:
- I installed bash,python3 and zip
- Used directory"templates/" next to deploy_agent.sh

## 3. How to run system and select feature:
- cd deploy_agent_isimbisonia then chmod +x deploy_agent.sh then ./deploy_agent.sh
- Use interactive menu 1)Deploy 2)Run 3)Archive 4)Exit
- When you enter invalid input prints"Invalid option" and reshow menu.

## 4. Feature: 1)Deploy:
- Checks python3 and zip first and stop with clear message.
- Asks for project name and create "attendance_tracker_{name}"
- Ask for the roster type and the student count(1 to 10)
- Ask to overwrite if the folder exists and abort if answer is not y
- Creates "Helpers" and "reports/" and copy "attendance_checker.py" and "config.json" unmodified
- Set chmod +x on the python file and "chmod 600" on config.json and shows them with "ls -l"
- Starts the app at the end to check the deployment works
- Show the folder structure

## 5. Roster and total_sessions:
- Option1 copies the header plus N rows from the template.Each student has 4 earlier sessions so "total_sessions" stays 5
- Option2 builds row from arrays of names and emails with counts at 0 and "sed" sets "total_sessions" to 1
- "Total_sessions" must be one more than the earlier sessions in the roster


## 6. How the threshold update works:
- Asks "Update thresholds?(y/n)", then the warning(default 75) and failure(default 50)
- Checks both values are numbers warning is 100 or less and failure is lower than warning
- If check fail, it prints a message and keeps the defaults
- "sed" changes only the "warning:" and "failure:" lines without reformatting the file
- The original in "templates/" is never changed


## 7. Feature: 2)Run:
- Asks for the project name, checks if folder exists and runs "python3 attendance_checker.py" inside it
- Prints "NOT FOUND" and returns to the menu if it doesn't exist



## 8. Feature: 3)Archive:
- Creates "archives/attendance" and "archives/absent" inside the project
- Copies each log with timestamp from date +%Y%m%d_%H%M%S 
- Prints the final path of each archived file.
- If a log is missing, it prints a message and carries on without crashing


## 9. Ctrl+C and ctrl+Z (the archive trigger):
- The trap is on only while the project is being created and off before the app starts
- The trigger is pressing Ctrl+C or Ctrl+Z during deployment
- The script prints an interrupted message, zips what exists into "attendance_tracker_{name}_archive.zip", deletes the incomplete folder and exits
- Nothing is zipped if the folder wasn't created yet and an existing project is never touched


## 10. How to test trap and what the zip contains:
- Deploy with roster 1 and 3 students then press Ctrl+C and Ctrl+Z at "Update thresholds?"
- Run "ls" (the zip exists, the folder is gone) and "unzip -l attendance_tracker_{name}_archive.zip
- The zip hold attendance_checker.py, Helpers/config.json, Helpers/assets.csv and reports/



## 11. How to test deployed structure:
- Cloned the repo into clean folder
- Deployed with both roster options and checked "config.json" and "assets.csv"
- Checked permissions with "ls -l"
- Ran Run and Archive then "ls -R archives"
- Edge cases:existing folder, empty or letter input, bad thresholds, a missing log and a read-only folder
- Ctrl+C and Ctrl+Z at different points



## 12. Repo contents:
- deploy_agent.sh, templates/ and README.md



