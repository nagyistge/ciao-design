
# 2. Architecture
## 2.1. Microservices
TODO - Talk about how CIPs are realised as microservices. Although there are no agreed definitions around microservices, need to provide some context and show how the CIP key architectural principles map to it.   

## 2.2. Containers
TODO - Talk about what containers (in the generic sense) are. So would cover traditional application servers, EJB, OSGi, Spring(?) and the newer LXC (Linux Containers) (Docker and Rocket). Need to carefully explain how containers relate to machines/VMs. Talk about models of deploying microservices to containers. Define our model, explain advantages and disadvantages:
*	Container = LXC aka Docker
*	Microservice = Linux application
*	Each microservice is packaged and deployed in a single container

## 2.3. Care Integration Patterns
TODO - Explain the concept of a CIP. Define the key architectural principles CIPs implement and explain why. These will include:
*	Interface Contracts – standard public interface definitions.
*	Dependency Injection – just through configuration e.g. say a CIP needs to persist data to a message queue; then the location and name of that message queue would be a configuration item that is loaded at run time.
*	Monitoring and management – being able to see what the CIP is doing (has done) and provide some external control over at least its lifecycle, but possibly its internal behaviour. Done through interface contracts.
*	Diagnostics – essentially being able to ask a CIP to self-test itself. Done through interface contracts.
*	Composing – being able to wire together different CIPs without the CIPs individually needing to be aware.

## 2.4. Applications
TODO - Talk about composing CIPs into Care apps.

## 2.5. Clouds
TODO - Our containers are deployed to essentially a cloud of real machines or VMs. Talk about the key issues to address at the cloud level (may not be able to actually provide answers for some of these yet as this is the bleeding edge of containers). These will include:
*	Deployment of containers
*	Configuration of containers
*	Monitoring and management of containers
*	Scalability and resilience of containers – this is around having multiple instances of the same container with load balancing in front, and having run policies e.g. I want 5 instances of this container operational at any one time
*	Security – this is perimeter security in and out of the cloud, not necessary at the container to container level – although this is up for debate
*	Composing/wiring containers together
Define our model and explain advantages and disadvantage. This may include going for Kubernetes (though Docker are rolling their own).

## 2.6. Product and Technology Stack
CIAO uses a variety of open source products and technologies. These provide the supporting services and infrastructure needed to run and manage CIPs.

Figure 2.6-1 here.

### 2.6.1. Linux
CIAO needs to run on Linux to be able to use Docker. However as the CIPs are developed in Java they can be run as non-containerised programs on any operating system that provides a JVM. This will require you to find, deploy, configure and manage your own supporting services, rather than using those that have already been bundled with CIAO for use on Linux.

The version of Linux you use must meet the minimum requirements for Docker:

*	64-bit installation
*	kernel must be 3.10 at minimum
  
We are going to use Ubuntu 14.04 LTS (Trusty) for all our examples, but you can use any Linux distribution that meets the Docker requirements.

Each CIAO Linux host must have the following services and applications installed and running:

*	OpenSSH server
*	curl 
*	[etal]

CIAO assumes that all hosts within a CIAO cloud are connected together in a secure network environment, so that network access to and from the CIAO cloud is controlled, but that IP networking between hosts within the CIAO cloud is unrestricted. It is important that all hosts within the CIAO cloud have Internet access so they can connect to Docker Hub to pull down CIAO Docker images.

### 2.6.2. Docker
To use the CIPs packaged as Docker containers you have to install the Docker daemon (Docker Engine) on each Linux host that will be part of a CIAO cloud.

For installation instructions see:

https://docs.docker.com/installation/

For example for Ubuntu Trusty, add a new gpg key:

`$ sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 -- recv-keys 58118E89F3A912897C070ADBF76221572C52609D`

Open the `/etc/apt/sources.list.d/docker.list` file in an editor. If the file doesn’t exist, create it. Add a single entry:

`deb https://apt.dockerproject.org/repo ubuntu-trusty main`

Save and close the `/etc/apt/sources.list.d/docker.list` file. Update the apt package index:

`$ sudo apt-get update`

Install Docker:

`$ sudo apt-get install docker-engine`

Verify Docker is installed correctly:

`$ sudo docker run hello-world`

This command downloads a test image and runs it in a container. When the container runs, it prints an informational message. Then, it exits.

If you are new to Docker, then you can find comprehensive documentation at:

https://docs.docker.com/ 

Some useful Docker commands to know are listed below.

To list all the Docker images on a host:

`$ sudo docker images`

To list all the Docker containers on a host:

`$ sudo docker ps –a`

To list all the running Docker containers on a host:

`$ sudo docker ps` 

To connect a new TTY to a running container:

`$ sudo docker exec –t –i {container name} /bin/bash`

To stop all Docker containers on a host:

