From: Reto Gantenbein <reto.gantenbein@id.unibe.ch>
Date: Sun, 31 Aug 2008 04:58:49 +0200
Subject: [Lustre-devel] [Lustre-discuss] Mount error with message: "Err
	-22 on cfg command:"
In-Reply-To: <09581767-DAEC-4F9B-91A1-FC674EA851C5@id.unibe.ch>
References: <09581767-DAEC-4F9B-91A1-FC674EA851C5@id.unibe.ch>
Message-ID: <BE802F6D-2982-4860-83BD-B2C7F7E2F41C@id.unibe.ch>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dear Lustre users and developers

I couldn't find a solution to work around this problem. So I was  
hoping that restarting the MGS/MDT would be a good try. But I was  
definitely wrong. When trying to remote the MGS/MDT device I got the  
same error:

Aug 31 03:27:59 lustre01 LDISKFS FS on sde, internal journal
Aug 31 03:27:59 lustre01 LDISKFS-fs: recovery complete.
Aug 31 03:27:59 lustre01 LDISKFS-fs: mounted filesystem with ordered  
data mode.
Aug 31 03:27:59 lustre01 kjournald starting.  Commit interval 5 seconds
Aug 31 03:27:59 lustre01 LDISKFS FS on sde, internal journal
Aug 31 03:27:59 lustre01 LDISKFS-fs: mounted filesystem with ordered  
data mode.
Aug 31 03:27:59 lustre01 Lustre: MGS MGS started
Aug 31 03:27:59 lustre01 Lustre: Enabling user_xattr
Aug 31 03:27:59 lustre01 Lustre: 6934:0:(mds_fs.c: 
446:mds_init_server_data()) RECOVERY: service homefs-MDT0000, 26  
recoverable clients, last_transno 5217310552
Aug 31 03:27:59 lustre01 Lustre: MDT homefs-MDT0000 now serving dev  
(homefs-MDT0000/983b4a03-68de-a879-44c3-b91decd23fba), but will be in  
recovery until 26 clients reconnect, or if no clients reconnect for  
4:10; during that time new clients will not be allowed to connect.  
Recovery progress can be monitored by watching /proc/fs/lustre/mds/ 
homefs-MDT0000/recovery_status.
Aug 31 03:27:59 lustre01 Lustre: 6934:0:(lproc_mds.c: 
260:lprocfs_wr_group_upcall()) homefs-MDT0000: group upcall set to / 
usr/sbin/l_getgroups
Aug 31 03:27:59 lustre01 Lustre: homefs-MDT0000.mdt: set parameter  
group_upcall=/usr/sbin/l_getgroups
Aug 31 03:27:59 lustre01 Lustre: 6934:0:(mds_lov.c:858:mds_notify())  
MDS homefs-MDT0000: in recovery, not resetting orphans on homefs- 
OST0001_UUID
Aug 31 03:27:59 lustre01 Lustre: 6934:0:(mds_lov.c:858:mds_notify())  
MDS homefs-MDT0000: in recovery, not resetting orphans on homefs- 
OST0004_UUID
Aug 31 03:27:59 lustre01 LustreError: 6842:0:(events.c: 
55:request_out_callback()) @@@ type 4, status -5  req at ffff81011b56a400  
x11/t0 o8->homefs-OST0003_UUID at 10.1.140.2@tcp:6 lens 240/272 ref 2 fl  
Rpc:/0/0 rc 0/-22
Aug 31 03:27:59 lustre01 LustreError: 6842:0:(client.c: 
975:ptlrpc_expire_one_request()) @@@ network error (sent at  
1220146079, 0s ago)  req at ffff81011b56a400 x11/t0 o8->homefs-OST0003_UUID at 10.1.140.2 
@tcp:6 lens 240/272 ref 1 fl Rpc:/0/0 rc 0/-22
Aug 31 03:27:59 lustre01 LustreError: 6842:0:(events.c: 
55:request_out_callback()) @@@ type 4, status -5  req at ffff81011b5bfa00  
x13/t0 o8->homefs-OST0006_UUID at 10.1.140.2@tcp:6 lens 240/272 ref 2 fl  
Rpc:/0/0 rc 0/-22
Aug 31 03:27:59 lustre01 LustreError: 6842:0:(client.c: 
975:ptlrpc_expire_one_request()) @@@ network error (sent at  
1220146079, 0s ago)  req at ffff81011b5bfa00 x13/t0 o8->homefs-OST0006_UUID at 10.1.140.2 
@tcp:6 lens 240/272 ref 1 fl Rpc:/0/0 rc 0/-22
Aug 31 03:27:59 lustre01 LustreError: 6934:0:(obd_config.c: 
897:class_process_proc_param()) homefs-OST0002-osc: unknown param  
activate=0
Aug 31 03:27:59 lustre01 LustreError: 6934:0:(obd_config.c: 
1062:class_config_llog_handler()) Err -22 on cfg command:
Aug 31 03:27:59 lustre01 Lustre:    cmd=cf00f 0:homefs-OST0002-osc   
1:osc.activate=0
Aug 31 03:27:59 lustre01 LustreError: 15b-f: MGC10.1.140.2 at tcp: The  
configuration from log 'homefs-MDT0000' failed (-22). Make sure this  
client and the MGS are running compatible versions of Lustre.
Aug 31 03:27:59 lustre01 LustreError: 15c-8: MGC10.1.140.2 at tcp: The  
configuration from log 'homefs-MDT0000' failed (-22). This may be the  
result of communication errors between this node and the MGS, a bad  
configuration, or other errors. See the syslog for more information.
Aug 31 03:27:59 lustre01 LustreError: 6934:0:(obd_mount.c: 
1080:server_start_targets()) failed to start server homefs-MDT0000: -22
Aug 31 03:27:59 lustre01 LustreError: 6934:0:(obd_mount.c: 
1570:server_fill_super()) Unable to start targets: -22
Aug 31 03:27:59 lustre01 Lustre: Failing over homefs-MDT0000
Aug 31 03:27:59 lustre01 Lustre: *** setting obd homefs-MDT0000 device  
'unknown-block(8,64)' read-only ***
Aug 31 03:27:59 lustre01 Turning device sde (0x800040) read-only
Aug 31 03:27:59 lustre01 Lustre: MGS has stopped.

