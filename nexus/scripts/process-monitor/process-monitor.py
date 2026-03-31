# Checks whether specific services are running and logs their status
# Status will be be determined based off of set thresholds for each section
# pathlib for files and regex for pasring. Using subprocesses as well

# Thresholds:
# CPU: WARN 70% or above utilization and ERR at 90% or above
# Memory: WARN at 75% or above and ERR at 90% or above
# Disk Storage: WARN at 70% or above and ERR at 90% or above
# Docker Containers: 
    # Docker itself ERR if down
    # Minecraft world: WARN if down
    # Portainer: WARN if DOWN
# Services:
    # Tailscale: ERR if down
    # Samba: WARN if down

# Other Restrictions
# Logging needs to be uniform with my Bash scripts so my log-analyzer script will catch it
# script begins line:
    # [2026-03-26 03:00:01] [INFO] script began at 2026-03-26 03:00:01
# script ends line:
    # [2026-03-26 03:00:32] [INFO] script end


import logging
from datetime import datetime
import subprocess

logging.basicConfig(
    filename='/var/log/my-scripts/process-monitor/process-monitor.log',
    level=logging.INFO,
    format='[%(asctime)s] [%(levelname)s] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

try:
    import psutil
    PSUTIL_AVAILABLE = True
except ModuleNotFoundError:
    PSUTIL_AVAILABLE = False
    logging.warning('psutil not installed - system metrics unavailable. Run: pip3 install psutil')


# logging.info() to log info
# logging.warning() to log warning
# logging.error() to log an error

# script began log
logging.info(f'script began at {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}')


# returns hostname, kernel, uptime
def get_system_info():
    hostname = subprocess.run(["hostname"], capture_output=True, text=True)
    hostname = (hostname.stdout).strip()

    kernel = subprocess.run(["uname", "-r"], capture_output=True, text=True)
    kernel = (kernel.stdout).strip()

    # need to grab only the first number to show real uptime
    # convert seconds to readable format
    uptime = subprocess.run(["cat", "/proc/uptime"], capture_output=True, text=True)
    uptime_seconds = int(float(uptime.stdout.strip().split()[0]))
    days = uptime_seconds // 86400
    hours = (uptime_seconds % 86400) // 3600
    minutes = (uptime_seconds % 3600) // 60
    seconds = uptime_seconds % 60

    uptime = f"{days}d {hours}h {minutes}m {seconds}s"

    return {
        'hostname': hostname,
        'kernel': kernel,
        'uptime': uptime
    }

# returns float percentage showing cpu usage
def get_cpu_usage():
    if not PSUTIL_AVAILABLE:
        return None
    cpu = psutil.cpu_percent(interval=1)
    return {
        'cpu': cpu
    }

# returns float percentage showing disk usage
def get_disk_usage():
    if not PSUTIL_AVAILABLE:
        return None
    disk = psutil.disk_usage('/')
    return {
        'available': disk.free,
        'percentage': disk.percent
    }

# returns float percentage showing memory usage
def get_memory_usage():
    if not PSUTIL_AVAILABLE:
        return None
    memory = psutil.virtual_memory()
    return {
        'available': memory.available,
        'percentage': memory.percent
    }

# checks to make sure docker is running
# returns list of all running containers
def get_docker_status():
    # check to see if docker is running
    docker_running = subprocess.run(["systemctl", "is-active", "docker.service"], capture_output=True, text=True)
    if docker_running.returncode == 0:
        # get all running container names
        containers = subprocess.run(["docker", "ps",
                                     "--format", "{{.Names}}"], capture_output=True, text=True)
        containers = containers.stdout.strip().split('\n')

        return {
            'docker_running': True,
            'containers': containers,
            'minecraft_running': 'hopefully-this-world-lasts' in containers,
            'portainer_running': 'portainer' in containers
        }
    else:
        return{
            'docker_running': False,
            'containers': [],
            'minecraft_running': False,
            'portainer_running': False
        }

# checks to make sure services are running
# returns if active/inacive
def get_service_status():
    # services to check: Tailscale, Samba ["tailscaled.service", "smbd.service"]
    services = {
        'tailscale': {'service': 'tailscaled.service', 'active': False},
        'samba': {'service': 'smbd.service', 'active': False}
    }
    for service_name, service_info in services.items():
        # get if the service is running
        result = subprocess.run(["systemctl", "is-active", service_info['service']], capture_output=True, text=True)
        # add result to the dict
        service_info['active'] = result.returncode == 0

    return services
        




# logging system info
sys_summary = get_system_info()
for key, value in sys_summary.items():
    logging.info(f"{key}: {value}")

# logging cpu
cpu_summary = get_cpu_usage()
if cpu_summary is None:
    logging.warning('skipping cpu check - psutil unavailable')
else:
    if cpu_summary['cpu'] >= 90:
        logging.error(f"cpu utilization critical: {cpu_summary['cpu']}%")
    elif cpu_summary['cpu'] >= 70:
        logging.warning(f"cpu utilization high: {cpu_summary['cpu']}%")
    else:
        logging.info(f"cpu utilization: {cpu_summary['cpu']}%")

# logging memory usage
memory_summary = get_memory_usage()
if memory_summary is None:
    logging.warning('skipping memory check - psutil unavailable')
else:
    available_gb = round(memory_summary['available'] / (1024 ** 3), 2)
    if memory_summary['percentage'] >= 90:
        logging.error(f"memory utilization critical: {memory_summary['percentage']}%")
        logging.info(f"available memory: {available_gb}GB")
    elif memory_summary['percentage'] >= 75:
        logging.warning(f"memory utilization high: {memory_summary['percentage']}%")
        logging.info(f"available memory: {available_gb}GB")
    else:
        logging.info(f"memory utilization: {memory_summary['percentage']}%")
        logging.info(f"available memory: {available_gb}GB")

# logging disk usage
disk_summary = get_disk_usage()
if disk_summary is None:
    logging.warning('skipping disk check - psutil unavailable')
else:
    available_gb = round(disk_summary['available'] / (1024 ** 3), 2)
    if disk_summary['percentage'] >= 90:
        logging.error(f"disk utilization critical: {disk_summary['percentage']}%")
        logging.info(f"available disk space: {available_gb}GB")
    elif disk_summary['percentage'] >= 70:
        logging.warning(f"disk utilization high: {disk_summary['percentage']}%")
        logging.info(f"available disk space: {available_gb}GB")
    else:
        logging.info(f"disk utilization percentage: {disk_summary['percentage']}%")
        logging.info(f"available disk space: {available_gb}GB")

# logging docker status
docker_summary = get_docker_status()
if docker_summary['docker_running'] is True:
    if not docker_summary['minecraft_running']:
        logging.warning("Minecraft world is not running")
    if not docker_summary['portainer_running']:
        logging.warning("Portainer is not running")
    
    for container in docker_summary['containers']:
        logging.info(f"running container: {container}")

else:
    logging.error("Docker is not running")

# logging service status
service_summary = get_service_status()
for service_name, service_info in service_summary.items():
    if service_info['active']:
        logging.info(f"{service_name} is running")
    else:
        if service_name == 'tailscale':
            logging.error("tailscale is not running")
        if service_name == 'samba':
            logging.warning("samba is not running")


# script end log
logging.info('script end')