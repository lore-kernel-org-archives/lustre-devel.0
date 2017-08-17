From: Simmons, James A. <simmonsja@ornl.gov>
Date: Thu, 17 Aug 2017 19:57:45 +0000
Subject: [lustre-devel] Lustre on Summitdev
In-Reply-To: <445D4849EC1E0340982C153449289314E666380559@AMASMAI-ED21.main.glb.corp.local>
References: <445D4849EC1E0340982C153449289314E6661BE9A4@AMASMAI-ED21.main.glb.corp.local>
	<CAFZWmxXgtd8szonWKb0UhTfHBVFvQWazmntKYx5x5598bnZdwQ@mail.gmail.com>
	<FED8BDAE-66EE-419B-ABAF-6A3EC1883488@ornl.gov>
	<90FC3FDD-9209-4644-84F0-71F50C408AF4@ornl.gov>
	<BE76047B-D547-488C-8B59-06278326AF2D@ornl.gov>
	<445D4849EC1E0340982C153449289314E666265378@AMASMAI-ED21.main.glb.corp.local>
	<80db2b91-d214-b1ee-aee3-088694b0759f@ornl.gov>
	<6a83013203104b0685a3329b386741f1@EXCHCS32.ornl.gov>
	<E73801F6988F014583395F4FEB057115C03347C458@AMASMAI-ED21.main.glb.corp.local>
	<e2000b2d32004746b85637b48db008bb@EXCHCS32.ornl.gov>
	<E73801F6988F014583395F4FEB057115C03347C583@AMASMAI-ED21.main.glb.corp.local>
	<91303b99ba744c6baba08d57f6fe71da@EXCHCS32.ornl.gov>
	<445D4849EC1E0340982C153449289314E66626560F@AMASMAI-ED21.main.glb.corp.local>
	<c11965aac2e14093bee5ef3265c3a542@EXCHCS32.ornl.gov>
	<E73801F6988F014583395F4FEB057115C03347C84F@AMASMAI-ED21.main.glb.corp.local>
	<85782fcbfc294f4283ba1dd058fb1d94@EXCHCS32.ornl.gov>
	<E73801F6988F014583395F4FEB057115C0334D13D4@AMASMAI-ED21.main.glb.corp.local>
	<090073ac2a76451888737dc755d5f64e@EXCHCS32.ornl.gov>
	<E73801F6988F014583395F4FEB057115C033563600@AMASMAI-ED21.main.glb.corp.local>
	<445D4849EC1E0340982C153449289314E666380559@AMASMAI-ED21.main.glb.corp.local>
Message-ID: <d791bcc86c2b44558cbfb86f891fc49b@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>Hi James,
>
>Are you able to disclose what OS version/stack you?re running on Summitdev where you have Lustre mounted?  Is the machine running Ubuntu?
>
>There seem to be significant pains to get the client working here on the ppcle platform, under RHEL/Centos 7.

Moved this topic to lustre-devel. So my Power8 clients are RHEL7.3. First to make life easy for you please download the latest lustre 2.10 client.

git clone git://git.hpdd.intel.com/fs/lustre/lustre-release
git checkout ?b b2_10 origin/b2_10

The latest has almost all the patches you need. The reason for your build failure is due to the lack of SNMP on the nodes. The lustre spec file
assumes SNMP is always there. This is wrong and I opened a ticket - https://jira.hpdd.intel.com/browse/LU-9870. I created a patch that resolves
this. Just download from here - https://review.whamcloud.com/#/c/28494 and apply. With that you should be able to build your rpms. Now you
try to mount and run into https://jira.hpdd.intel.com/browse/LU-9823 I can?t help you since I don?t have a solution. I do have a patch in the works
to fix several of the config log issues  (LU-7004) which I hope will fix this issue.
From: Russell JONES
Sent: Wednesday, August 09, 2017 4:41 PM
To: 'Simmons, James A.'; Donny COOPER; Leverman, Dustin B.; Mehta, Kshitij V.; Oral, H. Sarp; Hill, Jason J.
Subject: RE: Lustre on Summitdev

No worries about the delay ?

