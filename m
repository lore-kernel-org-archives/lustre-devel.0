From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 16 Jul 2019 21:09:53 +0000
Subject: [lustre-devel] Auster and no facet /usr/sbin/lctl
In-Reply-To: <CAPiwApyrJcArje3zYGFdHNff26JUdP7JLu7iK20ymNg4DaU1qQ@mail.gmail.com>
References: <CAPiwApyrJcArje3zYGFdHNff26JUdP7JLu7iK20ymNg4DaU1qQ@mail.gmail.com>
Message-ID: <7AE1C6EF-B45C-4256-A28A-9A5E73C2BBCC@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 16, 2019, at 06:11, Baptiste Gerondeau <baptiste.gerondeau@linaro.org> wrote:
> 
> Hi,
> 
> I'm currently in the process of bringing up the "3 node" x86 cluster and running "verbose=true ./auster -f multinode -rsv runtests" (on CentOS 7.6 x86 client & server, installed from repos), I keep getting "MDS: No host defined for facet /usr/sbin/lctl".
> 
> Auster then prints out some pdsh stuff, "Failures : 0" and exits after 16s obviously without running any tests.
> 
> Any suggestions?
> Thanks a lot,
> 
> 
> PS : My multinode config is attached
> PPS: I posted to the devel list because it concerned auster, if I need to post it elsewhere please let me know

Before running auster, which tries to launch a lot of tests, start with just a plain mount to see if that is working:

master.sh:
> MOUNT=/mnt/lustre
> MOUNT2=/mnt/master2

This is a bit odd for tests, which normally have e.g. /mnt/master and /mnt/master2, but I'm
not sure i there will be a problem or not.

### assume modules/utils are built
### modules/utils are installed or you are running out of the build directory
### ssh to the MDS and OSS nodes works without a password
### if you are not using @tcp0 for LNet, /etc/modprobe.d/lnet.conf is correct

all# modprobe ptlrpc		### on client and OSS and MDS to start LNet
x8602# lctl ping x86ohpc	### should print NID(s) of x860hpc
x8602# lctl ping x8601		### should print NID(s) of x8601
x8602# export NAME=master	### get config from lustre/tests/cfg/master.sh
x8602# sh llmount.sh		### should format x86ohpc:/dev/sda2 and x8601:/dev/sda2
x8602# lfs df			### should show master-MDT0000 and master-OST0000

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud
