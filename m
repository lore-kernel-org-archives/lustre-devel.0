From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Mon, 25 Feb 2008 11:28:48 -0500
Subject: [Lustre-devel] problem starting an mds
In-Reply-To: <Pine.LNX.4.64.0802251004060.9289@ckerner.ncsa.uiuc.edu>
References: <Pine.LNX.4.64.0802251004060.9289@ckerner.ncsa.uiuc.edu>
Message-ID: <1203956928.8507.16.camel@pc.ilinx>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, 2008-02-25 at 10:06 -0600, Chad Kerner wrote:
> Hello,
> 
>  	I have an mds with 16 ost's, when I try to start the MDS, I am 
> getting the following errors in syslog:
> 
> Feb 25 08:44:57 linc-io17  Lustre: 
> 10510:0:(llog_obd.c:160:cat_cancel_cb()) processing log 
> 0x13fd84c:c271bef6 at index 124 of catalog 0x13fd802
> Feb 25 08:44:57 linc-io17  LustreError: 
> 10510:0:(llog_lvfs.c:552:llog_lvfs_create()) error looking up logfile 
> 0x13fd84c:0xc271bef6: rc -2
> Feb 25 08:44:57 linc-io17  LustreError: 
> 10510:0:(llog_cat.c:158:llog_cat_id2handle()) error opening log id 
> 0x13fd84c:c271bef6: rc -2
> Feb 25 08:44:57 linc-io17  LustreError: 
> 10510:0:(llog_obd.c:165:cat_cancel_cb()) Cannot find handle for log 
> 0x13fd84c
> Feb 25 08:44:57 linc-io17  LustreError: 
> 10510:0:(llog_obd.c:232:llog_obd_origin_setup()) llog_process with 
> cat_cancel_cb failed: -2
> Feb 25 08:44:57 linc-io17  LustreError: 
> 10510:0:(lov_log.c:204:lov_llog_init()) error osc_llog_init 0
> Feb 25 08:44:57 linc-io17  LustreError: 
> 10510:0:(mds_log.c:197:mds_llog_init()) error lov_llog_init
> Feb 25 08:44:57 linc-io17  LustreError: 
> 10510:0:(llog_obd.c:322:llog_cat_initialize()) rc: -2
> Feb 25 08:44:57 linc-io17  LustreError: 
> 10510:0:(mds_lov.c:240:mds_lov_connect()) failed to initialize catalog 
> -2

This appears similar to bug 14651.  Caveat that I have not read through
the bug's whole history, but the error messages look the same.  Perhaps
you'd like to read through that bug and see if it applies to you.

b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 189 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080225/a6db8f62/attachment.pgp>
