Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DA378D59F60
	for <lustre-devel@archiver.kernel.org>; Wed,  6 Nov 2024 18:43:32 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4XkDY35rPPz1xdb;
	Wed, 06 Nov 2024 10:40:39 -0800 (PST)
Received: from mail-il1-f170.google.com (mail-il1-f170.google.com
 [209.85.166.170])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4XkDWN5Pbcz1wQP; Wed, 06 Nov 2024 10:39:12 -0800 (PST)
Received: by mail-il1-f170.google.com with SMTP id
 e9e14a558f8ab-3a4e30bffe3so607035ab.3; 
 Wed, 06 Nov 2024 10:39:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1730918352; x=1731523152; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=ccfXCjLVmIyx9/bJ+xx50eOED6csoV89FOGYhWAzAKs=;
 b=kNmesFRn35A6A/gYY8nbGM//VgxbX0QnYomqOqZyYaVL2P9Z/KxstfSyCIcVkNlYfF
 YYwErrXbun7qR8iKYturOWSoWekuN/eiHF/sM6+xluhnGE5/5RL00OK8EZ9Yh0jLl0Qp
 IYVoRX4m+op1Bc9TQj9C5ZvvkcTS1JEmj+/1KHwMCHh9tLjYm1HZAZqLFQ8VhRzCxTPU
 ChZLSbm/nSKiWQZoWE18SclUzL6pMyxN6/pXODbxx2c4EXAAAR6rTKYHS//5Fu/g1y+U
 QgQhKCZkJqg/j0jXwtAtJLP/kfG3HMjum2XPCdeB2EcRQtseNUlX/EdzQIhsu69HlCGI
 8EeQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1730918352; x=1731523152;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=ccfXCjLVmIyx9/bJ+xx50eOED6csoV89FOGYhWAzAKs=;
 b=H3mt4fCuOJZ12r1YGcxuybx5aqwlsYGJU+HTIwJUCiX2Flhi5xYDSw8/DmS2HBdnrA
 oy1yqAnZbNvgkhbtnpOgNWO0ZQ26hpyJ8Qkpp3H0rrX5oZnZYWqJBqYhzFVaTAnbXv/9
 cgdMh8MlBMHEZaS7NzCRTTL8uKuPTfkTVW3d2fLk21JmXOMNcNuY+A0mRtUL55MBc2Et
 G20GtiX520kZk+dD65dQj+UoQ4H5r1tE2XLuai3JJcjZ2irp6FUqCNvyxj5fhyF0SNBF
 fbaGZ8rWg4jbhh1pIS0pCrytf/FfJ6Pv7yQPpxYdndXw2ZMIhxcXHVp5h2SD/eODfRlM
 2mAg==
X-Forwarded-Encrypted: i=1;
 AJvYcCXSJPTxVn9gX4BJWVRRtXzqsV/fKQQzN6YfzX6x44IF3MyIUdJ2DpxqgQo4GuO+pW9C7WGce1Dx2Gwo27s=@lists.lustre.org
X-Gm-Message-State: AOJu0YyQnwBhAcbpw1nP08ai94wjedV1HcFyR8FN/D86pVxd8nkRtjht
 1qau13Zej++ZUmCR1BQZY5yq9DngKksHXYaIEvkeNTi6pDlc/KuAFdwMEPUp93EcY90HPXWY43Q
 Qk590MCL4NoxaO/B+wCeG2tbM/M0=
X-Google-Smtp-Source: AGHT+IELZQC0/0L3GgOKSqJUbGOU8KAJPY0MFV5BOc8z4ONT5BIWbfB4ZgyuhdOF8G9M63uzNTCrLIiBNI+gOQKxC/4=
X-Received: by 2002:a92:c564:0:b0:3a6:ca22:7b2d with SMTP id
 e9e14a558f8ab-3a6ca227c90mr149098245ab.13.1730918351583; Wed, 06 Nov 2024
 10:39:11 -0800 (PST)
MIME-Version: 1.0
References: <CAPq+oA+JR=CxnOQ-ERto7DMW7QuyMo6xuqa5CxGjPUE2xZwb+g@mail.gmail.com>
 <CAPq+oAJELmmeSS_K=JyEfu7WC=oT=AgAo9H8E1YThP3SbSo_7w@mail.gmail.com>
 <MW4PR84MB1444A2C04C5C1C0977BBE76C9E532@MW4PR84MB1444.NAMPRD84.PROD.OUTLOOK.COM>