No, not cross compiling. I have been giving it that configure flag because without it, it was not detecting the architecture correctly (gave me an error about attempting to build for big endian when system is little endian). I suppose I should have pointed that out at the beginning, sorry. I had been attempting to resolve these other issues long enough that I honestly forgot I was even adding it in there! This decision and the architecture error was prior to cloning the current lustre tree and applying your patch.

I started over with a clean copy of the source tree again, reapplied your patch, and re-ran autogen and configure with the following flags: ./configure --disable-server --with-o2ib=/usr/src/ofa_kernel/default --disable-tests.

Configure completes as does make. Make rpms errors with:
+ basemodpath=/tmp/rpmbuild-lustre-l0360328-nY6H5CMn/BUILDROOT/lustre-2.10.0_25_gc25132d_dirty-1.ppc64le/lib/modules/3.10.0-514.el7.ppc64le/extra/lustre-client
+ :
+ echo /usr/lib/systemd/system/lnet.service
+ echo /etc/init.d/lsvcgss
+ find /tmp/rpmbuild-lustre-l0360328-nY6H5CMn/BUILDROOT/lustre-2.10.0_25_gc25132d_dirty-1.ppc64le -name '*.so' -type f -exec chmod +x '{}' ';'
+ rm -f /tmp/rpmbuild-lustre-l0360328-nY6H5CMn/BUILDROOT/lustre-2.10.0_25_gc25132d_dirty-1.ppc64le/usr/lib64/liblnetconfig.la
+ echo '%attr(-, root, root) /usr/lib64/liblnetconfig.a'
+ echo '%attr(-, root, root) /usr/lib64/liblnetconfig.so'
+ echo '%attr(-, root, root) /usr/lib64/liblnetconfig.so.*'
+ '[' -d /tmp/rpmbuild-lustre-l0360328-nY6H5CMn/BUILDROOT/lustre-2.10.0_25_gc25132d_dirty-1.ppc64le/usr/lib64/lustre/snmp ']'
+ mkdir -p /tmp/rpmbuild-lustre-l0360328-nY6H5CMn/BUILDROOT/lustre-2.10.0_25_gc25132d_dirty-1.ppc64le//usr/share/lustre
+ find /tmp/rpmbuild-lustre-l0360328-nY6H5CMn/BUILDROOT/lustre-2.10.0_25_gc25132d_dirty-1.ppc64le/usr/lib64/lustre -name '*.la' -type f -exec rm -f '{}' ';'
find: '/tmp/rpmbuild-lustre-l0360328-nY6H5CMn/BUILDROOT/lustre-2.10.0_25_gc25132d_dirty-1.ppc64le/usr/lib64/lustre': No such file or directory
error: Bad exit status from /tmp/rpmbuild-lustre-l0360328-nY6H5CMn/TMP/rpm-tmp.XgLKEM (%install)


From: Simmons, James A. [mailto:simmonsja at ornl.gov]
Sent: Wednesday, August 09, 2017 3:18 PM
To: Russell JONES; Donny COOPER; Leverman, Dustin B.; Mehta, Kshitij V.; Oral, H. Sarp; Hill, Jason J.
Subject: RE: Lustre on Summitdev

>> Did you install libyaml-devel rpm?
>Yes, both libyaml and libyaml-devel are installed.
>
>
>I have successfully cloned and applied the patch without errors. Autogen and configure finish just fine, however a make errors out with:
>gcc -DHAVE_CONFIG_H -I. -I../..  -D_GNU_SOURCE -D_LARGEFILE64_SOURCE=1 -D_FILE_OFFSET_BITS=64 -DLUSTRE_UTILS=1 -include /home/l0360328/lustre->release/undef.h -include /home/l0360328/lustre-release/config.h -I/home/l0360328/lustre-release/libcfs/include -I/home/l0360328/lustre->release/lnet/include -I/home/l0360328/lustre-release/lustre/include -I/home/l0360328/lustre-release/lustre/include/uapi  -fPIC -g -O2 -MT >libcfsutil_a-parser.o -MD -MP -MF .deps/libcfsutil_a-parser.Tpo -c -o libcfsutil_a-parser.o `test -f 'util/parser.c' || echo './'`util/parser.c
>In file included from <command-line>:0:0:
>/usr/include/stdc-predef.h:40:1: fatal error: /home/l0360328/lustre-release/undef.h: No such file or directory
>#endif
?
>Configure line: ./configure --build=ppc64le --disable-server --with-o2ib=/usr/src/ofa_kernel/default --disable-tests

