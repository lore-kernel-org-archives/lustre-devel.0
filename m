From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Fri, 4 Mar 2011 09:21:38 +0300
Subject: [Lustre-devel] lustre 1.8+ issues with automounter
In-Reply-To: <4D7082DF.2040705@gmail.com>
References: <4D706F39.2070807@gmail.com>
	<FD878C30-2103-400A-A02D-C3745DBEBF1F@xyratex.com>
	<4D7082DF.2040705@gmail.com>
Message-ID: <6BA20898-9773-4E43-A697-C31C0A2C00E4@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

if you can add "df " call after mounting lustre fs - it will also help.

On Mar 4, 2011, at 09:12, Jeremy Filizetti wrote:

> An example is below with some comments and a handful of the log
> removed.  I don't actually have this many OSTs but I just created a lot
> of OSTs to easily reproduce the problem in a VM.  autofs is setup to
> mount lustre.  The autofs attempts to mount the file system when I typed
> "ls -l  /lustre/xen1/tmp/testfile" where testfile is allocated on the
> 192nd OST IIRC.
> 
> Mount kicked off by the above command by the automounter.
> 00000020:01200004:2:1298954011.295906:0:8398:0:(obd_mount.c:2001:lustre_fill_super())
> VFS Op: sb ffff8801e7e22c00
> 00000020:01000004:2:1298954011.295920:0:8398:0:(obd_mount.c:2015:lustre_fill_super())
> Mounting client xen1-client
> 00000080:00200000:2:1298954011.301889:0:8398:0:(llite_lib.c:1017:ll_fill_super())
> VFS Op: sb ffff8801e7e22c00
> 00000080:01000000:2:1298954011.431273:0:8398:0:(llite_lib.c:1115:ll_fill_super())
> Found profile xen1-client: mdc=xen1-MDT0000-mdc osc=xen1-clilov
> 00000080:00000010:2:1298954011.431274:0:8398:0:(llite_lib.c:1118:ll_fill_super())
> kmalloced 'osc': 29 at ffff8801e7efd9a0.
> 00000080:00000010:2:1298954011.431276:0:8398:0:(llite_lib.c:1124:ll_fill_super())
> kmalloced 'mdc': 34 at ffff8801dcb56ec0.
> 00000080:00000010:2:1298954011.431277:0:8398:0:(llite_lib.c:267:client_common_fill_super())
> kmalloced 'data': 72 at ffff8801e9deedc0.
> 00000080:00100000:2:1298954011.432116:0:8398:0:(llite_lib.c:409:client_common_fill_super())
> ocd_connect_flags: 0xe1440478 ocd_version: 17302784 ocd_grant: 0
> 00020000:01000000:1:1298954011.432928:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST0000_UUID active
> 00020000:01000000:1:1298954011.432977:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST0002_UUID active
> 00020000:01000000:1:1298954011.433025:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST0004_UUID active
> .
> .
> .
> 00020000:01000000:2:1298954011.455806:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST0094_UUID active
> 00020000:01000000:2:1298954011.455924:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST0095_UUID active
> 00020000:01000000:2:1298954011.456042:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST0096_UUID active
> 00020000:01000000:2:1298954011.456161:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST0097_UUID active
> 00020000:01000000:2:1298954011.457417:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST0098_UUID active
> 00000080:00000004:1:1298954011.457543:0:8398:0:(llite_lib.c:467:client_common_fill_super())
> rootfid 16:[0x10:0xababf859:0x4000]
> 00020000:01000000:2:1298954011.457573:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST0099_UUID active
> 00020000:01000000:2:1298954011.457705:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST009a_UUID active
> 00000080:00000010:1:1298954011.457830:0:8398:0:(super25.c:57:ll_alloc_inode())
> slab-alloced '(lli)': 928 at ffff8801e0de4bc0.
> 00020000:01000000:2:1298954011.457855:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST009b_UUID active
> 00000080:00000010:1:1298954011.457938:0:8398:0:(llite_lib.c:528:client_common_fill_super())
> kfreed 'data': 72 at ffff8801e9deedc0.
> 00000080:00000010:1:1298954011.457977:0:8398:0:(llite_lib.c:1151:ll_fill_super())
> kfreed 'mdc': 34 at ffff8801dcb56ec0.
> 00000080:00000010:1:1298954011.457979:0:8398:0:(llite_lib.c:1153:ll_fill_super())
> kfreed 'osc': 29 at ffff8801e7efd9a0.
> 00000080:02000400:1:1298954011.457979:0:8398:0:(llite_lib.c:1157:ll_fill_super())
> Client xen1-client has started
> 00000020:00000004:1:1298954011.457980:0:8398:0:(obd_mount.c:2053:lustre_fill_super())
> Mount 192.168.66.2 at tcp8:/xen1 complete
> 
> We just returned from filling the super block so now the file system is
> accessible, but as you can see by the lov_set_osc_active not all OSC's
> have been set active yet.
> 
> 00020000:01000000:2:1298954011.457981:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST009c_UUID active
> 00020000:01000000:2:1298954011.458108:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST009d_UUID active
> .
> .
> .
> 00020000:01000000:2:1298954011.460053:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST00ac_UUID active
> 00020000:01000000:2:1298954011.460187:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST00ad_UUID active
> 00000080:00000010:1:1298954011.461272:0:8395:0:(super25.c:57:ll_alloc_inode())
> slab-alloced '(lli)': 928 at ffff8801e0de4800.
> 00020000:01000000:2:1298954011.461487:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST00ae_UUID active
> 00000080:00000010:1:1298954011.461589:0:8395:0:(super25.c:57:ll_alloc_inode())
> slab-alloced '(lli)': 928 at ffff8801e0de4440.
> 00000080:00010000:1:1298954011.461624:0:8395:0:(file.c:965:ll_glimpse_size())
> Glimpsing inode 218
> 00000080:00020000:1:1298954011.461636:0:8395:0:(file.c:995:ll_glimpse_size())
> obd_enqueue returned rc -5, returning -EIO
> 
> Now glimpsing the inode from above that is allocated on xen-OST00bf
> which is not yet active so the set is empty and returns -EIO.
> 
> 00020000:01000000:2:1298954011.461644:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST00af_UUID active
> 00020000:01000000:2:1298954011.461782:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST00b0_UUID active
> .
> .
> .
> 00020000:01000000:2:1298954011.463766:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST00be_UUID active
> 00020000:01000000:2:1298954011.463911:0:11545:0:(lov_obd.c:570:lov_set_osc_active())
> Marking OSC xen1-OST00bf_UUID active
> 
> Finally the last OSC is set active, this is where
> client_common_fill_super should, ll_fill_super, lustre_fill_super should
> return from the mount syscall because the file system is now all accessible.
> 
> I will take a look at your suggestion below tomorrow to see if it will
> handle this situate.
> 
> 
> Thanks,
> Jeremy
> 
>> you patch is wrong in case some OSC targets will be inaccessible (in maintenance, or network troubles).
>> In that case lov_connect will stick in waiting for infinity time, but that is don't expected behavior. 
>> Can you provide more details about what is situation confuses automount ?
>> or try to move
>>>> 
>>        err = obd_statfs(obd, &osfs, cfs_time_current_64() - HZ, 0);                                                                  
>>        if (err)                                                                                                                      
>>                GOTO(out_mdc, err);                                                                                                   
>>>> 
>> from current location to something after get root fid.
>> 
>> if FS mounted without lazystatfs option, obd_statfs will blocked until all connection requests is finished.
>> so you will have same behavior but without changes in obd_connect() code.
> 

______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