In-Reply-To: <MW4PR84MB1444A2C04C5C1C0977BBE76C9E532@MW4PR84MB1444.NAMPRD84.PROD.OUTLOOK.COM>
From: Backer <backer.kolo@gmail.com>
Date: Wed, 6 Nov 2024 13:39:00 -0500
Message-ID: <CAPq+oAL+hxLnpf+UDbraDbj39mZnqGbA+Dy96zo7B7Zavkjw4g@mail.gmail.com>
To: "Horn, Chris" <chris.horn@hpe.com>
Cc: Backer via lustre-discuss <lustre-discuss@lists.lustre.org>, 
 "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] [lustre-discuss] Lustre switching to loop back
 lnet interface when it is not desired
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
Content-Type: multipart/mixed; boundary="===============3629161893784411232=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3629161893784411232==
Content-Type: multipart/alternative; boundary="0000000000007b45b4062642d527"

--0000000000007b45b4062642d527
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Chris,

Thank you looking in to this. I agree.  In cloud and other type of networks
on-Prem, floating ip is real thing providing ha and I am attempting to make
it work. Since ip move happens within subseconds in these environment, the
failover happens within a few seconds and even notice Any delay. This
optimization is an undesired optimization in certain environment. If there
is no param already  exists for a behavior change, how I can make it work
within this environment?  I wonder if it requires a code change? If so, I
could look in to it if someone can help with some pointers.

Regards

Aboo

On Wed, Nov 6, 2024 at 11:05=E2=80=AFAM Horn, Chris <chris.horn@hpe.com> wr=
ote:

> Here the failover is designed in such a way that the IP address moves
> (fails over) with OST and becomes active on the other server.
>
>
>
> This is probably the source of your problem. I would suggest assigning
> unique IP addresses to each OSS.
>
>
>
> Chris Horn
>
>
>
> *From: *lustre-discuss <lustre-discuss-bounces@lists.lustre.org> on
> behalf of Backer <backer.kolo@gmail.com>
> *Date: *Tuesday, November 5, 2024 at 10:19=E2=80=AFPM
> *To: *Backer via lustre-discuss <lustre-discuss@lists.lustre.org>,
> lustre-devel@lists.lustre.org <lustre-devel@lists.lustre.org>
> *Subject: *Re: [lustre-discuss] Lustre switching to loop back lnet
> interface when it is not desired
>
> Any ideas on how to avoid using 0@lo as failover_nids? Please see below.
>
>
>
> On Tue, 5 Nov 2024 at 12:34, Backer <backer.kolo@gmail.com> wrote:
>
> Hi,
>
>
>
> Mounting the Lustre file file system on the OSS. Some of the OSTs are
> locally attached to the OSS.
>
> The failover IP on the OST is "10.99.100.152". It is a local lnet on the
> OSS. However, when the client mounts it, the import automatically changes
> to 0@lo. It is undesirable here because when this OST fails over to
> another server, the client is still trying to connect to 0@lo while it is
> no longer on the same host. This makes the client fs mount hangs for ever=
.
>
> Here the failover is designed in such a way that the IP address moves
> (fails over) with OST and becomes active on the other server.
>
> How can I make the import pointing to the real IP and not the loopback?
> (so that the failover works)
>
>
>
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
> Persistent mount opts: ,errors=3Dremount-ro
> Parameters: mgsnode=3D10.99.100.221@tcp1 failover.node=3D10.99.100.152@tc=
p1
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
> Persistent mount opts: ,errors=3Dremount-ro
> Parameters: mgsnode=3D10.99.100.221@tcp1 failover.node=3D10.99.100.152@tc=
p1
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
>

--0000000000007b45b4062642d527
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto">Hi Chris,</div><div dir=3D"auto"><br></div><div dir=3D"au=
to">Thank you looking in to this. I agree.=C2=A0 In cloud and other type of=
 networks on-Prem, floating ip is real thing providing ha and I am attempti=
ng to make it work. Since ip move happens within subseconds in these enviro=
nment, the failover happens within a few seconds and even notice Any delay.=
 This optimization is an undesired optimization in certain environment. If =