Never tried build=ppc64le. Are you cross compiling? BTW I can reproduce your rpm build issue. That is why I didn?t response right away.  I was attempting to figure out
what is wrong. So basically autoconf is setting your libdir to /usr/lib64 and the rpm macros expect the libraries to be in /usr/lib. I see other projects have had issues
with this before but I didn?t find a good solution yet. It will take me a bit to figure it out.

From: Simmons, James A. [mailto:simmonsja at ornl.gov]
Sent: Tuesday, August 08, 2017 9:20 AM
To: Russell JONES; Donny COOPER; Leverman, Dustin B.; Mehta, Kshitij V.; Oral, H. Sarp; Hill, Jason J.
Subject: RE: Lustre on Summitdev

>James,
>
>When setting the new configuration options I noticed that I didn?t appear to have lnetctl on the system. I found an older bug report that hinted I needed libyaml and libyaml-devel for the binary to get built. Installed those and >ran another rpmbuild, but unfortunately I still didn?t get an RPM created that included that binary.
Did you install libyaml-devel rpm?

>I decided to try the route of patching the source tree to fix LUA-9758 and see if building that route would give me the binary, however I?m still getting the same error with the updated lustre.spec.in downloaded and put in place, >and a make clean, configure, make, make rpms ran. I viewed the new lustre.spec that gets created after configure to make sure your changed lines appear there, and they seem to be there.
Did the patch apply? The reason I ask is that I created that patch against a later lustre 2.10 version. Patches are still landing to the 2.10 branch for the 2.10.1 release. Try the following
git clone git://git.hpdd.intel.com/fs/lustre-release
git checkout ?b b2_10 origin/b2_10
Then apply the LU-9758 patch and with libyaml-devel installed try a build.

>I know this discussion is getting a bit long and technical, if there?s a better place to continue it (devel list or bug tracker?) I?ll be happy to move to wherever is more convenient for you.
I?m fine where ever the discuss takes place.

From: Simmons, James A. [mailto:simmonsja at ornl.gov]
Sent: Monday, August 07, 2017 4:19 PM
To: Donny COOPER; Russell JONES; Leverman, Dustin B.; Mehta, Kshitij V.; Oral, H. Sarp; Hill, Jason J.
Subject: RE: Lustre on Summitdev


>James,
>
>Is the configuration of OLCF Lustre filesystem that is connecting to the Summitdev (ppcle64) machine using mlx5 -> mlx5 on both Lustre client and server?

Is not so much a mlx4 vs mlx5 driver issue but what the hardware supports.  So here is the correct technical explanation of what is going. IB hardware support
something called queue pairs. How deep the queue pair can go depends on the hardware. In our testbed the back end file system I was testing with, which
does have mlx4 based hardware, could support a queue depth of 64K. This is also true of our production file system storage back end. This setup allows us
to set our lnet peer credits to 63. The Power8 nodes Mellanox hardware in our testbed has a maximum queue pair depth of 32K. Because of this I couldn?t
push the lnet peer credits to 63. So what I did to get around that is turn on map_on_demand. The map_on_demand option in ko2iblnd turns on RDMA
transfers. This helped me to support the 63 peer credits I wanted on the Power8 nodes but it exposed a problem due to different page sizes. That is what
caused me some headaches.  Now for our Summitdev machine its hardware, even with it using the mlx5 driver, doesn?t seem to have problems with our
back end production file system.  So how this will impact you will depend on your setup.  You just have to try and see with the LNet peer_credits you
are using.

From: Simmons, James A. [mailto:simmonsja at ornl.gov]
Sent: Monday, August 07, 2017 3:20 PM
To: Russell JONES <russell.jones at external.total.com<mailto:russell.jones@external.total.com>>; Leverman, Dustin B. <leverman at ornl.gov<mailto:leverman@ornl.gov>>; Donny COOPER <donny.cooper at total.com<mailto:donny.cooper@total.com>>; Mehta, Kshitij V. <mehtakv at ornl.gov<mailto:mehtakv@ornl.gov>>; Oral, H. Sarp <oralhs at ornl.gov<mailto:oralhs@ornl.gov>>; Hill, Jason J. <hilljj at ornl.gov<mailto:hilljj@ornl.gov>>
Subject: RE: Lustre on Summitdev