`$ sudo docker stop $(sudo docker ps -q)`

To remove all Docker containers on a host:

`$ sudo docker rm $(sudo docker ps -a -q)`
   
To remove all Docker images on a host:

`$ sudo docker rmi $(sudo docker images -q)`

### 2.6.3. etcd
Because CIPs can be deployed in a variety of different ways, there is a need for a consistent way of managing the configuration of CIPs even when they may be distributed across many containers and hosts. There are a number of approaches for managing configuration for distributed cloud solutions, including Zookeeper, Doozer, etcd.

The tool chosen for CIAO is etcd. This provides a lightweight, simple solution which allows configuration to be easily created and accessed via a REST API, and also provides replication to allow each CIP to have its configuration kept in-sync as new instances are created.

etcd has been produced as part of the CoreOS project, and more details can be found on their github page at:

https://github.com/coreos/etcd  

Information about the Docker image of etcd used by CIAO can be found at:

https://github.com/coreos/etcd/blob/master/Documentation/docker_guide.md 

To provide resilience CIAO uses clustered etcd, where two or more etcd instances are clustered together. In an etcd cluster any changes to one cluster member is automatically replicated to the other cluster members (peers).

The etcd Docker image exposes the IP port 2380 to allow etcd peers to talk to each other in an etcd cluster, and the IP ports 2379 and 4001 to allow a client to talk to an etcd instance. By convention CIAO uses 4001. CIAO uses HTTP rather than HTTPS to talk to etcd, which means CIAO assumes it is operating in a secure network environment. 

Figure 2.6-2 here

To create or change a value in etcd within the secure network environment you can use curl to HTTP PUT a key and associated value, for example:

`$ curl -L -X PUT http://localhost:4001/v2/keys/testkey -d value="testvalue"`

To read the value from etcd use curl to HTTP GET the key value, for example:

`$ curl http://localhost:4001/v2/keys/testkey`

The result is returned in JSON format, for example:

`{"action":"get","node":{"key":"/testkey","value":"testvalue","modifiedIndex":10,"createdIndex":10}}`

To test that etcd is replicating content successfully within an etcd cluster curl to HTTP GET the key value from a different etcd cluster member, for example:

`$ curl http:// 10.210.162.28:4001/v2/keys/testkey`

By convention CIAO deploys an etcd instance on each host that runs CIPs as well as the management host. To provide resilience an etcd cluster of at least two members is required. By convention CIAO names the etcd cluster `etcd-cluster-cia`o and names individual etcd instances `etcd-{host moniker}`. The Docker container running etcd is named `ciao-etcd` by convention.

Figure 2.6-3 here

Currently etcd does not provide any monitoring functionality such as JMX. Therefore the only way to monitor the state of the etcd cluster is to monitor the state of each individual etcd Docker container in the cluster to see if it has stopped.

The host to container mappings for the default `ciao-etcd` deployment are:

| Container	port| Host port |
|-----------|------|
| 2379	| 2379 |
| 2380	| 2380 |
| 4001	| 4001 |

To help view and change values in etcd, rather than using curl a web based browser application called etcd-browser can be used. The Docker image for etcd-browser can be found at:

https://hub.docker.com/r/buddho/etcd-browser/ 

The etcd-browser Docker image exposes the IP port 8000 to allow a web browser to connect to it.

Figure 2.6-4 here

By convention CIAO deploys one instance of etc-browser on the management host. The Docker container running etcd-browser is named `ciao-etcdbrowser` by convention.

The host to container mappings for the default `ciao-etcdbrowser` deployment are:

| Container	port| Host port |
|-----------|------|
| 8000	| 7999 |

To connect to etcd-browser you can point your web browser at the URL:

http://{network address of etcd-browser}:7999

The etcd-browser console should be opened as shown below:

Figure here

### 2.6.4. ZooKeeper

ZooKeeper is a centralized service for maintaining configuration information, naming, providing distributed synchronization, and providing group services. CIAO requires it to support the resilient deployment of ActiveMQ as described later and so is a necessary evil (more stuff to be deployed unfortunately).

ZooKeeper is an Apache project, and more details can be found at:

https://zookeeper.apache.org/ 

Information about the Docker image of ZooKeeper used by CIAO can be found at:

https://hub.docker.com/r/jplock/zookeeper/ 

For a reliable ZooKeeper service, ZooKeeper needs to be deployed in a cluster known as an ensemble. As long as a majority of the ensemble are up, the service will be available. Because Zookeeper requires a majority, it is best to use an odd number of hosts.

The ZooKeeper Docker image exposes the IP ports 2888 and 3888 to allow ZooKeeper peers to talk to each other in a ZooKeeper cluster, and the IP port 2181 to allow a client to talk to a ZooKeeper instance. By convention CIAO does not enable ZooKeeper authentication or authorisation but assumes it is operating in a secure network environment.

