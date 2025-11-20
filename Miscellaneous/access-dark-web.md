# [The Dark Web EXPOSED (FREE + Open-Source Tool)](https://www.youtube.com/watch?v=_KzObeom88Y)
 - [Github](https://github.com/theNetworkChuck/dark-web-scraping-guide)
 - [Robin Github Repo](https://github.com/apurvsinghgautam/robin)

# Run Robin

```
cd ~/Github/robin

chmod +x entrypoint.sh

docker run --rm \
   -v "$(pwd)/.env:/app/.env" \
   --add-host=host.docker.internal:host-gateway \
   -p 8501:8501 \
   robin:latest ui --ui-port 8501 --ui-host 0.0.0.0
```