there is no param already=C2=A0<span style=3D"font-family:-apple-system,hel=
veticaneue;background-color:rgba(0,0,0,0);border-color:rgb(0,0,0);color:rgb=
(0,0,0)">=C2=A0exists for a behavior change, how I can make it work within =
this environment?=C2=A0 I wonder if it requires a code change? If so, I cou=
ld look in to it if someone can help with some pointers.=C2=A0</span></div>=
<div dir=3D"auto"><span style=3D"font-family:-apple-system,helveticaneue;ba=
ckground-color:rgba(0,0,0,0);border-color:rgb(0,0,0);color:rgb(0,0,0)"><br>=
</span></div><div dir=3D"auto"><span style=3D"font-family:-apple-system,hel=
veticaneue;background-color:rgba(0,0,0,0);border-color:rgb(0,0,0);color:rgb=
(0,0,0)">Regards</span></div><div dir=3D"auto"><span style=3D"font-family:-=
apple-system,helveticaneue;background-color:rgba(0,0,0,0);border-color:rgb(=
0,0,0);color:rgb(0,0,0)"><br></span></div><div dir=3D"auto"><span style=3D"=
font-family:-apple-system,helveticaneue;background-color:rgba(0,0,0,0);bord=
er-color:rgb(0,0,0);color:rgb(0,0,0)">Aboo</span></div><div><br><div class=
=3D"gmail_quote"><div dir=3D"ltr" class=3D"gmail_attr">On Wed, Nov 6, 2024 =
at 11:05=E2=80=AFAM Horn, Chris &lt;<a href=3D"mailto:chris.horn@hpe.com">c=
hris.horn@hpe.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote"=
 style=3D"margin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-style:=
solid;padding-left:1ex;border-left-color:rgb(204,204,204)">





<div lang=3D"EN-US" link=3D"blue" vlink=3D"purple" style=3D"overflow-wrap: =
break-word;">
<div class=3D"m_2579605375602447286WordSection1">
<p class=3D"MsoNormal" style=3D"margin-left:0.5in"><span style=3D"font-size=
:11pt">Here the failover is designed in such a way that the IP address move=
s (fails over) with OST and becomes active on the other server.<u></u><u></=
u></span></p>
<p class=3D"MsoNormal" style=3D"margin-left:0.5in"><span style=3D"font-size=
:11pt"><u></u>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11pt">This is probably the =
source of your problem. I would suggest assigning unique IP addresses to ea=
ch OSS.</span></p></div></div><div lang=3D"EN-US" link=3D"blue" vlink=3D"pu=
rple" style=3D"overflow-wrap: break-word;"><div class=3D"m_2579605375602447=
286WordSection1"><p class=3D"MsoNormal"><span style=3D"font-size:11pt"><u><=
/u><u></u></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11pt"><u></u>=C2=A0<u></u><=
/span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11pt">Chris Horn<u></u><u><=
/u></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11pt"><u></u>=C2=A0<u></u><=
/span></p>
<div id=3D"m_2579605375602447286mail-editor-reference-message-container">
<div>
<div>
<div style=3D"border-width:1pt medium medium;border-style:solid none none;p=
adding:3pt 0in 0in;border-color:rgb(181,196,223) currentcolor currentcolor"=
>
<p class=3D"MsoNormal" style=3D"margin-bottom:12pt"><b><span style=3D"color=
:black">From:
</span></b><span style=3D"color:black">lustre-discuss &lt;<a href=3D"mailto=
:lustre-discuss-bounces@lists.lustre.org" target=3D"_blank">lustre-discuss-=
bounces@lists.lustre.org</a>&gt; on behalf of Backer &lt;<a href=3D"mailto:=
backer.kolo@gmail.com" target=3D"_blank">backer.kolo@gmail.com</a>&gt;<br>
<b>Date: </b>Tuesday, November 5, 2024 at 10:19</span><span style=3D"font-f=
amily:Arial,sans-serif;color:black">=E2=80=AF</span><span style=3D"color:bl=
ack">PM<br>
<b>To: </b>Backer via lustre-discuss &lt;<a href=3D"mailto:lustre-discuss@l=
ists.lustre.org" target=3D"_blank">lustre-discuss@lists.lustre.org</a>&gt;,=
 <a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-=