>Thanks for the feedback!
>Yes we do have a mlx5 -> mlx4 connection in play, our lustre servers are mlx4.
>
>I will start work on getting the configuration put into place you recommended.
You might still have issues mounting due the LU-9823 bug. I collected the debug log but it is going to take some time for me to figure out what is wrong.
As for the mlx5 <-> mlx4 if you have trouble, if you manage to get around LU-9823,  let me know and I can help you with that.

From: Simmons, James A. [mailto:simmonsja at ornl.gov]
Sent: Monday, August 07, 2017 2:18 PM
To: Russell JONES; Leverman, Dustin B.; Donny COOPER; Mehta, Kshitij V.; Oral, H. Sarp; Hill, Jason J.
Subject: RE: Lustre on Summitdev

>Hi all,
>
>Appreciate the assistance! Here?s a quick overview of what we are experiencing, and then further answers inline below.
>
>If we do a simple rpmbuild against the 2.10 source RPM, the build completes and I am able to modprobe the lustre module and issue a mount command against our Lustre filesystem. However as soon as I do that, or >attempt any writes, we begin getting the following errors recorded in /var/log/messages on the node, and the filesystem is unusable from this client:
>
>Aug  7 13:32:49 p8eval kernel: Lustre: Lustre: Build Version: 2.10.0
>Aug  7 13:32:49 p8eval kernel: LNet: Added LNI 172.40.120.231 at o2ib4<mailto:172.40.120.231@o2ib4> [8/256/0/180]
>Aug  7 13:33:06 p8eval kernel: Lustre: 61690:0:(client.c:2114:ptlrpc_expire_one_request()) @@@ Request sent has timed out for slow reply: [sent >1502130781/real 1502130781]  req at c000000fd85e0300 x1575098273234960/t0(0) o250->MGC172.40.2.60 at o2ib4@172.40.2.60 at o2ib4:26/25<mailto:MGC172.40.2.60 at o2ib4@172.40.2.60@o2ib4:26/25> lens 520/544 e 0 to >.1 dl 1502130786 ref 1 fl Rpc:XN/0/ffffffff rc 0/-1
>Aug  7 13:33:07 p8eval kernel: LustreError: 61858:0:(mgc_request.c:251:do_config_log_add()) MGC172.40.2.60 at o2ib4<mailto:MGC172.40.2.60@o2ib4>: failed processing log, type 1: >rc = -5
>Aug  7 13:33:26 p8eval kernel: Lustre: Server MGS version (2.5.42.8) is much older than client. Consider upgrading server (2.10.0)
>Aug  7 13:33:26 p8eval kernel: Lustre: Mounted lustre4-client
>Aug  7 13:33:31 p8eval kernel: Lustre: 61690:0:(client.c:2114:ptlrpc_expire_one_request()) @@@ Request sent has timed out for slow reply: [sent >1502130806/real 1502130806]  req at c000000fdb620300 x1575098273235408/t0(0) o8->lustre4-OST0006-osc-c000001e3c4e9000 at 172.40.2.62@o2ib4:28/4<mailto:lustre4-OST0006-osc-c000001e3c4e9000@172.40.2.62@o2ib4:28/4> lens >520/544 e 0 to 1 dl 1502130811 ref 1 fl Rpc:XN/0/ffffffff rc 0/-1
>
I know this bug. I can reproduce it on the Cray ARM machine.  I haven?t fix it yet since I can?t reproduce this one on a x86 platform.
The ticket URL is https://jira.hpdd.intel.com/browse/LU-9823. I will look to collect some debug logs today on the ARM machine to
track it down.

