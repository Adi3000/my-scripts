# WSL Tips: 

If you'r also in trouble with `DOCKER_HOST tcp://localhost:2375 is not listening` on test container while `telnet localhost 2375` is responding, it may be because forwarded traffic through WSL go through `[::1]` not through `127.0.0.1`.

On testcontainers, Java is resolving ip through domain name. So localhost may be resolved by IPv4 instead of IPv6.

To check that, just test on windows 
```
telnet 127.0.0.1 2375
telnet ::1 2375
```
And use the one which produce a black screen. 


```
DOCKER_HOST=tcp://[::1]:2375
 
# or
 
DOCKER_HOST=tcp://127.0.0.1:2375
```

If you get a message : 
```
org.testcontainers.utility.RyukResourceReaper - Can not connect to Ryuk at localhost:49173
```

you can add this variable to specify ipv4 internal Testcontainers network :
```
TESTCONTAINERS_HOST_OVERRIDE=127.0.0.1
```