devel@lists.lustre.org</a> &lt;<a href=3D"mailto:lustre-devel@lists.lustre.=
org" target=3D"_blank">lustre-devel@lists.lustre.org</a>&gt;<br>
<b>Subject: </b>Re: [lustre-discuss] Lustre switching to loop back lnet int=
erface when it is not desired<u></u><u></u></span></p>
</div>
<div>
<p class=3D"MsoNormal">Any ideas on how to avoid using 0@lo as failover_nid=
s? Please see below.=C2=A0<u></u><u></u></p>
</div>
<p class=3D"MsoNormal"><u></u>=C2=A0<u></u></p>
<div>
<div>
<p class=3D"MsoNormal">On Tue, 5 Nov 2024 at 12:34, Backer &lt;<a href=3D"m=
ailto:backer.kolo@gmail.com" target=3D"_blank">backer.kolo@gmail.com</a>&gt=
; wrote:<u></u><u></u></p>
</div>
<blockquote style=3D"border-width:medium medium medium 1pt;border-style:non=
e none none solid;padding:0in 0in 0in 6pt;margin-left:4.8pt;margin-right:0i=
n;border-color:currentcolor currentcolor currentcolor rgb(204,204,204)">
<div>
<p class=3D"MsoNormal">Hi,<u></u><u></u></p>
<div>
<p class=3D"MsoNormal"><u></u>=C2=A0<u></u></p>
</div>
<p class=3D"MsoNormal">Mounting the Lustre file file system on the OSS. Som=
e of the OSTs are locally attached to the OSS.
<br>
<br>
The failover IP on the OST is &quot;10.99.100.152&quot;. It is a local lnet=
 on the OSS. However, when the client mounts it, the import automatically c=
hanges to 0@lo. It is undesirable here because when this OST fails over to =
another server, the client is still trying
 to connect to 0@lo while it is no longer on the same host. This makes the =
client fs mount hangs for ever. =C2=A0<br>
<br>
Here the failover is designed in such a way that the IP address moves (fail=
s over) with OST and becomes active on the other server.
<br>
<br>
How can I make the import pointing to the real IP and not the loopback? (so=
 that the failover works)<u></u><u></u></p>
