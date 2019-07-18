From: Baptiste Gerondeau <baptiste.gerondeau@linaro.org>
Date: Thu, 18 Jul 2019 12:29:17 +0200
Subject: [lustre-devel] Auster and no facet /usr/sbin/lctl
In-Reply-To: <7AE1C6EF-B45C-4256-A28A-9A5E73C2BBCC@whamcloud.com>
References: <CAPiwApyrJcArje3zYGFdHNff26JUdP7JLu7iK20ymNg4DaU1qQ@mail.gmail.com>
 <7AE1C6EF-B45C-4256-A28A-9A5E73C2BBCC@whamcloud.com>
Message-ID: <CAPiwApzC41YqCCsWzgEHP_OJCtRJ0e8L6LUooY3rtu3vr_=1=g@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thank you very much for your quick help !
I reformatted and remounted everything from scratch and can confirm that
mounting works, and that the client can communicate with the MDS (210, OSS
is 211 and client 212):

[root at x8602 tests]# lnetctl net show
net:
    - net type: lo
      local NI(s):
        - nid: 0 at lo
          status: up
    - net type: tcp
      local NI(s):
        - nid: 10.40.24.212 at tcp
          status: up
          interfaces:
              0: eno1
[root at x8602 tests]# lnetctl peer show -v
peer:
    - primary nid: 10.40.24.210 at tcp
      Multi-Rail: True
      peer ni:
        - nid: 10.40.24.210 at tcp
          state: NA
          max_ni_tx_credits: 8
          available_tx_credits: 8
          min_tx_credits: 6
          tx_q_num_of_buf: 0
          available_rtr_credits: 8
          min_rtr_credits: 8
          refcount: 1
          statistics:
              send_count: 137546
              recv_count: 137545
              drop_count: 0
    - primary nid: 10.40.24.212 at tcp
      Multi-Rail: True
      peer ni:
        - nid: 10.40.24.212 at tcp
          state: NA
          max_ni_tx_credits: 8
          available_tx_credits: 8
          min_tx_credits: -84
          tx_q_num_of_buf: 0
          available_rtr_credits: 8
          min_rtr_credits: 8
          refcount: 1
          statistics:
              send_count: 291726
              recv_count: 291726
              drop_count: 0
    - primary nid: 10.40.24.211 at tcp
      Multi-Rail: True
      peer ni:
        - nid: 10.40.24.211 at tcp
          state: NA
          max_ni_tx_credits: 8
          available_tx_credits: 8
          min_tx_credits: 7
          tx_q_num_of_buf: 0
          available_rtr_credits: 8
          min_rtr_credits: 8
          refcount: 1
          statistics:
              send_count: 56
              recv_count: 56
              drop_count: 0
[root at x8602 tests]# lctl which_nid 10.40.24.210 at tcp
10.40.24.210 at tcp
[root at x8602 tests]# lfs df -ih
UUID                      Inodes       IUsed       IFree IUse% Mounted on
test-MDT0000_UUID           4.0M         272        4.0M   1% /lustre[MDT:0]
test-OST0000_UUID         640.0K         267      639.7K   0% /lustre[OST:0]

filesystem_summary:       640.0K         272      639.7K   0% /lustre

[root at x8602 tests]#  ls -lsah /lustre/
total 12K
4.0K drwxr-xr-x   3 root root 4.0K Jul 18 11:03 .
4.0K dr-xr-xr-x. 19 root root 4.0K Jun 28 11:43 ..
4.0K -rw-r--r--   1 root root   14 Jul 18 11:03 test.txt

I get the same output from auster though:
Client: Lustre version: 2.12.0
MDS: No host defined for facet /usr/sbin/lctl
OSS: Lustre version: 2.12.0

From the client I can ssh into the other nodes (and from each node I can
ssh into the others).
I had tried to debug the scripts behind the above auster output but was
unable to track down where it failed...

On Tue, 16 Jul 2019 at 23:09, Andreas Dilger <adilger@whamcloud.com> wrote:

> On Jul 16, 2019, at 06:11, Baptiste Gerondeau <
> baptiste.gerondeau at linaro.org> wrote:
> >
> > Hi,
> >
> > I'm currently in the process of bringing up the "3 node" x86 cluster and
> running "verbose=true ./auster -f multinode -rsv runtests" (on CentOS 7.6
> x86 client & server, installed from repos), I keep getting "MDS: No host
> defined for facet /usr/sbin/lctl".
> >
> > Auster then prints out some pdsh stuff, "Failures : 0" and exits after
> 16s obviously without running any tests.
> >
> > Any suggestions?
> > Thanks a lot,
> >
> >
> > PS : My multinode config is attached
> > PPS: I posted to the devel list because it concerned auster, if I need
> to post it elsewhere please let me know
>
> Before running auster, which tries to launch a lot of tests, start with
> just a plain mount to see if that is working:
>
> master.sh:
> > MOUNT=/mnt/lustre
> > MOUNT2=/mnt/master2
>
> This is a bit odd for tests, which normally have e.g. /mnt/master and
> /mnt/master2, but I'm
> not sure i there will be a problem or not.
>
> ### assume modules/utils are built
> ### modules/utils are installed or you are running out of the build
> directory
> ### ssh to the MDS and OSS nodes works without a password
> ### if you are not using @tcp0 for LNet, /etc/modprobe.d/lnet.conf is
> correct
>
> all# modprobe ptlrpc            ### on client and OSS and MDS to start LNet
> x8602# lctl ping x86ohpc        ### should print NID(s) of x860hpc
> x8602# lctl ping x8601          ### should print NID(s) of x8601
> x8602# export NAME=master       ### get config from
> lustre/tests/cfg/master.sh
> x8602# sh llmount.sh            ### should format x86ohpc:/dev/sda2 and
> x8601:/dev/sda2
> x8602# lfs df                   ### should show master-MDT0000 and
> master-OST0000
>
> Cheers, Andreas
> --
> Andreas Dilger
> Principal Lustre Architect
> Whamcloud
>
>
>
>
>
>
>

-- 
Baptiste Gerondeau
Engineer - HPC SIG - LDCG - Linaro
#irc : BaptisteGer
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190718/72468e97/attachment.html>
