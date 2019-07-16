From: Baptiste Gerondeau <baptiste.gerondeau@linaro.org>
Date: Tue, 16 Jul 2019 14:11:19 +0200
Subject: [lustre-devel] Auster and no facet /usr/sbin/lctl
Message-ID: <CAPiwApyrJcArje3zYGFdHNff26JUdP7JLu7iK20ymNg4DaU1qQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I'm currently in the process of bringing up the "3 node" x86 cluster and
running "verbose=true ./auster -f multinode -rsv runtests" (on CentOS 7.6
x86 client & server, installed from repos), I keep getting "MDS: No host
defined for facet /usr/sbin/lctl".

Auster then prints out some pdsh stuff, "Failures : 0" and exits after 16s
obviously without running any tests.

Any suggestions?
Thanks a lot,


PS : My multinode config is attached
PPS: I posted to the devel list because it concerned auster, if I need to
post it elsewhere please let me know
-- 
Baptiste Gerondeau
Engineer - HPC SIG - LDCG - Linaro
#irc : BaptisteGer
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190716/d4740c3f/attachment.html>
-------------- next part --------------
[root at x8602 tests]# cat cfg/multinode.sh 
FSNAME=master
FSTYPE=ldiskfs
MOUNT=/mnt/lustre
MOUNT2=/mnt/master2
# MDS and MDT configuration
MDSCOUNT=1

mds_HOST="x86ohpc"
mgs_HOST="x86ohpc"
mdt_HOST="x86ohpc"
MDSDEV1="/dev/sda2"

# OSS and OST configuration
OSTCOUNT=1

ost_HOST="x8601"
OSTDEV1="/dev/sda2"

# Client configuration
CLIENTCOUNT=1
RCLIENTS="x8602"

export PDSH_SSH_ARGS_APPEND="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /root/.ssh/cluster"
PDSH="/usr/bin/pdsh -l root -S -Rssh -d -w"

SHARED_DIRECTORY=${SHARED_DIRECTORY:-/opt/ohpc/pub}