>If I attempt to build from the source .tar.gz with the following configure flags, the configure and make complete, however ?make rpms? gets an error:
>
>./configure --disable-tests --disable-server --with-linux=/usr/src/kernels/3.10.0-514.el7.ppc64le/ --with-o2ib=/usr/src/ofa_kernel/default -->target=ppc64le
>
>+ basemodpath=/tmp/rpmbuild-lustre-root-dLLJioYr/BUILDROOT/lustre-2.10.0-1.ppc64le/lib/modules/3.10.0-514.el7.ppc64le/extra/lustre-client
>+ :
>+ echo /usr/lib/systemd/system/lnet.service
>+ echo /etc/init.d/lsvcgss
>+ find /tmp/rpmbuild-lustre-root-dLLJioYr/BUILDROOT/lustre-2.10.0-1.ppc64le -name '*.so' -type f -exec chmod +x '{}' ';'
>+ '[' -d /tmp/rpmbuild-lustre-root-dLLJioYr/BUILDROOT/lustre-2.10.0-1.ppc64le/usr/lib64/lustre/snmp ']'
>+ mkdir -p /tmp/rpmbuild-lustre-root-dLLJioYr/BUILDROOT/lustre-2.10.0-1.ppc64le//usr/share/lustre
>+ find /tmp/rpmbuild-lustre-root-dLLJioYr/BUILDROOT/lustre-2.10.0-1.ppc64le/usr/lib64/lustre -name '*.la' -type f -exec rm -f '{}' ';'
>find: '/tmp/rpmbuild-lustre-root-dLLJioYr/BUILDROOT/lustre-2.10.0-1.ppc64le/usr/lib64/lustre': No such file or directory
>error: Bad exit status from /tmp/rpmbuild-lustre-root-dLLJioYr/TMP/rpm-tmp.QuU8wT (%install)
>
>RPM build errors:
>    Bad exit status from /tmp/rpmbuild-lustre-root-dLLJioYr/TMP/rpm-tmp.QuU8wT (%install)

I know this one since I fixed it ?  That is LU-9758 and I have a patch for 2.10 already. Just waiting to land. You can get it here:

https://review.whamcloud.com/#/c/28372

>> Is lnet running over InfiniBand interfaces? If so, is it using the mlx4 or mlx5 driver
>
>Yes, here?s the output of lustre.conf:
>
>[root at p8eval modprobe.d]# cat lustre.conf
>options lnet networks=o2ib4(ib0)

>> Also what OFED stack are you running?  Are you using the Lustre 2.10 or 2.8 client?

>Mellanox OFED 3.4, and attempting to use 2.9 and 2.10, same errors for both versions. The version of lustre on the servers is 2.5.

This one is a but more complicated. If by default the queue pair depth is too small. You will need to create the following file:

/etc/modprobe.d/ib_mad.conf

With the following:

# Module parameters for infiniband core to increase queue pair size

options ib_mad send_queue_size=4096

options ib_mad recv_queue_size=4096

Now for the LNet configurate. Please don?t use the modprobe config file lustre.conf. That is deprecated. You should be using lnetctl.

First you need a /etc/sysconfig/lnet.conf  file. Something like this.



-------------------------------------------------

net:

    - net: o2ib6

      status: up

      interfaces:

          0: ib0

          lnd tunables:

              peercredits_hiw: 63

              #map_on_demand: 16

              concurrent_sends: 31

              fmr_pool_size: 1280

              fmr_flush_trigger: 1024

              fmr_cache: 1

      tunables:

          peer_timeout: 180

          peer_credits: 63

          peer_buffer_credits: 0

          credits: 2560

route:

    - net: o2ib

      gateway: 10.39.232.10 at o2ib6<mailto:10.39.232.10@o2ib6>

      hop: 1

      priority: 0

    - net: o2ib

      gateway: 10.39.232.11 at o2ib6<mailto:10.39.232.11@o2ib6>

      hop: 1

      priority: 0



Once you have that file you need to run the following command:



modprobe lnet; lnetctl lnet configure; lnetctl import < /etc/sysconfig/lnet.conf



Now if you have a mlx4 <-> mlx5 connection then you will have problems with page size difference between x86 and PPC. Is that the case for you?

Let me know because in that case it will take some more magic to get it working. Hope that helps. Hmmm. I need to create a wiki for this on lustre.org.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170817/6643d5c2/attachment-0001.htm>
