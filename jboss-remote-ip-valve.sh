#!/bin/bash
# config for reverse proxy

profile=full

/profile=$profile/subsystem=web/valve=remoteip-valve:add(module=org.jboss.as.web, class-name=org.apache.catalina.valves.RemoteIpValve, parameters=[protocolHeader=x-forwarded-proto, remoteIpHeader=x-forwarded-for])

