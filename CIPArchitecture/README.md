# CIP Architecture

Explain the concept of a CIP. Define the key architectural principles CIPs implement and explain why. These will include:
* Interface Contracts - standard public interface definitions.
* Dependency Injection - just through configuration e.g. say a CIP needs to persist data to a message queue; then the location and name of that message queue would be a configuration item that is loaded at run time.
* Configuration Management - managing the configuration for CIPs
* Monitoring and management - being able to see what the CIP is doing (has done) and provide some external control over at least its lifecycle, but possibly its internal behaviour. Done through interface contracts.
* Diagnostics - essentially being able to ask a CIP to self-test itself. Done through interface contracts.

# Configuration Management

Because CIPs can be deployed in a variety of different ways (see deployment
section), there is a need for a consistent way of managing the configuration of
CIPs even when they may be distributed across many containers. There are a
number of approaches for managing configuration for distributed cloud solutions,
including Zookeeper, Doozer, etcd.

The tool chosed for CIAO is etcd. This provides a lightweight, simple solution
which allows configuration to be easily created and accessed via a REST API, and
also provides replication to allow each CIP to have it's configuration kept
in-sync as new instances are created.

etcd has been produced as part of the CoreOS project, and more details can be
found on their [github page](https://github.com/coreos/etcd).

## CIAO Configuration Naming Conventions

All configuration in etcd is in the form of key-value pairs, and is created in
a simple hierarchical directory structure. The convention used in CIAO is as
follows:

`/ciao/<cipname>/<version>`

Within this directory, all CIPs will have a key called "version", which stores
the version of the CIP that is running.

## Specifying the etcd URL

A CIP will need to be able to find the etcd URL in order to access it's
configuration. The URL can be provided as a command line parameter when the
CIP is started, this should be in the form:

`--etcdURL http://127.0.0.1:4001`

**TODO:** Clarify how this would work in an OSGi container.

## Running without etcd

If you are unable to use etcd for some reason (or choose not to), CIPs will
fall-back on local configuration files. These will by default be saved in the
user's home directory in the path:

`~/.ciao/<cipname>-<version>.properties`

An alternative path can be specified as a command line parameter when starting
the CIP if required, this should be in the form:

`--configPath /etc/ciao`

Obviously, the use of config files will mean that configuration will need to
be managed individually on all running instances - there is no mechanism for
keeping these configuration files in-sync.

## Installing etcd

In a standard CIAO deployment, etcd would be deployed onto each machine a
docker container, alongside the CIPs on that machine (see deployment section).

If the CIP will be run in a different environment (e.g. within an OSGi container
or natively), then etcd can be installed manually - see the
[etcd github page](https://github.com/coreos/etcd)
for details on how to do this.

NOTE - etcd is currently only supported on 64bit machines. It may be possible to
compile a 32bit version from source, but this is not trivial.

## First-time CIP execution

The first time a CIP is run, it will attempt to connect to the etcd URL provided.
If it is able to connect, it will check whether configuration already exists for
this CIP. It will do this by looking for the `/ciao/<cipname>/version` key. If
config already exists, it will be used immediately. If no config exists, a
default set of configuration values will be added to the etcd repository.
If the CIP is unable to connect to the provided URL, an error will be returned.

If no etcd URL is provided, the CIP will look for a local configuration file
(as described above). If a config file path is used, the CIP will look in that
path, otherwise it will look in the home path (as described above).
If a config file is found, it will be used, and if not, a default
configuration file will be created.

## Using in CIPs

As all CIPs will require the above configuration capabilities, a common CIAO
code library has been created for this, which all CIPs can use. This is called
ciao-configuration, and is available as a project in the
[ciao-utils repository](https://github.com/nhs-ciao/ciao-utils)

