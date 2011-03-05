From: Ravi <raviprakashdrbh@aol.com>
Date: Sat, 5 Mar 2011 13:51:01 -0500 (EST)
Subject: [Lustre-devel] LNetPoll  undefined
In-Reply-To: <7E84F671-5637-4253-95BB-6999A17F3C4E@whamcloud.com>
References: <8CDA8EC0A0C0017-A90-CEFA@webmail-d097.sysops.aol.com>
	<7E84F671-5637-4253-95BB-6999A17F3C4E@whamcloud.com>
Message-ID: <8CDA97D68228C90-21C-11D97@webmail-m099.sysops.aol.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


 Hello 
Thanks for the reply.I am  using lustre-1.8.1.1 .I am working on a new module which  is used for some kind of delegation operations.I am using Lnet operations in this  module.


The code which fails is  
 do {
                        rc = LNetEQWait(lnet_eq_hd, &ev);
                      if( ev.type == LNET_EVENT_PUT )
                               break;

                } while ( rc != 0);
                



Here i am waiting on some PUT event from a client and then break from the loop.And do some operations accordingly.But next time when i perform some PUT operation (for example) and it gets logged into  the event queue i try reading from that event but the MDS fails.
I also tried using these functions  //rc = LNetEQPoll( &lnet_eq_hd, 1,2000, &ev, &which); in place of LNetEQWait  but it says undefined .

Can you please throw some light on eq_callback function as i havnt found it in Lnet manual to go through.
                                              

The log before crashing shows :


Mar  4 20:35:08 ws11 kernel:     type=LNET_EVENT_SEND, pt-idx=53, mbits=0x1234abcd, rlen=64, mlen=64, md.user_ptr=0xaaaabbbb, hdr-data=0x0
Mar  4 20:35:08 ws11 kernel:     status=0, unlnk=0, offset=0, seq=2 

//Iam asssuming it fails here as till here it prints fine.I also want to mention that  this operation is successful as well. 


Mar  4 20:35:27 ws11 kernel: BUG: soft lockup - CPU#0 stuck for 10s! [insmod:4609]
Mar  4 20:35:27 ws11 kernel: CPU 0:
Mar  4 20:35:27 ws11 kernel: Modules linked in: tmod(U) ksocklnd(U) ko2iblnd(FU) lnet(U) libcfs(U) autofs4(U) hidp(U) nfs(U) fscache(U) nfs_acl(U) rfcomm(U) l2cap(U) bluetooth(U) lockd(U) sunrpc(U) cpufreq_ondemand(U) acpi_cpufreq(U) freq_table(U) ip_conntrack_netbios_ns(U) ipt_REJECT(U) xt_state(U) ip_conntrack(U) nfnetlink(U) iptable_filter(U) ip_tables(U) ip6t_REJECT(U) xt_tcpudp(U) ip6table_filter(U) ip6_tables(U) x_tables(U) rdma_ucm(U) ib_sdp(U) rdma_cm(U) iw_cm(U) ib_addr(U) ib_ipoib(U) ipoib_helper(U) ib_cm(U) ib_sa(U) ipv6(U) xfrm_nalgo(U) crypto_api(U) ib_uverbs(U) ib_umad(U) mlx4_en(U) mlx4_ib(U) mlx4_core(U) loop(U) dm_multipath(U) scsi_dh(U) video(U) hwmon(U) backlight(U) sbs(U) i2c_ec(U) button(U) battery(U) asus_acpi(U) acpi_memhotplug(U) ac(U) lp(U) snd_hda_intel(U) snd_seq_dummy(U) snd_seq_oss(U) snd_seq_midi_event(U) snd_seq(U) snd_seq_device(U) snd_pcm_oss(U) snd_mixer_oss(U) ib_mthca(U) snd_pcm(U) snd_timer(U) snd_page_alloc(U) ib_mad(U) snd_hwdep(U) snd(U) sg(U) ib_core(U) e100(U) ide_cd(
Mar  4 20:35:27 ws11 kernel: ) mii(U) serio_raw(U) pcspkr(U) i2c_i801(U) cdrom(U) soundcore(U) parport_pc(U) shpchp(U) i2c_core(U) parport(U) dm_raid45(U) dm_message(U) dm_region_hash(U) dm_mem_cache(U) dm_snapshot(U) dm_zero(U) dm_mirror(U) dm_log(U) dm_mod(U) ata_piix(U) libata(U) sd_mod(U) scsi_mod(U) ext3(U) jbd(U) uhci_hcd(U) ohci_hcd(U) ehci_hcd(U)
Mar  4 20:35:27 ws11 kernel: Pid: 4609, comm: insmod Tainted: GF     2.6.18-128.7.1.el5-lustre.1.8.1.1smp-cust #2
Mar  4 20:35:27 ws11 kernel: RIP: 0010:[<ffffffff80064c54>]  [<ffffffff80064c54>] .text.lock.spinlock+0x2/0x30
Mar  4 20:35:27 ws11 kernel: RSP: 0018:ffff810021099d10  EFLAGS: 00000286
Mar  4 20:35:27 ws11 kernel: RAX: 0000000000000002 RBX: 00000000ffffffff RCX: ffff810021099df8
Mar  4 20:35:27 ws11 kernel: RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffff8888a7a0
Mar  4 20:35:27 ws11 kernel: RBP: ffff81003a04e1c0 R08: ffff810021099ddc R09: 000000001234abcd
.......




 I hope this helps 

Thanks  





 

 

-----Original Message-----
From: Liang Zhen <liang@whamcloud.com>
To: Ravi <raviprakashdrbh@aol.com>
Cc: lustre-devel <lustre-devel@lists.lustre.org>
Sent: Fri, Mar 4, 2011 8:54 pm
Subject: Re: [Lustre-devel] LNetPoll  undefined


Hi Ravi,


Which version of Lustre/LNet are you trying with? Are you trying to build some new code over LNet? Could you show us some example code if you don't mind?
btw, If you are trying this in kernel space, I would suggest to use eq_callback (LNetEQAlloc(...eq_callback)) instead of LNetEQPoll/LNetEQWait, which is better for performance. Polling is not good for performance because all EQs share one single waitq in LNet. 


Regards
Liang


On Mar 5, 2011, at 9:30 AM, Ravi wrote:


Hello 

I am using LNetWait (blocking call ) on a particular event .After i recevie this event i break from the loop which waits for this event and proceed  but when another event is added into the event queue the system crashes.I thought LNetPoll would be better as  i can just  poll for that particular event without disturbing the event queue but when i make i get undefined.Any thoughts .

 

 Thanks 
Ravi 



_______________________________________________
Lustre-devel mailing list
Lustre-devel at lists.lustre.org
http://lists.lustre.org/mailman/listinfo/lustre-devel



 
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110305/b936f694/attachment.htm>