Still here the -22 (unknown parameter -> homefs-OST0002-osc: unknown  
param activate=0) error is haunting me. WTF?! Where does this comes  
from? It doesn't make any sense to me. When trying to mount the MGS/ 
MDT device a second time I get a kernel soft-lockup:

Aug 31 03:34:32 lustre01 LustreError: 7456:0:(mgs_handler.c: 
150:mgs_setup()) ASSERTION(!lvfs_check_rdonly(lvfs_sbdev(mnt- 
 >mnt_sb))) failed
Aug 31 03:34:32 lustre01 LustreError: 7456:0:(tracefile.c: 
431:libcfs_assertion_failed()) LBUG
Aug 31 03:34:32 lustre01 Lustre: 7456:0:(linux-debug.c: 
168:libcfs_debug_dumpstack()) showing stack for process 7456
Aug 31 03:34:32 lustre01 mount.lustre  R  running task       0  7456    
7455                     (NOTLB)
Aug 31 03:34:32 lustre01 ffff810077c9d598 000000000000000c  
0000000000009c72 0000000000000004
Aug 31 03:34:32 lustre01 0000000000000004 0000000000000000  
0000000000009c55 0000000000000004
Aug 31 03:34:32 lustre01 0000000000000018 ffff81011c54c180  
0000000000000000 00000000ffffffff
Aug 31 03:34:32 lustre01 Call Trace:
Aug 31 03:34:32 lustre01 [<ffffffff80249faa>] module_text_address+0x3a/ 
0x50
Aug 31 03:34:32 lustre01 [<ffffffff80240ada>] kernel_text_address+0x1a/ 
0x30
Aug 31 03:34:32 lustre01 [<ffffffff80240ada>] kernel_text_address+0x1a/ 
0x30
Aug 31 03:34:32 lustre01 [<ffffffff8020b3ba>] show_trace+0x20a/0x240
Aug 31 03:34:32 lustre01 [<ffffffff8020b4fb>] _show_stack+0xeb/0x100
Aug 31 03:34:32 lustre01 [<ffffffff880869fa>] :libcfs:lbug_with_loc 
+0x7a/0xc0
Aug 31 03:34:32 lustre01  
[<ffffffff8808e724>] :libcfs:libcfs_assertion_failed+0x54/0x60
Aug 31 03:34:32 lustre01 [<ffffffff88307a71>] :mgs:cleanup_module 
+0xa71/0x2470
Aug 31 03:34:32 lustre01  
[<ffffffff880f05cd>] :obdclass:class_new_export+0x52d/0x5b0
Aug 31 03:34:32 lustre01 [<ffffffff88105cdb>] :obdclass:class_setup 
+0x8bb/0xbe0
Aug 31 03:34:32 lustre01  
[<ffffffff8810836a>] :obdclass:class_process_config+0x14ca/0x19f0
Aug 31 03:34:32 lustre01 [<ffffffff88112d94>] :obdclass:do_lcfg 
+0x9d4/0x15f0
Aug 31 03:34:32 lustre01 [<ffffffff8042b475>] scsi_disk_put+0x35/0x50
Aug 31 03:34:32 lustre01  
[<ffffffff88114bd0>] :obdclass:lustre_common_put_super+0x1220/0x6890
Aug 31 03:34:32 lustre01  
[<ffffffff88119a3f>] :obdclass:lustre_common_put_super+0x608f/0x6890
Aug 31 03:34:32 lustre01 [<ffffffff80293405>] __d_lookup+0x85/0x120
Aug 31 03:34:32 lustre01 [<ffffffff88086f48>] :libcfs:cfs_alloc 
+0x28/0x60
Aug 31 03:34:32 lustre01 [<ffffffff8810d8bf>] :obdclass:lustre_init_lsi 
+0x29f/0x660
Aug 31 03:34:32 lustre01  
[<ffffffff8811a240>] :obdclass:lustre_fill_super+0x0/0x1ae0
Aug 31 03:34:32 lustre01  
[<ffffffff8811bba3>] :obdclass:lustre_fill_super+0x1963/0x1ae0
Aug 31 03:34:32 lustre01 [<ffffffff802822d0>] set_anon_super+0x0/0xc0
Aug 31 03:34:32 lustre01  
[<ffffffff8811a240>] :obdclass:lustre_fill_super+0x0/0x1ae0
Aug 31 03:34:32 lustre01 [<ffffffff80282583>] get_sb_nodev+0x63/0xe0
Aug 31 03:34:32 lustre01 [<ffffffff80281d62>] vfs_kern_mount+0x62/0xb0
Aug 31 03:34:32 lustre01 [<ffffffff80281e0a>] do_kern_mount+0x4a/0x80
Aug 31 03:34:32 lustre01 [<ffffffff8029955d>] do_mount+0x6cd/0x770
Aug 31 03:34:32 lustre01 [<ffffffff80260cb2>] __handle_mm_fault 
+0x5e2/0xa30
Aug 31 03:34:32 lustre01 [<ffffffff80384c21>] __up_read+0x21/0xb0
Aug 31 03:34:32 lustre01 [<ffffffff8021bae7>] do_page_fault+0x447/0x820
Aug 31 03:34:32 lustre01 [<ffffffff8025a006>] release_pages+0x186/0x1a0
Aug 31 03:34:32 lustre01 [<ffffffff8025da33>] zone_statistics+0x33/0x90
Aug 31 03:34:32 lustre01 [<ffffffff8025774b>] __get_free_pages+0x1b/0x40
Aug 31 03:34:32 lustre01 [<ffffffff8029969b>] sys_mount+0x9b/0x100
Aug 31 03:34:32 lustre01 [<ffffffff80209cf2>] system_call+0x7e/0x83

