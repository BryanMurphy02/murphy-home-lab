# Stage 1 — Discovery: find all your script log directories and their log files using pathlib
# Stage 2 — Parsing: read a log file, find the most recent run, and parse each line into structured data using regex
# Stage 3 — Analysis: determine status, extract key info (duration, size, warnings, errors)
# Stage 4 — Reporting: write the formatted report using Python's logging module
# Stage 5 — Wiring up: make it runnable from cron cleanly


from pathlib import Path
import re
from datetime import datetime
import logging

logging.basicConfig(
    filename='/var/log/my-scripts/report.log',
    level=logging.INFO,
    format='%(message)s'
)


# making a path to all logs
p = Path('/var/log/my-scripts')

# path to all log files needing to be analyzed
log_files = []

# dictionary to store file name linked with the parsed file
results = {}


# main analyze logic
def analyze_logs(parsed_lines):
    status = 'SUCCESS'
    err_messages = []
    warn_messages = []
    start_time = ''
    end_time = ''
    duration = ''
    for line in parsed_lines:
        # status logic
        if (line['level'] == 'ERR' or line['level'] == 'ERROR'):
            status = 'ERROR'
            err_messages.append(line['message'])
        elif (line['level'] == 'WARN' or line['level'] == 'WARNING') and status != 'ERROR':
            status = 'WARNING'
            warn_messages.append(line['message'])
        
        # start time
        if 'script began' in line['message']:
            start_time = line['timestamp']
        
        # end time
        if 'script end' in line['message']:
            end_time = line['timestamp']

    # duration
    if end_time:
        fmt = "%Y-%m-%d %H:%M:%S"
        duration = str(datetime.strptime(end_time, fmt) - datetime.strptime(start_time, fmt))
    else:
        status = 'INCOMPLETE'
        duration = 'N/A'

    return {
        'status': status,
        'start': start_time,
        'end': end_time,
        'duration': duration,
        'errors': err_messages,
        'warnings': warn_messages
    }




# use regex to pull timestamp, severity, and message
# \d matches any digits 0-9

# pattern for time stamp
# 4 digits-2digits-2digits space 2digits:2digits:2digits
# need to use escape to read []
# \[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]

# pattern for severity
# "one or more word characters"
# \[(\w+)\]

# pattern for message
# "one or more of any character"
# .+

# full pattern
# r before means raw string
pattern = r'\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\] \[(\w+)\] (.+)'

# looking through /var/logs and find only the directories
# giving glob ** make it look through all the directories AND all the subdirectories no matter how deep
# /*.log maeans look for files within the search that end in .log
for file in p.glob('**/*.log'):
    if file.name != 'report.log':
        log_files.append(file)

# file is still a Path object
for file in log_files:
    # read the entire file
    with file.open() as f:
        lines = f.readlines()
    # start at the end of the file and look backwards to find the index where the script begins
    for i in range(len(lines) - 1, -1, -1):
        if "script began" in lines[i]:
            # slice the list and give me everything from index i to end of file
            # also strip the lines to get rid of escape characters
            most_recent_log = [line.strip() for line in lines[i:]]
            break

    # print(most_recent_log)
    
    parsed_lines = []
    

    for line in most_recent_log:
        # looking for pattern matches within every line
        match = re.search(pattern, line)
        if match:
            # add the full grouped line to the list
            # group(0) would be the full line
            parsed_lines.append({
                'timestamp': match.group(1),
                'level': match.group(2),
                'message': match.group(3)
            })
    
    # link the parsed log file with the name of the file
    results[file.parent.name] = parsed_lines


# analyzing the logs

logging.info('=' * 40)
logging.info(f'LOG ANALYSIS REPORT — {datetime.now().strftime("%Y-%m-%d %H:%M")}')
logging.info('=' * 40)
for script_name, parsed_lines in results.items():
    summary = analyze_logs(parsed_lines)

    # 'status': status,
    #     'start': start_time,
    #     'end': end_time,
    #     'duration': duration,
    #     'errors': err_messages,
    #     'warnings': warn_messages

    # logging everything
    logging.info('')
    logging.info(f'[ {script_name} ]')
    logging.info(f"Status:   {summary['status']}")
    logging.info(f"Started:  {summary['start']}")
    logging.info(f"Ended:  {summary['end']}")
    logging.info(f"Duration:  {summary['duration']}")
    if len(summary['errors']) == 0:
        logging.info("Errors:   0")
    else:
        logging.info(f"Errors:   {len(summary['errors'])}")
        for err in summary['errors']:
            logging.info(f"  - {err}")
    if len(summary['warnings']) == 0:
        logging.info("Warnings:   0")
    else:
        logging.info(f"Warnings:   {len(summary['warnings'])}")
        for warn in summary['warnings']:
            logging.info(f"  - {warn}")

logging.info('=' * 40)
logging.info('')



