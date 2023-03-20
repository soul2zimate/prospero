#!/bin/sh -x

#
# Copyright 2023 Red Hat, Inc. and/or its affiliates
# and other contributors as indicated by the @author tags.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if [ "x$COMMON_CONF" = "x" ]; then
  COMMON_CONF="$DIRNAME/common.conf"
else
  if [ ! -r "$COMMON_CONF" ]; then
    echo "Config file not found $COMMON_CONF"
  fi

fi
if [ -r "$COMMON_CONF" ]; then
  . "$COMMON_CONF"
fi

setModularJdk() {
  "$JAVA" --add-modules=java.se -version > /dev/null 2>&1 && MODULAR_JDK=true || MODULAR_JDK=false
}

setDefaultModularJvmOptions() {
  setModularJdk
  if [ "$MODULAR_JDK" = "true" ]; then
    DEFAULT_MODULAR_JVM_OPTIONS=`echo $* | $GREP "\--add-modules"`
    if [ "x$DEFAULT_MODULAR_JVM_OPTIONS" = "x" ]; then
      # Set default modular jdk options
      # NB: In case an update is made to these exports and opens, make sure that bootable-jar/boot/pom.xml script is in sync.
      # Needed by the iiop-openjdk subsystem
      DEFAULT_MODULAR_JVM_OPTIONS="$DEFAULT_MODULAR_JVM_OPTIONS --add-exports=java.desktop/sun.awt=ALL-UNNAMED"
      # Needed to instantiate the default InitialContextFactory implementation used by the
      # Elytron subsystem dir-context and core management ldap-connection resources
      DEFAULT_MODULAR_JVM_OPTIONS="$DEFAULT_MODULAR_JVM_OPTIONS --add-exports=java.naming/com.sun.jndi.ldap=ALL-UNNAMED"
      # Needed if Hibernate applications use Javassist
      DEFAULT_MODULAR_JVM_OPTIONS="$DEFAULT_MODULAR_JVM_OPTIONS --add-opens=java.base/java.lang=ALL-UNNAMED"
      # Needed by the MicroProfile REST Client subsystem
      DEFAULT_MODULAR_JVM_OPTIONS="$DEFAULT_MODULAR_JVM_OPTIONS --add-opens=java.base/java.lang.invoke=ALL-UNNAMED"
      # Needed for marshalling of proxies
      DEFAULT_MODULAR_JVM_OPTIONS="$DEFAULT_MODULAR_JVM_OPTIONS --add-opens=java.base/java.lang.reflect=ALL-UNNAMED"
      # Needed by JBoss Marshalling
      DEFAULT_MODULAR_JVM_OPTIONS="$DEFAULT_MODULAR_JVM_OPTIONS --add-opens=java.base/java.io=ALL-UNNAMED"
      # Needed by WildFly Security Manager
      DEFAULT_MODULAR_JVM_OPTIONS="$DEFAULT_MODULAR_JVM_OPTIONS --add-opens=java.base/java.security=ALL-UNNAMED"
      # Needed for marshalling of collections
      DEFAULT_MODULAR_JVM_OPTIONS="$DEFAULT_MODULAR_JVM_OPTIONS --add-opens=java.base/java.util=ALL-UNNAMED"
      # Needed for marshalling of concurrent collections
      DEFAULT_MODULAR_JVM_OPTIONS="$DEFAULT_MODULAR_JVM_OPTIONS --add-opens=java.base/java.util.concurrent=ALL-UNNAMED"
      # EE integration with sar mbeans requires deep reflection in javax.management
      DEFAULT_MODULAR_JVM_OPTIONS="$DEFAULT_MODULAR_JVM_OPTIONS --add-opens=java.management/javax.management=ALL-UNNAMED"
      # InitialContext proxy generation requires deep reflection in javax.naming
      DEFAULT_MODULAR_JVM_OPTIONS="$DEFAULT_MODULAR_JVM_OPTIONS --add-opens=java.naming/javax.naming=ALL-UNNAMED"
    else
      DEFAULT_MODULAR_JVM_OPTIONS=""
    fi
  fi
}
