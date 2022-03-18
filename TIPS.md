# Tips 

## Docker

### Clean all images and container

```
  docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)
  docker rmi $(docker images -a -q)
```


## Git

### Delete stale branches

```
git branch | grep -v '^*' | xargs git branch -d
```
