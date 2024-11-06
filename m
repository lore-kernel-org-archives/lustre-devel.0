Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E7CC2D3E788
	for <lustre-devel@archiver.kernel.org>; Wed,  6 Nov 2024 04:20:56 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4XjsPn1xxcz1xPS;
	Tue, 05 Nov 2024 20:18:05 -0800 (PST)
Received: from mail-il1-f174.google.com (mail-il1-f174.google.com
 [209.85.166.174])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4XjsPb5zhsz1wj3; Tue, 05 Nov 2024 20:17:55 -0800 (PST)
Received: by mail-il1-f174.google.com with SMTP id
 e9e14a558f8ab-3a4e5e57678so1563785ab.1; 
 Tue, 05 Nov 2024 20:17:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1730866650; x=1731471450; darn=lists.lustre.org;
 h=to:subject:message-id:date:from:in-reply-to:references:mime-version
 :from:to:cc:subject:date:message-id:reply-to;
 bh=Hnq/1W7E15Ef3yaUel91fniL6xuJnk+NIDHzFBAlMbM=;
 b=BKLIkT7/siJBXqGkOVbwJfots1PDfYAkt74kgU2zzOeZmPpvlAb+Nu3Gd4jKth1hw9
 L0c/A9Z5IYu5rpUOaKBQX5eQbnU9cl8jyGEv1otI0qVUpNH9aFx8ikpzT1XkOJG3uTBA
 u8m3pKbEH3e22VDbmlpnZtoG9LSx48JSE0G898/Au/obGzQQk45DR4FrkIHTrTZ+w5RQ
 sNwcIS7y04QNQdNMxv/p58mfgukvCQsmfuzw0BRyfKFuoFiJn5SJr4cGkllx/+qAMEX8
 jMfbqHM/Ag7yOZ3vV2iTPOHj2Ed9kZrVyn5F2NZqxpiOmQfaiV8DC3i7LsWViTBmFUN9
 l5+w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1730866650; x=1731471450;
 h=to:subject:message-id:date:from:in-reply-to:references:mime-version
 :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=Hnq/1W7E15Ef3yaUel91fniL6xuJnk+NIDHzFBAlMbM=;
 b=bmHgf9Ub8jWXk/nsOVf1VXxWNtAFYU+afngggosF+t1X4rJuRcycG7gS1csKyxmSh6
 3E5CsbInJ4VvuHK8eJzi4aQKqy3E18vckZfe4AAkKbjxU+8ZGHi7TFBG3YQAFCnT3oqy
 q3/Qn0khP9Is+6662s/HfEfv0BuHE7NEHTAMdqvjq9Y1j5I5PbivR/9F/QTOhIQiMQKy
 28QXjkzvUCltFr4qus1ycGP40qATBNnz5OSzh5da/+TGuVbOM1G1PndEcVfy5V+PuYa/
 4hS53snPLPZrEfkOnzxCHMOjgi0CmdBh8zHvnkeSUNuTw9nypfTy3uwl7yyJUXDPPgPR
 gyyQ==
X-Forwarded-Encrypted: i=1;
 AJvYcCWXAVL4TN407Yskkw+PTKM+moeEQgqhuvdIywCbhJYGc8i6bNtbyxrKXrnEhwFNo2xvusKIOZNb3mkjCBM=@lists.lustre.org
X-Gm-Message-State: AOJu0YwHyG5tq+E5QUzZE2ay/Fh3c+gEB3zLPteUhp3DrYAwdUeD0UD/
 Ym5NpQx1hgJmeSYsJhLHSpr4JAqi56itpH6dKak5UL614SRprKyIzjXhoLsnY9PHHX7TQ3OYbfI
 Ozru/U9nln7qnywUx4cPpAFih6/1dLZor
X-Google-Smtp-Source: AGHT+IFnVw+OH+80lbAK6sRIQjSFDJ5eH+ADwuWq1ymXRMXBCKhrLa21ZF8vwO56FiPia45nLwoyYZojS5APdMIRoOM=
X-Received: by 2002:a05:6e02:1d03:b0:3a6:aade:5644 with SMTP id
 e9e14a558f8ab-3a6e2a2893fmr9460115ab.4.1730866650254; Tue, 05 Nov 2024
 20:17:30 -0800 (PST)
MIME-Version: 1.0
References: <CAPq+oA+JR=CxnOQ-ERto7DMW7QuyMo6xuqa5CxGjPUE2xZwb+g@mail.gmail.com>
In-Reply-To: <CAPq+oA+JR=CxnOQ-ERto7DMW7QuyMo6xuqa5CxGjPUE2xZwb+g@mail.gmail.com>
From: Backer <backer.kolo@gmail.com>
Date: Tue, 5 Nov 2024 23:17:19 -0500
Message-ID: <CAPq+oA+h8bcHMQ70r2_i88G4D+Yukz0BFfw_aH1egwwrzyxfCA@mail.gmail.com>
To: Backer via lustre-discuss <lustre-discuss@lists.lustre.org>,
 lustre-devel@lists.lustre.org
Subject: Re: [lustre-devel] Lustre switching to loop back lnet interface
 when it is not desired
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============0112822163646792900=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0112822163646792900==
Content-Type: multipart/alternative; boundary="000000000000d79544062636cb53"

--000000000000d79544062636cb53
Content-Type: text/plain; charset="UTF-8"

The import is showing the following though the OST is formatted with
failover.node=10.99.100.152
or service mode =10.99.100.152

    connection:
       failover_nids: [ 0@lo, 0@lo ]
       current_connection: 0@lo



On Tue, 5 Nov 2024 at 12:34, Backer <backer.kolo@gmail.com> wrote:

> Hi,
>
> Mounting the Lustre file file system on the OSS. Some of the OSTs are
> locally attached to the OSS.
>
> The failover IP on the OST is "10.99.100.152". It is a local lnet on the
> OSS. However, when the client mounts it, the import automatically changes
> to 0@lo. It is undesirable here because when this OST fails over to
> another server, the client is still trying to connect to 0@lo while it is
> no longer on the same host. This makes the client fs mount hangs for ever.
>
> Here the failover is designed in such a way that the IP address moves
> (fails over) with OST and becomes active on the other server.
>
> How can I make the import pointing to the real IP and not the loopback?
> (so that the failover works)
>
>
> [oss000 ~]$ lfs df
> UUID                   1K-blocks        Used   Available Use% Mounted on
> fs-MDT0000_UUID     29068444       25692    26422344   1% /mnt/fs[MDT:0]
> fs-OST0000_UUID     50541812    30160292    17743696  63% /mnt/fs[OST:0]
> fs-OST0001_UUID     50541812    29301740    18602248  62% /mnt/fs[OST:1]
> fs-OST0002_UUID     50541812    29356508    18547480  62% /mnt/fs[OST:2]
> fs-OST0003_UUID     50541812     8822980    39081008  19% /mnt/fs[OST:3]
>
> filesystem_summary:    202167248    97641520    93974432  51% /mnt/fs
>
> [oss000 ~]$ df -h
> Filesystem                  Size  Used Avail Use% Mounted on
> devtmpfs                     30G     0   30G   0% /dev
> tmpfs                        30G  8.1M   30G   1% /dev/shm
> tmpfs                        30G   25M   30G   1% /run
> tmpfs                        30G     0   30G   0% /sys/fs/cgroup
> /dev/mapper/ocivolume-root   36G   17G   19G  48% /
> /dev/sdc2                  1014M  637M  378M  63% /boot
> /dev/mapper/ocivolume-oled   10G  2.5G  7.6G  25% /var/oled
> /dev/sdc1                   100M  5.1M   95M   6% /boot/efi
> tmpfs                       5.9G     0  5.9G   0% /run/user/987
> tmpfs                       5.9G     0  5.9G   0% /run/user/0
> /dev/sdb                     49G   28G   18G  62% /fs-OST0001
> /dev/sda                     49G   29G   17G  63% /fs-OST0000
> tmpfs                       5.9G     0  5.9G   0% /run/user/1000
> 10.99.100.221@tcp1:/fs  193G   94G   90G  51% /mnt/fs
>
> [oss000 ~]$ sudo tunefs.lustre --dryrun /dev/sda
> checking for existing Lustre data: found
>
>    Read previous values:
> Target:     fs-OST0000
> Index:      0
> Lustre FS:  fs
> Mount type: ldiskfs
> Flags:      0x1002
>               (OST no_primnode )
> Persistent mount opts: ,errors=remount-ro
> Parameters: mgsnode=10.99.100.221@tcp1 failover.node=10.99.100.152@tcp1
> ,10.99.100.152@tcp1
>
>
>    Permanent disk data:
> Target:     fs-OST0000
> Index:      0
> Lustre FS:  fs
> Mount type: ldiskfs
> Flags:      0x1002
>               (OST no_primnode )
> Persistent mount opts: ,errors=remount-ro
> Parameters: mgsnode=10.99.100.221@tcp1 failover.node=10.99.100.152@tcp1
> ,10.99.100.152@tcp1
>
> exiting before disk write.
>
>
> [oss000 proc]# cat
> /proc/fs/lustre/osc/fs-OST0000-osc-ffff89c57672e000/import
> import:
>     name: fs-OST0000-osc-ffff89c57672e000
>     target: fs-OST0000_UUID
>     state: IDLE
>     connect_flags: [ write_grant, server_lock, version, request_portal,
> max_byte_per_rpc, early_lock_cancel, adaptive_timeouts, lru_resize,
> alt_checksum_algorithm, fid_is_enabled, version_recovery, grant_shrink,
> full20, layout_lock, 64bithash, object_max_bytes, jobstats, einprogress,
> grant_param, lvb_type, short_io, lfsck, bulk_mbits, second_flags,
> lockaheadv2, increasing_xid, client_encryption, lseek, reply_mbits ]
>     connect_data:
>        flags: 0xa0425af2e3440078
>        instance: 39
>        target_version: 2.15.3.0
>        initial_grant: 8437760
>        max_brw_size: 4194304
>        grant_block_size: 4096
>        grant_inode_size: 32
>        grant_max_extent_size: 67108864
>        grant_extent_tax: 24576
>        cksum_types: 0xf7
>        max_object_bytes: 17592186040320
>     import_flags: [ replayable, pingable, connect_tried ]
>     connection:
>        failover_nids: [ 0@lo, 0@lo ]
>        current_connection: 0@lo
>        connection_attempts: 1
>        generation: 1
>        in-progress_invalidations: 0
>        idle: 36 sec
>     rpcs:
>        inflight: 0
>        unregistering: 0
>        timeouts: 0
>        avg_waittime: 2627 usec
>     service_estimates:
>        services: 1 sec
>        network: 1 sec
>     transactions:
>        last_replay: 0
>        peer_committed: 0
>        last_checked: 0
>

--000000000000d79544062636cb53
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">The import is showing the following though the OST is form=
atted with=C2=A0<span style=3D"font-family:monospace">failover.node=3D10.99=
.100.152 or service=C2=A0mode=C2=A0</span><span style=3D"font-family:monosp=
ace">=3D10.99.100.152</span><div><br></div><div><span style=3D"font-family:=
monospace">=C2=A0 =C2=A0 connection:</span><br style=3D"font-family:monospa=
ce"><span style=3D"font-family:monospace">=C2=A0 =C2=A0 =C2=A0 =C2=A0failov=
er_nids: [ 0@lo, 0@lo ]</span><br style=3D"font-family:monospace"><span sty=
le=3D"font-family:monospace">=C2=A0 =C2=A0 =C2=A0 =C2=A0current_connection:=
 0@lo</span></div><div><span style=3D"font-family:monospace"><br></span></d=
iv><div><span style=3D"font-family:monospace"><br></span></div></div><br><d=
iv class=3D"gmail_quote"><div dir=3D"ltr" class=3D"gmail_attr">On Tue, 5 No=
v 2024 at 12:34, Backer &lt;<a href=3D"mailto:backer.kolo@gmail.com">backer=
.kolo@gmail.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);pad=
ding-left:1ex"><div dir=3D"ltr">Hi,<div><br></div>Mounting the Lustre file =
file system on the OSS. Some of the OSTs are locally attached to the OSS. <=
br><br>The failover IP on the OST is &quot;10.99.100.152&quot;. It is a loc=
al lnet on the OSS. However, when the client mounts it, the import automati=
cally changes to 0@lo. It is undesirable here because when this OST fails o=
ver to another server, the client is still trying to connect to 0@lo while =
it is no longer on the same host. This makes the client fs mount hangs for =
ever. =C2=A0<br><br>Here the failover is designed in such a way that the IP=
 address moves (fails over) with OST and becomes active on the other server=
. <br><br>How can I make the import pointing to the real IP and not the loo=
pback? (so that the failover works)<div><span style=3D"font-family:monospac=
e"></span></div><div><span style=3D"font-family:monospace"><br></span></div=
><div><br></div><font face=3D"monospace">[oss000 ~]$ lfs df<br>UUID =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1K-blocks =C2=A0 =
=C2=A0 =C2=A0 =C2=A0Used =C2=A0 Available Use% Mounted on<br>fs-MDT0000_UUI=
D =C2=A0 =C2=A0 29068444 =C2=A0 =C2=A0 =C2=A0 25692 =C2=A0 =C2=A026422344 =
=C2=A0 1% /mnt/fs[MDT:0]<br>fs-OST0000_UUID =C2=A0 =C2=A0 50541812 =C2=A0 =
=C2=A030160292 =C2=A0 =C2=A017743696 =C2=A063% /mnt/fs[OST:0]<br>fs-OST0001=
_UUID =C2=A0 =C2=A0 50541812 =C2=A0 =C2=A029301740 =C2=A0 =C2=A018602248 =
=C2=A062% /mnt/fs[OST:1]<br>fs-OST0002_UUID =C2=A0 =C2=A0 50541812 =C2=A0 =
=C2=A029356508 =C2=A0 =C2=A018547480 =C2=A062% /mnt/fs[OST:2]<br>fs-OST0003=
_UUID =C2=A0 =C2=A0 50541812 =C2=A0 =C2=A0 8822980 =C2=A0 =C2=A039081008 =
=C2=A019% /mnt/fs[OST:3]<br><br>filesystem_summary: =C2=A0 =C2=A0202167248 =
=C2=A0 =C2=A097641520 =C2=A0 =C2=A093974432 =C2=A051% /mnt/fs<br><br>[oss00=
0 ~]$ df -h<br>Filesystem =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0Size =C2=A0Used Avail Use% Mounted on<br>devtmpfs =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 30G =C2=A0 =C2=
=A0 0 =C2=A0 30G =C2=A0 0% /dev<br>tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A030G =C2=A08.1M =C2=A0 30G =
=C2=A0 1% /dev/shm<br>tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A030G =C2=A0 25M =C2=A0 30G =C2=A0 1% /=
run<br>tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A030G =C2=A0 =C2=A0 0 =C2=A0 30G =C2=A0 0% /sys/fs/cgrou=
p<br>/dev/mapper/ocivolume-root =C2=A0 36G =C2=A0 17G =C2=A0 19G =C2=A048% =
/<br>/dev/sdc2 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A01014M =C2=A0637M =C2=A0378M =C2=A063% /boot<br>/dev/mapper/ocivolume-ole=
d =C2=A0 10G =C2=A02.5G =C2=A07.6G =C2=A025% /var/oled<br>/dev/sdc1 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 100M =C2=A05.1M =C2=
=A0 95M =C2=A0 6% /boot/efi<br>tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 5.9G =C2=A0 =C2=A0 0 =C2=A05.9G =C2=
=A0 0% /run/user/987<br>tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 5.9G =C2=A0 =C2=A0 0 =C2=A05.9G =C2=A0 0% /=
run/user/0<br>/dev/sdb =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 49G =C2=A0 28G =C2=A0 18G =C2=A062% /fs-OST0001<br>/dev/s=
da =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 49=
G =C2=A0 29G =C2=A0 17G =C2=A063% /fs-OST0000<br>tmpfs =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 5.9G =C2=A0 =C2=A0=
 0 =C2=A05.9G =C2=A0 0% /run/user/1000<br>10.99.100.221@tcp1:/fs =C2=A0193G=
 =C2=A0 94G =C2=A0 90G =C2=A051% /mnt/fs<br><br>[oss000 ~]$ sudo tunefs.lus=
tre --dryrun /dev/sda<br>checking for existing Lustre data: found<br><br>=
=C2=A0 =C2=A0Read previous values:<br>Target: =C2=A0 =C2=A0 fs-OST0000<br>I=
ndex: =C2=A0 =C2=A0 =C2=A00<br>Lustre FS: =C2=A0fs<br>Mount type: ldiskfs<b=
r>Flags: =C2=A0 =C2=A0 =C2=A00x1002<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 (OST no_primnode )<br>Persistent mount opts: ,errors=3Dremoun=
t-ro<br>Parameters: mgsnode=3D10.99.100.221@tcp1 failover.node=3D10.99.100.=
152@tcp1,10.99.100.152@tcp1<br><br><br>=C2=A0 =C2=A0Permanent disk data:<br=
>Target: =C2=A0 =C2=A0 fs-OST0000<br>Index: =C2=A0 =C2=A0 =C2=A00<br>Lustre=
 FS: =C2=A0fs<br>Mount type: ldiskfs<br>Flags: =C2=A0 =C2=A0 =C2=A00x1002<b=
r>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (OST no_primnode )<br>Pe=
rsistent mount opts: ,errors=3Dremount-ro<br>Parameters: mgsnode=3D10.99.10=
0.221@tcp1 failover.node=3D10.99.100.152@tcp1,10.99.100.152@tcp1<br><br>exi=
ting before disk write.<br><br><br>[oss000 proc]# cat /proc/fs/lustre/osc/f=
s-OST0000-osc-ffff89c57672e000/import<br>import:<br>=C2=A0 =C2=A0 name: fs-=
OST0000-osc-ffff89c57672e000<br>=C2=A0 =C2=A0 target: fs-OST0000_UUID<br>=
=C2=A0 =C2=A0 state: IDLE<br>=C2=A0 =C2=A0 connect_flags: [ write_grant, se=
rver_lock, version, request_portal, max_byte_per_rpc, early_lock_cancel, ad=
aptive_timeouts, lru_resize, alt_checksum_algorithm, fid_is_enabled, versio=
n_recovery, grant_shrink, full20, layout_lock, 64bithash, object_max_bytes,=
 jobstats, einprogress, grant_param, lvb_type, short_io, lfsck, bulk_mbits,=
 second_flags, lockaheadv2, increasing_xid, client_encryption, lseek, reply=
_mbits ]<br>=C2=A0 =C2=A0 connect_data:<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0flags=
: 0xa0425af2e3440078<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0instance: 39<br>=C2=A0 =
=C2=A0 =C2=A0 =C2=A0target_version: 2.15.3.0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0=
initial_grant: 8437760<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0max_brw_size: 4194304<=
br>=C2=A0 =C2=A0 =C2=A0 =C2=A0grant_block_size: 4096<br>=C2=A0 =C2=A0 =C2=
=A0 =C2=A0grant_inode_size: 32<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0grant_max_exte=
nt_size: 67108864<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0grant_extent_tax: 24576<br>=
=C2=A0 =C2=A0 =C2=A0 =C2=A0cksum_types: 0xf7<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0=
max_object_bytes: 17592186040320<br>=C2=A0 =C2=A0 import_flags: [ replayabl=
e, pingable, connect_tried ]<br>=C2=A0 =C2=A0 connection:<br>=C2=A0 =C2=A0 =
=C2=A0 =C2=A0failover_nids: [ 0@lo, 0@lo ]<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0cu=
rrent_connection: 0@lo<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0connection_attempts: 1=
<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0generation: 1<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0=
in-progress_invalidations: 0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0idle: 36 sec<br>=
=C2=A0 =C2=A0 rpcs:<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0inflight: 0<br>=C2=A0 =C2=
=A0 =C2=A0 =C2=A0unregistering: 0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0timeouts: 0=
<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0avg_waittime: 2627 usec<br>=C2=A0 =C2=A0 ser=
vice_estimates:<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0services: 1 sec<br>=C2=A0 =C2=
=A0 =C2=A0 =C2=A0network: 1 sec<br>=C2=A0 =C2=A0 transactions:<br>=C2=A0 =
=C2=A0 =C2=A0 =C2=A0last_replay: 0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0peer_commi=
tted: 0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0last_checked: 0</font></div>
</blockquote></div>

--000000000000d79544062636cb53--

--===============0112822163646792900==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0112822163646792900==--