Is there some kind of log that is replayed when mounting the MGS/MDT?  
Can I clear it to be able to mount the device again? Or is this just  
an annoying bug? At the moment the entire file system is down. Is  
there a way to bring it back online or do I have to reformat it?

Any help/hints/advice would be appreciated. I really cannot see where  
I made a mistake.

Kind regards,
Reto Gantenbein



On Aug 29, 2008, at 3:12 PM, Reto Gantenbein wrote:

> Dear Lustre users
>
> Some days ago we had a problem that four OSTs were disconnecting
> themselves. To recover, I deactivated them with 'lctl conf_param
> homefs-OST0002.osc.active=0', remounted them and waited until they
> were recovered and activated them again. Some hosts which kept the
> Lustre file system mounted at this time, resumed to work correctly on
> the paused devices.
>
> But when I want to mount Lustre with on a new client:
>
> node01 ~ # mount -t lustre lustre01 at tcp:lustre02 at tcp:/homefs /home
>
>  it refuses with the following message:
>
> LustreError: 3794:0:(obd_config.c:897:class_process_proc_param())
> homefs-OST0002-osc-ffff81022f630000: unknown param activate=0
> LustreError: 3794:0:(obd_config.c:1062:class_config_llog_handler())
> Err -22 on cfg command:
> Lustre:    cmd=cf00f 0:homefs-OST0002-osc  1:osc.activate=0
> LustreError: 15b-f: MGC10.1.140.1 at tcp: The configuration from log
> 'homefs-client' failed (-22). Make sure this client and the MGS are
> running compatible versions of Lustre.
> LustreError: 15c-8: MGC10.1.140.1 at tcp: The configuration from log
> 'homefs-client' failed (-22). This may be the result of communication
> errors between this node and the MGS, a bad configuration, or other
> errors. See the syslog for more information.
> LustreError: 3794:0:(llite_lib.c:1021:ll_fill_super()) Unable to
> process log: -22
> LustreError: 3794:0:(mdc_request.c:1273:mdc_precleanup()) client
> import never connected
> LustreError: 3794:0:(connection.c:142:ptlrpc_put_connection()) NULL
> connection
> Lustre: client ffff81022f630000 umount complete
> LustreError: 3794:0:(obd_mount.c:1924:lustre_fill_super()) Unable to
> mount  (-22)
>
> There are no wrong parameters because the same command did work on all
> the previous attempts. Also there is no connection problem between the
> hosts:
>
> lctl > peer_list
> 12345-10.1.140.1 at tcp [1]node01->lustre01:988 #6
> 12345-10.1.140.2 at tcp [1]node01->lustre02:988 #6
>
> Why does this cfg command error arise? homefs-OST0002 is properly
> mounted on the lustre-server and is fully working with the other
> clients, as far as I can say. Any hints about this or anything I can
> do to troubleshoot this problem?
>
> Kind regards,
> Reto Gantenbein
>
>
>
>
> _______________________________________________
> Lustre-discuss mailing list
> Lustre-discuss at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-discuss

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080831/f2831003/attachment.htm>
