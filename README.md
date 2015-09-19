# Dreams of Websockets

At Stockflare, we use this docker container to enable Websocket connections through [AWS Elastic Load Balancers](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-elb.html).

The container uses [confd]() for a one-time configuration of Nginx when the container starts, using environment variables. The Nginx configuration file is written to work in conjunction with an Elastic Load Balancer, itself using [ProxyProtocol](http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/enable-proxy-protocol.html).

## Usage

The container requires the presence of three environment variables. These variables will be used to configure Nginx when the container starts.

**Note:** The resulting configuration is checked for validity.

| Env | Purpose |
|---|---|
| `LISTEN_ON` | Determines which port Nginx will listen on |
| `DESTINATION_HOSTNAME` | The hostname to proxy traffic to. This should typically be the name of the linked docker container (explained below) |
| `DESTINATION_PORT` | The port to proxy traffic to on the destination container |

## Brief Example

Lets say that we have the following container running on a host:

```
docker run -p 45490:45490 -n app -d my_websocket_application
```

To enable this container to proxy traffic to that application, we would run the following command:

```
docker run --link app:app \
           -p 45400:45400 \
           -e LISTEN_ON=45400 \
           -e DESTINATION_HOSTNAME=app \
           -e DESTINATION_PORT=45490 \
           -d stockflare/nginx-elb-websocket
```

This container would then start listening to traffic on port `45400`, forwarding it to your application container on port `45490`.

If you were running these containers on EC2 hosts that were part of a load balanced auto scaling group, the load balancer would be configured with the aforementioned `ProxyProtocol` on port `45400`, complete with listeners forwarding `TCP` type traffic to port `45400`.

The container also provides a naive health check for ELBs located at `/ping`.

## Why is this needed?

Out-of-the-box, ELBs do not support Websockets and therefore require an additional proxy for which the connections must be negotiated through. There exist many blog posts on the internet, documenting the process for what we've done here. We wanted to create a more _generic_ and _complete_ approach to this. Below are some of the resources that we used:

* [Web Apps: WebSockets with AWS Elastic Load Balancing](http://blog.flux7.com/web-apps-websockets-with-aws-elastic-load-balancing)
* [Load-balancing Websockets on EC2](https://medium.com/@Philmod/load-balancing-websockets-on-ec2-1da94584a5e9)
* [600k concurrent websocket connections on AWS using Node.js](http://www.jayway.com/2015/04/13/600k-concurrent-websocket-connections-on-aws-using-node-js/)
* [Load balancing WebSockets with ELB and nginx on EC2](http://blog.seafuj.com/using-elb-with-websockets)
