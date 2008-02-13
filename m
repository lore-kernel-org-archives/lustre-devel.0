From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Wed, 13 Feb 2008 08:41:09 -0800
Subject: [Lustre-devel] lustre client goes wacky?
In-Reply-To: <b1b2daf5-5ad9-4384-b880-1686ee17c167@i29g2000prf.googlegroups.com>
References: <b1b2daf5-5ad9-4384-b880-1686ee17c167@i29g2000prf.googlegroups.com>
Message-ID: <47B31DA5.6050003@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The clients you pulled from CVS have a feature called adaptive timeouts 
which apparently
are having an issue with your 1.6.4.1 servers.  Eric, can you make sure 
our interoperability
is working?

Moving this thread to lustre-discuss; devel is more for 
architecture/coding stuff.

Ron wrote:
> Hi,
> I don't know if this is a bug or it's it's a misconfig or something
> else.
>
> What I have is:
>     server = 1.6.4.1+vanilla 2.6.18.8   (mgs+2*ost+mdt all on a single
> server)
>    clients = cvs.20080116+2.6.23.12
>
> I mounted the server from several clients and several hours later
> noticed the top display below.  dmesg show some lustre errors (also
> below).Can someone comment on what could be going on?
>
> Thanks,
> Ron
>
> top - 18:28:09 up 5 days,  3:36,  1 user,  load average: 12.00, 12.00,
> 11.94
> Tasks: 168 total,  13 running, 136 sleeping,   0 stopped,  19 zombie
> Cpu(s):  0.0% us, 37.5% sy,  0.0% ni, 62.5% id,  0.0% wa,  0.0% hi,
> 0.0% si
> Mem:  16468196k total,   526828k used, 15941368k free,    42996k
> buffers
> Swap:  4192924k total,        0k used,  4192924k free,   294916k
> cached
>
>   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+
> COMMAND
>  1533 root      20   0     0    0    0 R  100  0.0 308:54.05
> ll_cfg_requeue
> 32071 root      20   0     0    0    0 R  100  0.0 308:15.95
> socknal_reaper
> 32073 root      20   0     0    0    0 R  100  0.0 308:48.90
> ptlrpcd
>     1 root      20   0  4832  588  492 R    0  0.0   0:02.48
> init
>     2 root      15  -5     0    0    0 S    0  0.0   0:00.00
> kthreadd
>
>
> Lustre: OBD class driver, info at clusterfs.com
>         Lustre Version: 1.6.4.50
>         Build Version: b1_6-20080210103536-
> CHANGED-.usr.src.linux-2.6.23.12-2.6.23.12
> Lustre: Added LNI 192.168.241.42 at tcp [8/256]
> Lustre: Accept secure, port 988
> Lustre: Lustre Client File System; info at clusterfs.com
> Lustre: Binding irq 17 to CPU 0 with cmd: echo 1 > /proc/irq/17/
> smp_affinity
> Lustre: MGC192.168.241.247 at tcp: Reactivating import
> Lustre: setting import datafs-OST0002_UUID INACTIVE by administrator
> request
> Lustre: datafs-OST0002-osc-ffff810241ad7800.osc: set parameter
> active=0
> LustreError: 32181:0:(lov_obd.c:230:lov_connect_obd()) not connecting
> OSC datafs-OST0002_UUID; administratively disabled
> Lustre: Client datafs-client has started
> Lustre: Request x7684 sent from MGC192.168.241.247 at tcp to NID
> 192.168.241.247 at tcp 15s ago has timed out (limit 15s).
> LustreError: 166-1: MGC192.168.241.247 at tcp: Connection to service MGS
> via nid 192.168.241.247 at tcp was lost; in progress operations using
> this service will fail.
> LustreError: 32073:0:(import.c:212:ptlrpc_invalidate_import()) MGS: rc
> = -110 waiting for callback (1 != 0)
> LustreError: 32073:0:(import.c:216:ptlrpc_invalidate_import()) @@@
> still on sending list  req at ffff81040fa14600 x7684/t0 o400-
>   
>> MGS at 192.168.241.247@tcp:26/25 lens 128/256 e 0 to 11 dl 1202843837
>>     
> ref 1 fl Rpc:EXN/0/0 rc -4/0
> Lustre: Request x7685 sent from datafs-MDT0000-mdc-ffff810241ad7800 to
> NID 192.168.241.247 at tcp 115s ago has timed out (limit 15s).
> Lustre: datafs-MDT0000-mdc-ffff810241ad7800: Connection to service
> datafs-MDT0000 via nid 192.168.241.247 at tcp was lost; in progress
> operations using this service will wait for recovery to complete.
> Lustre: MGC192.168.241.247 at tcp: Reactivating import
> Lustre: MGC192.168.241.247 at tcp: Connection restored to service MGS
> using nid 192.168.241.247 at tcp.
> LustreError: 32059:0:(events.c:116:reply_in_callback()) ASSERTION(ev-
>   
>> mlength == lustre_msg_early_size()) failed
>>     
> LustreError: 32059:0:(tracefile.c:432:libcfs_assertion_failed()) LBUG
>
> Call Trace:
>  [<ffffffff88000b53>] :libcfs:lbug_with_loc+0x73/0xc0
>  [<ffffffff88007bd4>] :libcfs:libcfs_assertion_failed+0x54/0x60
>  [<ffffffff8815c746>] :ptlrpc:reply_in_callback+0x426/0x430
>  [<ffffffff88027f35>] :lnet:lnet_enq_event_locked+0xc5/0xf0
>  [<ffffffff88028475>] :lnet:lnet_finalize+0x1e5/0x270
>  [<ffffffff880625d9>] :ksocklnd:ksocknal_process_receive+0x469/0xab0
>  [<ffffffff88060350>] :ksocklnd:ksocknal_tx_done+0x80/0x1e0
>  [<ffffffff8806301c>] :ksocklnd:ksocknal_scheduler+0x12c/0x7e0
>  [<ffffffff8024e850>] autoremove_wake_function+0x0/0x30
>  [<ffffffff8024e850>] autoremove_wake_function+0x0/0x30
>  [<ffffffff8020c918>] child_rip+0xa/0x12
>  [<ffffffff88062ef0>] :ksocklnd:ksocknal_scheduler+0x0/0x7e0
>  [<ffffffff8020c90e>] child_rip+0x0/0x12
>
> LustreError: dumping log to /tmp/lustre-log.1202843942.32059
> Lustre: Request x7707 sent from MGC192.168.241.247 at tcp to NID
> 192.168.241.247 at tcp 15s ago has timed out (limit 15s).
> Lustre: Skipped 2 previous similar messages
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
