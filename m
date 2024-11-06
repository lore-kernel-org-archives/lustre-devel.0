Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A3CB5D1CA17
	for <lustre-devel@archiver.kernel.org>; Wed,  6 Nov 2024 04:16:20 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4XjsMT3RNxz1x69;
	Tue, 05 Nov 2024 20:16:05 -0800 (PST)
Received: from mail-il1-f178.google.com (mail-il1-f178.google.com
 [209.85.166.178])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4XjsMH5bMvz1whR; Tue, 05 Nov 2024 20:15:55 -0800 (PST)
Received: by mail-il1-f178.google.com with SMTP id
 e9e14a558f8ab-3a3a5cd2a3bso22472235ab.3; 
 Tue, 05 Nov 2024 20:15:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1730866555; x=1731471355; darn=lists.lustre.org;
 h=to:subject:message-id:date:from:in-reply-to:references:mime-version
 :from:to:cc:subject:date:message-id:reply-to;
 bh=FJCENRuIZ4qV6AQtNX6oz44eQd7EjdvHRMdzIwvPjXU=;
 b=bYm75OB85Vrv5uw1HTzWsjfdzSOrv2W1Ha9hmXhUQY3KQMVDfIRiqdXSjEWIwCE7nt
 DYpm8jXx3sIMTKqGYoO/IBoGmzFx05Z02hC+CSPSvlSe2QIhxGesF6AA30dREE8blCmR
 Mkb3zop6uTJdA+eYosiFKJQ4rFT86GCp0sJesn/7wtMMcFoEcn+MiHM2HvZ7+aXcS16g
 PsSXPhKSkcknTocCh9TPY0uj4BZKEyzyI1q12slQECyi1R/dCpGApcIMcOQazhtom9Wy
 ZbGeEozZ1FD9w2jQ5PEH23OSjB/Vkq4Peq46d49JrbETCtMnsJZvN0RWDCSKY7kbtKob
 EHKQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1730866555; x=1731471355;
 h=to:subject:message-id:date:from:in-reply-to:references:mime-version
 :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=FJCENRuIZ4qV6AQtNX6oz44eQd7EjdvHRMdzIwvPjXU=;
 b=MDuhsUB5ITmP8rsT93SVlAqkY1hZr2aaw0dE5mNmBFVtryzLBMOyT/50a9pMoist1z
 7wNNjN66tlPkZzqrY2vsOg5wmBR1NCx2b4KoltzfZdRDxWDFTdpUZk+eUSKgbweh/4cR
 5zUDaC5hA2u10ubTAxP2r4jU4hM0oHRwf/RKtN1lssu9PJQihaw/Phs4AvgGY0BuzQoY
 wX4TaoulqOWvrh/ADIWFXDjAScpWdGoMm5G8Q2eAH3iB0sJr5SNEp2ag6EC8iA9W67g8
 Sd5NC9Q91wuNnSHW00z6zpokfqmIwp0sEtwmJTqixgJ93c6f9EA+XGn5+sChymYdIRji
 H2RA==
X-Forwarded-Encrypted: i=1;
 AJvYcCVrZn2lovJXLvaLZ17i3zcAjmRZbPeN5DTrJRTeOliE7+7dGSHAbIkXaNBS3jB1q5Vi7zpZ7j16el8UEW8=@lists.lustre.org
X-Gm-Message-State: AOJu0Yy2BTNww2F/jN2wvIZrW9mRpRIxmyB0jHrXdVRSVfxotOrE1FSK
 oKzVOLtjknI9oSzAG0GmRxH9SNCJcuxbp/F7xkDrrQOUU0nIuTJEftw/VwWg5MIwkrqwkU39tOx
 L5ujI3dPpauHhC8YH5TrD8O9MhaKLfQ==
X-Google-Smtp-Source: AGHT+IE8PrVKzJekjNrd3CSjmb6ZEkfOzaOHDay4+Pk/gVc0PifdiRlPAR2q5MJnnphvQr25pKJOhQ7XGmVcNRChkOg=
X-Received: by 2002:a05:6e02:1988:b0:3a6:ca38:6862 with SMTP id
 e9e14a558f8ab-3a6ca386d1fmr122903895ab.19.1730866554519; Tue, 05 Nov 2024
 20:15:54 -0800 (PST)
MIME-Version: 1.0
References: <CAPq+oA+JR=CxnOQ-ERto7DMW7QuyMo6xuqa5CxGjPUE2xZwb+g@mail.gmail.com>
In-Reply-To: <CAPq+oA+JR=CxnOQ-ERto7DMW7QuyMo6xuqa5CxGjPUE2xZwb+g@mail.gmail.com>
From: Backer <backer.kolo@gmail.com>
Date: Tue, 5 Nov 2024 23:15:43 -0500
Message-ID: <CAPq+oAJELmmeSS_K=JyEfu7WC=oT=AgAo9H8E1YThP3SbSo_7w@mail.gmail.com>
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
Content-Type: multipart/mixed; boundary="===============2305379483719275157=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============2305379483719275157==
Content-Type: multipart/alternative; boundary="00000000000022cf58062636c669"

--00000000000022cf58062636c669
Content-Type: text/plain; charset="UTF-8"

Any ideas on how to avoid using 0@lo as failover_nids? Please see below.

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

--00000000000022cf58062636c669
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Any ideas on how to avoid using 0@lo as failover_nids? Ple=
ase see below.=C2=A0</div><br><div class=3D"gmail_quote"><div dir=3D"ltr" c=
lass=3D"gmail_attr">On Tue, 5 Nov 2024 at 12:34, Backer &lt;<a href=3D"mail=
to:backer.kolo@gmail.com">backer.kolo@gmail.com</a>&gt; wrote:<br></div><bl=
ockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-lef=
t:1px solid rgb(204,204,204);padding-left:1ex"><div dir=3D"ltr">Hi,<div><br=
></div>Mounting the Lustre file file system on the OSS. Some of the OSTs ar=
e locally attached to the OSS. <br><br>The failover IP on the OST is &quot;=
10.99.100.152&quot;. It is a local lnet on the OSS. However, when the clien=
t mounts it, the import automatically changes to 0@lo. It is undesirable he=
re because when this OST fails over to another server, the client is still =
trying to connect to 0@lo while it is no longer on the same host. This make=
s the client fs mount hangs for ever. =C2=A0<br><br>Here the failover is de=
signed in such a way that the IP address moves (fails over) with OST and be=
comes active on the other server. <br><br>How can I make the import pointin=
g to the real IP and not the loopback? (so that the failover works)<div><sp=
an style=3D"font-family:monospace"></span></div><div><span style=3D"font-fa=
mily:monospace"><br></span></div><div><br></div><font face=3D"monospace">[o=
ss000 ~]$ lfs df<br>UUID =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 1K-blocks =C2=A0 =C2=A0 =C2=A0 =C2=A0Used =C2=A0 Available Us=
e% Mounted on<br>fs-MDT0000_UUID =C2=A0 =C2=A0 29068444 =C2=A0 =C2=A0 =C2=
=A0 25692 =C2=A0 =C2=A026422344 =C2=A0 1% /mnt/fs[MDT:0]<br>fs-OST0000_UUID=
 =C2=A0 =C2=A0 50541812 =C2=A0 =C2=A030160292 =C2=A0 =C2=A017743696 =C2=A06=
3% /mnt/fs[OST:0]<br>fs-OST0001_UUID =C2=A0 =C2=A0 50541812 =C2=A0 =C2=A029=
301740 =C2=A0 =C2=A018602248 =C2=A062% /mnt/fs[OST:1]<br>fs-OST0002_UUID =
=C2=A0 =C2=A0 50541812 =C2=A0 =C2=A029356508 =C2=A0 =C2=A018547480 =C2=A062=
% /mnt/fs[OST:2]<br>fs-OST0003_UUID =C2=A0 =C2=A0 50541812 =C2=A0 =C2=A0 88=
22980 =C2=A0 =C2=A039081008 =C2=A019% /mnt/fs[OST:3]<br><br>filesystem_summ=
ary: =C2=A0 =C2=A0202167248 =C2=A0 =C2=A097641520 =C2=A0 =C2=A093974432 =C2=
=A051% /mnt/fs<br><br>[oss000 ~]$ df -h<br>Filesystem =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Size =C2=A0Used Avail Use% Mounted=
 on<br>devtmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 30G =C2=A0 =C2=A0 0 =C2=A0 30G =C2=A0 0% /dev<br>tmpfs =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A030G =C2=A08.1M =C2=A0 30G =C2=A0 1% /dev/shm<br>tmpfs =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A030G =C2=
=A0 25M =C2=A0 30G =C2=A0 1% /run<br>tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A030G =C2=A0 =C2=A0 0 =C2=
=A0 30G =C2=A0 0% /sys/fs/cgroup<br>/dev/mapper/ocivolume-root =C2=A0 36G =
=C2=A0 17G =C2=A0 19G =C2=A048% /<br>/dev/sdc2 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01014M =C2=A0637M =C2=A0378M =C2=A063% /bo=
ot<br>/dev/mapper/ocivolume-oled =C2=A0 10G =C2=A02.5G =C2=A07.6G =C2=A025%=
 /var/oled<br>/dev/sdc1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 100M =C2=A05.1M =C2=A0 95M =C2=A0 6% /boot/efi<br>tmpfs =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 5=
.9G =C2=A0 =C2=A0 0 =C2=A05.9G =C2=A0 0% /run/user/987<br>tmpfs =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 5.9G =C2=
=A0 =C2=A0 0 =C2=A05.9G =C2=A0 0% /run/user/0<br>/dev/sdb =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 49G =C2=A0 28G =C2=A0 =
18G =C2=A062% /fs-OST0001<br>/dev/sda =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 49G =C2=A0 29G =C2=A0 17G =C2=A063% /fs-=
OST0000<br>tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 5.9G =C2=A0 =C2=A0 0 =C2=A05.9G =C2=A0 0% /run/user/10=
00<br>10.99.100.221@tcp1:/fs =C2=A0193G =C2=A0 94G =C2=A0 90G =C2=A051% /mn=
t/fs<br><br>[oss000 ~]$ sudo tunefs.lustre --dryrun /dev/sda<br>checking fo=
r existing Lustre data: found<br><br>=C2=A0 =C2=A0Read previous values:<br>=
Target: =C2=A0 =C2=A0 fs-OST0000<br>Index: =C2=A0 =C2=A0 =C2=A00<br>Lustre =
FS: =C2=A0fs<br>Mount type: ldiskfs<br>Flags: =C2=A0 =C2=A0 =C2=A00x1002<br=
>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (OST no_primnode )<br>Per=
sistent mount opts: ,errors=3Dremount-ro<br>Parameters: mgsnode=3D10.99.100=
.221@tcp1 failover.node=3D10.99.100.152@tcp1,10.99.100.152@tcp1<br><br><br>=
=C2=A0 =C2=A0Permanent disk data:<br>Target: =C2=A0 =C2=A0 fs-OST0000<br>In=
dex: =C2=A0 =C2=A0 =C2=A00<br>Lustre FS: =C2=A0fs<br>Mount type: ldiskfs<br=
>Flags: =C2=A0 =C2=A0 =C2=A00x1002<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 (OST no_primnode )<br>Persistent mount opts: ,errors=3Dremoun=
t-ro<br>Parameters: mgsnode=3D10.99.100.221@tcp1 failover.node=3D10.99.100.=
152@tcp1,10.99.100.152@tcp1<br><br>exiting before disk write.<br><br><br>[o=
ss000 proc]# cat /proc/fs/lustre/osc/fs-OST0000-osc-ffff89c57672e000/import=
<br>import:<br>=C2=A0 =C2=A0 name: fs-OST0000-osc-ffff89c57672e000<br>=C2=
=A0 =C2=A0 target: fs-OST0000_UUID<br>=C2=A0 =C2=A0 state: IDLE<br>=C2=A0 =
=C2=A0 connect_flags: [ write_grant, server_lock, version, request_portal, =
max_byte_per_rpc, early_lock_cancel, adaptive_timeouts, lru_resize, alt_che=
cksum_algorithm, fid_is_enabled, version_recovery, grant_shrink, full20, la=
yout_lock, 64bithash, object_max_bytes, jobstats, einprogress, grant_param,=
 lvb_type, short_io, lfsck, bulk_mbits, second_flags, lockaheadv2, increasi=
ng_xid, client_encryption, lseek, reply_mbits ]<br>=C2=A0 =C2=A0 connect_da=
ta:<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0flags: 0xa0425af2e3440078<br>=C2=A0 =C2=
=A0 =C2=A0 =C2=A0instance: 39<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0target_version:=
 2.15.3.0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0initial_grant: 8437760<br>=C2=A0 =
=C2=A0 =C2=A0 =C2=A0max_brw_size: 4194304<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0gra=
nt_block_size: 4096<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0grant_inode_size: 32<br>=
=C2=A0 =C2=A0 =C2=A0 =C2=A0grant_max_extent_size: 67108864<br>=C2=A0 =C2=A0=
 =C2=A0 =C2=A0grant_extent_tax: 24576<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0cksum_t=
ypes: 0xf7<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0max_object_bytes: 17592186040320<b=
r>=C2=A0 =C2=A0 import_flags: [ replayable, pingable, connect_tried ]<br>=
=C2=A0 =C2=A0 connection:<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0failover_nids: [ 0@=
lo, 0@lo ]<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0current_connection: 0@lo<br>=C2=A0=
 =C2=A0 =C2=A0 =C2=A0connection_attempts: 1<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0g=
eneration: 1<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0in-progress_invalidations: 0<br>=
=C2=A0 =C2=A0 =C2=A0 =C2=A0idle: 36 sec<br>=C2=A0 =C2=A0 rpcs:<br>=C2=A0 =
=C2=A0 =C2=A0 =C2=A0inflight: 0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0unregistering=
: 0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0timeouts: 0<br>=C2=A0 =C2=A0 =C2=A0 =C2=
=A0avg_waittime: 2627 usec<br>=C2=A0 =C2=A0 service_estimates:<br>=C2=A0 =
=C2=A0 =C2=A0 =C2=A0services: 1 sec<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0network: =
1 sec<br>=C2=A0 =C2=A0 transactions:<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0last_rep=
lay: 0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0peer_committed: 0<br>=C2=A0 =C2=A0 =C2=
=A0 =C2=A0last_checked: 0</font></div>
</blockquote></div>

--00000000000022cf58062636c669--

--===============2305379483719275157==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============2305379483719275157==--