The ZooKeeper Docker image also provides two data volumes:

`/opt/zookeeper/conf` where configuration files are stored 
`/tmp/zookeeper` where data and log files are stored

Figure 2.6-5 here

You can monitor the health and status of individual ZooKeeper instances by using a set of four letter words that can be sent to the client port using `telnet` or `nc`. For example sending `ruok` checks whether the instance is running without any error. The instance will respond with `imok` if it is running. If the instance is in some error state, it will not respond to this command:
```
$ telnet localhost 2181
Trying ::1...
Connected to localhost.
Escape character is '^]'.
ruok
imokConnection closed by foreign host.
$
```
You can also use the `stat` command to see the status of a ZooKeeper instance:
```
$ telnet localhost 2181
Trying ::1...
Connected to localhost.
Escape character is '^]'.
stat
Zookeeper version: 3.4.6-1569965, built on 02/20/2014 09:09 GMT
Clients:
 /172.17.42.1:33995[0](queued=0,recved=1,sent=0)
 /10.210.162.28:36320[1](queued=0,recved=64369,sent=64376)
 /10.210.162.22:40594[1](queued=0,recved=30075,sent=30075)

Latency min/avg/max: 0/0/56
Received: 94449
Sent: 94455
Connections: 3
Outstanding: 0
Zxid: 0x1900000025
Mode: follower
Node count: 8
Connection closed by foreign host.
$
```
By convention CIAO deploys a ZooKeeper instance on a minimum of three hosts. The Docker container running ZooKeeper is named `ciao-zookeeper` by convention.

Figure 2.6-6 here

The host to container mappings for the default `ciao-zookeeper` deployment are:

| Container	port | Host port |
|-----------|------|
| 2181	| 2181 |
| 2888	| 2888 |
| 3888	| 3888 |

| Container	volume | Host volume |
|-----------|------|
| /opt/zookeeper/conf	| /opt/ciao_zookeeper/conf |
| /tmp/zookeeper	| /var/lib/ciao_zookeeper |

### 2.6.5. ActiveMQ
To ensure resilience of communication between CIPs, CIAO uses persisted messaging. There are a number of open source message brokers available. The product chosen for CIAO is ActiveMQ. This provides a message broker for remote communication between systems using the JMS (Java Message Service) specification.

ActiveMQ is an Apache project, and more details can be found at:

http://activemq.apache.org/ 

Information about the Docker image of ActiveMQ used by CIAO can be found at:

https://hub.docker.com/r/hscic/ciao-activemq/ 

To provide resilience CIAO uses ActiveMQ clustered as Master/Slave. With Master/Slave messages are replicated to a slave broker so that if you have a failure of the master you get immediate failover to the slave with no message loss. The Master/Slave ActiveMQ configuration used by CIAO is the Replicated LevelDB Store. This uses Apache ZooKeeper to pick a master from a set of broker nodes configured to replicate a LevelDB Store (a high performance file based store ActiveMQ implements) and to pick a new master in case of failure. The Replicated LevelDB Store Master/Slave option allows you to have multiple slaves.

The ActiveMQ Docker image exposes the IP port 8161 to allow access to the ActiveMQ web console and the IP port 61616 to allow a client to talk to the ActiveMQ broker using the TCP transport. The IP port 61619 is used for replication within an ActiveMQ cluster. CIAO does not use SSL to secure TCP communication with ActiveMQ which means CIAO assumes it is operating in a secure network environment.

 The ActiveMQ Docker image also provides two data volumes:

`/opt/activemq/conf` where configuration files are stored 
`/opt/activemq/data` where data files are stored

Figure 2.6-7 here

To test that an ActiveMQ broker is running you can point your web browser at the URL:

http://{network address of broker}:8161/admin

The ActiveMQ web console should be opened as shown below. The default login username and password are `admin` and `admin`.

Fidure here

Note that within an ActiveMQ master/slave cluster, only the current master will be running the web console. This can be somewhat frustrating as you need to try and connect to the web console on each member of the cluster until you find a successful connection with the member who is the current master.

By convention CIAO deploys a minimum of three ActiveMQ brokers, one master and two slaves, to provide resilience. By convention CIAO names the ActiveMQ brokers within the cluster `CiaoBroker`. The Docker container running ActiveMQ is named `ciao-activemq` by convention.

Figure 2.6-8 here

ActiveMQ provides monitoring and management capabilities with Java Management Extensions (JMX).

The host to container mappings for the default `ciao-activemq` deployment are:

| Container	port | Host port |
|-----------|------|
| 8161	| 8161 |
| 61616	 | 61616 |
| 61619	| 61619 |

| Container	volume | Host volume |
|-----------|------|
| /opt/activemq/conf	| /opt/ciao_activemq/conf |

