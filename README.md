# Pi IP

A simple shell script that triggers an IFTTT webhook to POST the device's local IP address.

My use case is a headless SSH device on a network where you cannot make its local IP static, such as a Raspberry Pi on a University Network.

## Requirements

The script requires `netcat` and `curl`. You'll need `git` to clone the repo and a text editor like `nano` to edit the `.env` file. You'll need `cron` if you want to set up a cronjob to run on startup.

If you're intending to use a wireless network, you must configure your device to use the wireless network and ensure that your device automatically connects to that network on startup.

## Setup

### Getting the Files

Ensure `git` is installed, then clone the git repo.

```sh
git clone https://github.com/ethmth/pi-ip.git
cd pi-ip/
```

### Select Network Interface

Determine your device's wireless or wired network interface, whichever you want to determine the local IP of. `ip a` gives a list of network interfaces on your device. A common wireless interface is `wlan0`.

Edit the `.env` file with your network interface.

```
INTERFACE_NAME=<your_network_interface>
```

Put your interface in place of `<your_network_interface>`,
For example: `INTERFACE_NAME=wlan0`

> **_NOTE:_** The `.env` file may be hidden, but if you cloned this repo from GitHub and entered its directory, it will be there. You can edit it by typing `nano .env`.

### IFTTT Setup

Register an [IFTTT](https://ifttt.com/) account, then create an applet.

For the _If This_ service, select "Webhooks" then "Receive a web request with a JSON payload". Call the event name something you'll remember, such as _pi_awoken_.

Add the event name to the `.env` file.

```
EVENT_NAME=<your_event_name>
```

For the _Then That_ service, you could theoretically select anything, but I selected "Send an email."

Once the Applet is created, go to [ifttt.com/maker_webhooks](https://ifttt.com/maker_webhooks) and click **Documentation**. It should say "Your key is: <your_key>". Copy the key, then add it to the `.env` file.

```
IFTTT_KEY=<your_key>
```

## Running the Script

### Test the Setup

Make the script executable.

```sh
chmod +x ipcheck.sh
```

Once you added the environment variables to the `.env` file, test the script by running it.

```sh
./ipcheck.sh
```

If you set it up correctly, your IFTTT event should get triggered with the local IP address info of your device.

### Run on Startup/Detect IP Changes

If you would like this script to run on startup, and tell you the local IP address of your device every time it turns on, I would recommend setting up a `cronjob`.

```sh
crontab -e # Edit your crontab
```

Then, add the following lines, replacing the directory with the directory you cloned the git repo into.

```
*/5 * * * * /home/$USER/pi-ip/ipcheck.sh
@reboot /home/$USER/pi-ip/ipcheck.sh startup
```

The first line will cause the script to check for local IP updates every 5 minutes, which is probably not necessary.
The second line will cause the script to check for local IP updates every time the system boots up, which you will likely want to enable.
