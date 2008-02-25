From: Chad Kerner <ckerner@ncsa.uiuc.edu>
Date: Mon, 25 Feb 2008 10:06:16 -0600 (CST)
Subject: [Lustre-devel] problem starting an mds
Message-ID: <Pine.LNX.4.64.0802251004060.9289@ckerner.ncsa.uiuc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

 	I have an mds with 16 ost's, when I try to start the MDS, I am 
getting the following errors in syslog:

Feb 25 08:44:57 linc-io17  Lustre: 
10510:0:(llog_obd.c:160:cat_cancel_cb()) processing log 
0x13fd84c:c271bef6 at index 124 of catalog 0x13fd802
Feb 25 08:44:57 linc-io17  LustreError: 
10510:0:(llog_lvfs.c:552:llog_lvfs_create()) error looking up logfile 
0x13fd84c:0xc271bef6: rc -2
Feb 25 08:44:57 linc-io17  LustreError: 
10510:0:(llog_cat.c:158:llog_cat_id2handle()) error opening log id 
0x13fd84c:c271bef6: rc -2
Feb 25 08:44:57 linc-io17  LustreError: 
10510:0:(llog_obd.c:165:cat_cancel_cb()) Cannot find handle for log 
0x13fd84c
Feb 25 08:44:57 linc-io17  LustreError: 
10510:0:(llog_obd.c:232:llog_obd_origin_setup()) llog_process with 
cat_cancel_cb failed: -2
Feb 25 08:44:57 linc-io17  LustreError: 
10510:0:(lov_log.c:204:lov_llog_init()) error osc_llog_init 0
Feb 25 08:44:57 linc-io17  LustreError: 
10510:0:(mds_log.c:197:mds_llog_init()) error lov_llog_init
Feb 25 08:44:57 linc-io17  LustreError: 
10510:0:(llog_obd.c:322:llog_cat_initialize()) rc: -2
Feb 25 08:44:57 linc-io17  LustreError: 
10510:0:(mds_lov.c:240:mds_lov_connect()) failed to initialize catalog 
-2


Was wondering if anyone else had seen a similar problem or had any 
places I should start looking.

Thanks,
Chad
--
Chad Kerner - ckerner at ncsa.uiuc.edu
Systems Engineer, Storage Enabling Technologies
National Center for Supercomputing Applications
http://www.ncsa.uiuc.edu/~ckerner
