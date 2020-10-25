# monit-docker

Run monit in a docker container.

## Usage

Check out the `example` directory including an example `docker-compose.yml` and some example monit configs.

## Utility script

In this readme, the script is named monit. Of course, you can adapt the commands and use any name to not interfere with an existing monit installation.

You can use the utility script to operate monit as usual. It automatically execs the commands inside the first found running monit-docker container. To watch the output use the `-w` flag. For further information type `monit -h`.

```bash
MONIT_BIN=monit

sudo curl -L "https://github.com/SpritzerPyro/monit-docker/releases/download/v1.0.0/monit" -o "/usr/local/bin/${MONIT_BIN}"
sudo chmod +x "/usr/local/bin/${MONIT_BIN}"
```

```bash
monit -h
monit status
monit summary -w
```