<div>
<p class=3D"MsoNormal"><u></u>=C2=A0<u></u></p>
</div>
<div>
<p class=3D"MsoNormal"><u></u>=C2=A0<u></u></p>
</div>
<p class=3D"MsoNormal"><span style=3D"font-family:&quot;Courier New&quot;">=
[oss000 ~]$ lfs df<br>
UUID =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1K-bloc=
ks =C2=A0 =C2=A0 =C2=A0 =C2=A0Used =C2=A0 Available Use% Mounted on<br>
fs-MDT0000_UUID =C2=A0 =C2=A0 29068444 =C2=A0 =C2=A0 =C2=A0 25692 =C2=A0 =
=C2=A026422344 =C2=A0 1% /mnt/fs[MDT:0]<br>
fs-OST0000_UUID =C2=A0 =C2=A0 50541812 =C2=A0 =C2=A030160292 =C2=A0 =C2=A01=
7743696 =C2=A063% /mnt/fs[OST:0]<br>
fs-OST0001_UUID =C2=A0 =C2=A0 50541812 =C2=A0 =C2=A029301740 =C2=A0 =C2=A01=
8602248 =C2=A062% /mnt/fs[OST:1]<br>
fs-OST0002_UUID =C2=A0 =C2=A0 50541812 =C2=A0 =C2=A029356508 =C2=A0 =C2=A01=
8547480 =C2=A062% /mnt/fs[OST:2]<br>
fs-OST0003_UUID =C2=A0 =C2=A0 50541812 =C2=A0 =C2=A0 8822980 =C2=A0 =C2=A03=
9081008 =C2=A019% /mnt/fs[OST:3]<br>
<br>
filesystem_summary: =C2=A0 =C2=A0202167248 =C2=A0 =C2=A097641520 =C2=A0 =C2=
=A093974432 =C2=A051% /mnt/fs<br>
<br>
[oss000 ~]$ df -h<br>
Filesystem =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Si=
ze =C2=A0Used Avail Use% Mounted on<br>
devtmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 30G =C2=A0 =C2=A0 0 =C2=A0 30G =C2=A0 0% /dev<br>
tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A030G =C2=A08.1M =C2=A0 30G =C2=A0 1% /dev/shm<br>
tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A030G =C2=A0 25M =C2=A0 30G =C2=A0 1% /run<br>
tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A030G =C2=A0 =C2=A0 0 =C2=A0 30G =C2=A0 0% /sys/fs/cgroup<br>
/dev/mapper/ocivolume-root =C2=A0 36G =C2=A0 17G =C2=A0 19G =C2=A048% /<br>
/dev/sdc2 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0101=
4M =C2=A0637M =C2=A0378M =C2=A063% /boot<br>
/dev/mapper/ocivolume-oled =C2=A0 10G =C2=A02.5G =C2=A07.6G =C2=A025% /var/=
oled<br>
/dev/sdc1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10=
0M =C2=A05.1M =C2=A0 95M =C2=A0 6% /boot/efi<br>
tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 5.9G =C2=A0 =C2=A0 0 =C2=A05.9G =C2=A0 0% /run/user/987<br>
tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 5.9G =C2=A0 =C2=A0 0 =C2=A05.9G =C2=A0 0% /run/user/0<br>
/dev/sdb =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 49G =C2=A0 28G =C2=A0 18G =C2=A062% /fs-OST0001<br>
/dev/sda =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 49G =C2=A0 29G =C2=A0 17G =C2=A063% /fs-OST0000<br>
tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 5.9G =C2=A0 =C2=A0 0 =C2=A05.9G =C2=A0 0% /run/user/1000<br>
10.99.100.221@tcp1:/fs =C2=A0193G =C2=A0 94G =C2=A0 90G =C2=A051% /mnt/fs<b=
r>
<br>
[oss000 ~]$ sudo tunefs.lustre --dryrun /dev/sda<br>
checking for existing Lustre data: found<br>
<br>
=C2=A0 =C2=A0Read previous values:<br>
Target: =C2=A0 =C2=A0 fs-OST0000<br>
Index: =C2=A0 =C2=A0 =C2=A00<br>
Lustre FS: =C2=A0fs<br>
Mount type: ldiskfs<br>
Flags: =C2=A0 =C2=A0 =C2=A00x1002<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (OST no_primnode )<br>
Persistent mount opts: ,errors=3Dremount-ro<br>
Parameters: mgsnode=3D10.99.100.221@tcp1 failover.node=3D10.99.100.152@tcp1=
,10.99.100.152@tcp1<br>
<br>
<br>
=C2=A0 =C2=A0Permanent disk data:<br>
Target: =C2=A0 =C2=A0 fs-OST0000<br>
Index: =C2=A0 =C2=A0 =C2=A00<br>
Lustre FS: =C2=A0fs<br>
Mount type: ldiskfs<br>
Flags: =C2=A0 =C2=A0 =C2=A00x1002<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (OST no_primnode )<br>
Persistent mount opts: ,errors=3Dremount-ro<br>
Parameters: mgsnode=3D10.99.100.221@tcp1 failover.node=3D10.99.100.152@tcp1=
,10.99.100.152@tcp1<br>
<br>
exiting before disk write.<br>
<br>
<br>
[oss000 proc]# cat /proc/fs/lustre/osc/fs-OST0000-osc-ffff89c57672e000/impo=
rt<br>
import:<br>
=C2=A0 =C2=A0 name: fs-OST0000-osc-ffff89c57672e000<br>
=C2=A0 =C2=A0 target: fs-OST0000_UUID<br>
=C2=A0 =C2=A0 state: IDLE<br>
=C2=A0 =C2=A0 connect_flags: [ write_grant, server_lock, version, request_p=
ortal, max_byte_per_rpc, early_lock_cancel, adaptive_timeouts, lru_resize, =
alt_checksum_algorithm, fid_is_enabled, version_recovery, grant_shrink, ful=
l20, layout_lock, 64bithash, object_max_bytes,
 jobstats, einprogress, grant_param, lvb_type, short_io, lfsck, bulk_mbits,=
 second_flags, lockaheadv2, increasing_xid, client_encryption, lseek, reply=
_mbits ]<br>
=C2=A0 =C2=A0 connect_data:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0flags: 0xa0425af2e3440078<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0instance: 39<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0target_version: 2.15.3.0<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0initial_grant: 8437760<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0max_brw_size: 4194304<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0grant_block_size: 4096<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0grant_inode_size: 32<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0grant_max_extent_size: 67108864<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0grant_extent_tax: 24576<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0cksum_types: 0xf7<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0max_object_bytes: 17592186040320<br>
=C2=A0 =C2=A0 import_flags: [ replayable, pingable, connect_tried ]<br>
=C2=A0 =C2=A0 connection:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0failover_nids: [ 0@lo, 0@lo ]<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0current_connection: 0@lo<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0connection_attempts: 1<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0generation: 1<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0in-progress_invalidations: 0<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0idle: 36 sec<br>
=C2=A0 =C2=A0 rpcs:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0inflight: 0<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0unregistering: 0<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0timeouts: 0<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0avg_waittime: 2627 usec<br>
=C2=A0 =C2=A0 service_estimates:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0services: 1 sec<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0network: 1 sec<br>
=C2=A0 =C2=A0 transactions:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0last_replay: 0<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0peer_committed: 0<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0last_checked: 0</span><u></u><u></u></p>
</div>
</blockquote>
</div>
</div>
</div>
</div>
</div>
</div>

</blockquote></div></div>

--0000000000007b45b4062642d527--

--===============3629161893784411232==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3629161893784411232==--
