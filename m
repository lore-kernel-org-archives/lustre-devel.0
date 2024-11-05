Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6F413D3176B
	for <lustre-devel@archiver.kernel.org>; Tue,  5 Nov 2024 17:35:00 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Xjb7Z5H77z1wsW;
	Tue, 05 Nov 2024 09:34:50 -0800 (PST)
Received: from mail-il1-f169.google.com (mail-il1-f169.google.com
 [209.85.166.169])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Xjb7Y2Cn2z1wY0; Tue, 05 Nov 2024 09:34:49 -0800 (PST)
Received: by mail-il1-f169.google.com with SMTP id
 e9e14a558f8ab-3a3b463e9b0so20160715ab.3; 
 Tue, 05 Nov 2024 09:34:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1730828088; x=1731432888; darn=lists.lustre.org;
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=s/rhYTFaXP3Dh+7hwLcaAA/f6wFylNETvCvMZV+1+jw=;
 b=D1xHydOBihB6oRUnUri6+H/WsxcmqDtz0xqpKcB54660mswtqrJodTX9DcEb7aIDf1
 NWsXDPPqRI21I/Mzx2GHnbfZ0TjKGKiS3t//ij+YDQgEQyftmbb8ML8k4qOVhjDKUTZd
 1IHSmlVqiWPrinmOdLyu3CIZOSgITlxxxCfOvJLUqbYE+wEAd4XdLxJ7kwfSglOSvRDL
 gju9yYoTISZU9XlmdaKW2N/MuRlsvncUxMhUpQn3GDfgQ4k51U1S0cZ74hLNjQJeVMVQ
 EbnvZkEr5NacsjRa+JxYx0VvzOU9dtHtZXXPSRLayuu8uN/DPZHuebIKlgmJgdRpsWGQ
 LTug==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1730828088; x=1731432888;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=s/rhYTFaXP3Dh+7hwLcaAA/f6wFylNETvCvMZV+1+jw=;
 b=Y9CwHDs9tTwTNjrNuWcECI3hX4cLIBqLPUnt4BbonMA8hlfR5uuEALQDt4WXY1Bd5L
 /Ho+11kmaclfBImBz1Bl6vqHfZJMxj0Hbt5oOY75KjbFHAp3V1EiH3SC1ippLWQUSpzn
 lTvwAuqVgy6gqLCHyrjNVYJgHHqLXEfCX2puEgwLjWIPbuUtrhvqIZ5Qg7HCc9rTKl3P
 MAIMR2KAjo3HVmLVM/NoZuqkt6tUojdtsDa7n4BUc58eNql+sRmyElSrUHgg+qYNx6MP
 oC17SYOwm1OCYWcmjG34w2h80GLz9WPbzi8ZDaa/V3mYH700VRD2rH0oCJHC+f0f02h+
 ZY+Q==
X-Forwarded-Encrypted: i=1;
 AJvYcCUmknRKcRqyvwOT0zQwGZze1lW7Vy6W+LsiEVqJIXxGpD5H+EH8O+cZMhtp0UJGTlt4QhK4fKnQADe/B8Q=@lists.lustre.org
X-Gm-Message-State: AOJu0Yy0mkM/Cpl/BKGmLCzemNzS+DXoCePJrM/v/PzVhMjjeQ8wyPwB
 Lc5Af/CzCqvcB15p3deDOmeZU31N7ur3YeqmXkc4ZtWOAZ0WPAnHTMMUH2MlOXzbmTOfG0oF2/4
 3qBt77kVAwmjh6xjuY5f2yPdyjSTbr0TW
X-Google-Smtp-Source: AGHT+IHfKiH5SxZLYSSGKNCZ+ReM2RPtYcIhppa7fBECanrKiA0vMuVXp2sTW8C4HGliBlhqFfkklOWSh8BIEB4uXDk=
X-Received: by 2002:a05:6e02:1c87:b0:3a6:c27a:6383 with SMTP id
 e9e14a558f8ab-3a6c27a665amr117081895ab.19.1730828087812; Tue, 05 Nov 2024
 09:34:47 -0800 (PST)
MIME-Version: 1.0
From: Backer <backer.kolo@gmail.com>
Date: Tue, 5 Nov 2024 12:34:36 -0500
Message-ID: <CAPq+oA+JR=CxnOQ-ERto7DMW7QuyMo6xuqa5CxGjPUE2xZwb+g@mail.gmail.com>
To: Backer via lustre-discuss <lustre-discuss@lists.lustre.org>,
 lustre-devel@lists.lustre.org
Subject: [lustre-devel] Lustre switching to loop back lnet interface when it
 is not desired
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
Content-Type: multipart/mixed; boundary="===============3948452406150143387=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3948452406150143387==
Content-Type: multipart/alternative; boundary="00000000000057710e06262dd16f"

--00000000000057710e06262dd16f
Content-Type: text/plain; charset="UTF-8"

Hi,

Mounting the Lustre file file system on the OSS. Some of the OSTs are
locally attached to the OSS.

The failover IP on the OST is "10.99.100.152". It is a local lnet on the
OSS. However, when the client mounts it, the import automatically changes
to 0@lo. It is undesirable here because when this OST fails over to another
server, the client is still trying to connect to 0@lo while it is no longer
on the same host. This makes the client fs mount hangs for ever.

Here the failover is designed in such a way that the IP address moves
(fails over) with OST and becomes active on the other server.

How can I make the import pointing to the real IP and not the loopback? (so
that the failover works)


[oss000 ~]$ lfs df
UUID                   1K-blocks        Used   Available Use% Mounted on
fs-MDT0000_UUID     29068444       25692    26422344   1% /mnt/fs[MDT:0]
fs-OST0000_UUID     50541812    30160292    17743696  63% /mnt/fs[OST:0]
fs-OST0001_UUID     50541812    29301740    18602248  62% /mnt/fs[OST:1]
fs-OST0002_UUID     50541812    29356508    18547480  62% /mnt/fs[OST:2]
fs-OST0003_UUID     50541812     8822980    39081008  19% /mnt/fs[OST:3]

filesystem_summary:    202167248    97641520    93974432  51% /mnt/fs

[oss000 ~]$ df -h
Filesystem                  Size  Used Avail Use% Mounted on
devtmpfs                     30G     0   30G   0% /dev
tmpfs                        30G  8.1M   30G   1% /dev/shm
tmpfs                        30G   25M   30G   1% /run
tmpfs                        30G     0   30G   0% /sys/fs/cgroup
/dev/mapper/ocivolume-root   36G   17G   19G  48% /
/dev/sdc2                  1014M  637M  378M  63% /boot
/dev/mapper/ocivolume-oled   10G  2.5G  7.6G  25% /var/oled
/dev/sdc1                   100M  5.1M   95M   6% /boot/efi
tmpfs                       5.9G     0  5.9G   0% /run/user/987
tmpfs                       5.9G     0  5.9G   0% /run/user/0
/dev/sdb                     49G   28G   18G  62% /fs-OST0001
/dev/sda                     49G   29G   17G  63% /fs-OST0000
tmpfs                       5.9G     0  5.9G   0% /run/user/1000
10.99.100.221@tcp1:/fs  193G   94G   90G  51% /mnt/fs

[oss000 ~]$ sudo tunefs.lustre --dryrun /dev/sda
checking for existing Lustre data: found

   Read previous values:
Target:     fs-OST0000
Index:      0
Lustre FS:  fs
Mount type: ldiskfs
Flags:      0x1002
              (OST no_primnode )
Persistent mount opts: ,errors=remount-ro
Parameters: mgsnode=10.99.100.221@tcp1 failover.node=10.99.100.152@tcp1
,10.99.100.152@tcp1


   Permanent disk data:
Target:     fs-OST0000
Index:      0
Lustre FS:  fs
Mount type: ldiskfs
Flags:      0x1002
              (OST no_primnode )
Persistent mount opts: ,errors=remount-ro
Parameters: mgsnode=10.99.100.221@tcp1 failover.node=10.99.100.152@tcp1
,10.99.100.152@tcp1

exiting before disk write.


[oss000 proc]# cat
/proc/fs/lustre/osc/fs-OST0000-osc-ffff89c57672e000/import
import:
    name: fs-OST0000-osc-ffff89c57672e000
    target: fs-OST0000_UUID
    state: IDLE
    connect_flags: [ write_grant, server_lock, version, request_portal,
max_byte_per_rpc, early_lock_cancel, adaptive_timeouts, lru_resize,
alt_checksum_algorithm, fid_is_enabled, version_recovery, grant_shrink,
full20, layout_lock, 64bithash, object_max_bytes, jobstats, einprogress,
grant_param, lvb_type, short_io, lfsck, bulk_mbits, second_flags,
lockaheadv2, increasing_xid, client_encryption, lseek, reply_mbits ]
    connect_data:
       flags: 0xa0425af2e3440078
       instance: 39
       target_version: 2.15.3.0
       initial_grant: 8437760
       max_brw_size: 4194304
       grant_block_size: 4096
       grant_inode_size: 32
       grant_max_extent_size: 67108864
       grant_extent_tax: 24576
       cksum_types: 0xf7
       max_object_bytes: 17592186040320
    import_flags: [ replayable, pingable, connect_tried ]
    connection:
       failover_nids: [ 0@lo, 0@lo ]
       current_connection: 0@lo
       connection_attempts: 1
       generation: 1
       in-progress_invalidations: 0
       idle: 36 sec
    rpcs:
       inflight: 0
       unregistering: 0
       timeouts: 0
       avg_waittime: 2627 usec
    service_estimates:
       services: 1 sec
       network: 1 sec
    transactions:
       last_replay: 0
       peer_committed: 0
       last_checked: 0

--00000000000057710e06262dd16f
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi,<div><br></div>Mounting the Lustre file file system on =
the OSS. Some of the OSTs are locally attached to the OSS. <br><br>The fail=
over IP on the OST is &quot;10.99.100.152&quot;. It is a local lnet on the =
OSS. However, when the client mounts it, the import automatically changes t=
o 0@lo. It is undesirable here because when this OST fails over to another =
server, the client is still trying to connect to 0@lo while it is no longer=
 on the same host. This makes the client fs mount hangs for ever. =C2=A0<br=
><br>Here the failover is designed in such a way that the IP address moves =
(fails over) with OST and becomes active on the other server. <br><br>How c=
an I make the import pointing to the real IP and not the loopback? (so that=
 the failover works)<div><span style=3D"font-family:monospace"></span></div=
><div><span style=3D"font-family:monospace"><br></span></div><div><br></div=
><font face=3D"monospace">[oss000 ~]$ lfs df<br>UUID =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1K-blocks =C2=A0 =C2=A0 =C2=A0 =
=C2=A0Used =C2=A0 Available Use% Mounted on<br>fs-MDT0000_UUID =C2=A0 =C2=
=A0 29068444 =C2=A0 =C2=A0 =C2=A0 25692 =C2=A0 =C2=A026422344 =C2=A0 1% /mn=
t/fs[MDT:0]<br>fs-OST0000_UUID =C2=A0 =C2=A0 50541812 =C2=A0 =C2=A030160292=
 =C2=A0 =C2=A017743696 =C2=A063% /mnt/fs[OST:0]<br>fs-OST0001_UUID =C2=A0 =
=C2=A0 50541812 =C2=A0 =C2=A029301740 =C2=A0 =C2=A018602248 =C2=A062% /mnt/=
fs[OST:1]<br>fs-OST0002_UUID =C2=A0 =C2=A0 50541812 =C2=A0 =C2=A029356508 =
=C2=A0 =C2=A018547480 =C2=A062% /mnt/fs[OST:2]<br>fs-OST0003_UUID =C2=A0 =
=C2=A0 50541812 =C2=A0 =C2=A0 8822980 =C2=A0 =C2=A039081008 =C2=A019% /mnt/=
fs[OST:3]<br><br>filesystem_summary: =C2=A0 =C2=A0202167248 =C2=A0 =C2=A097=
641520 =C2=A0 =C2=A093974432 =C2=A051% /mnt/fs<br><br>[oss000 ~]$ df -h<br>=
Filesystem =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Si=
ze =C2=A0Used Avail Use% Mounted on<br>devtmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 30G =C2=A0 =C2=A0 0 =C2=A0 30G =
=C2=A0 0% /dev<br>tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A030G =C2=A08.1M =C2=A0 30G =C2=A0 1% /dev/=
shm<br>tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A030G =C2=A0 25M =C2=A0 30G =C2=A0 1% /run<br>tmpfs =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A030G =C2=A0 =C2=A0 0 =C2=A0 30G =C2=A0 0% /sys/fs/cgroup<br>/dev/mappe=
r/ocivolume-root =C2=A0 36G =C2=A0 17G =C2=A0 19G =C2=A048% /<br>/dev/sdc2 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01014M =C2=A06=
37M =C2=A0378M =C2=A063% /boot<br>/dev/mapper/ocivolume-oled =C2=A0 10G =C2=
=A02.5G =C2=A07.6G =C2=A025% /var/oled<br>/dev/sdc1 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 100M =C2=A05.1M =C2=A0 95M =C2=A0=
 6% /boot/efi<br>tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 5.9G =C2=A0 =C2=A0 0 =C2=A05.9G =C2=A0 0% /run/use=
r/987<br>tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 5.9G =C2=A0 =C2=A0 0 =C2=A05.9G =C2=A0 0% /run/user/0<br>=
/dev/sdb =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 49G =C2=A0 28G =C2=A0 18G =C2=A062% /fs-OST0001<br>/dev/sda =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 49G =C2=A0 29G =
=C2=A0 17G =C2=A063% /fs-OST0000<br>tmpfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 5.9G =C2=A0 =C2=A0 0 =C2=A05.=
9G =C2=A0 0% /run/user/1000<br>10.99.100.221@tcp1:/fs =C2=A0193G =C2=A0 94G=
 =C2=A0 90G =C2=A051% /mnt/fs<br><br>[oss000 ~]$ sudo tunefs.lustre --dryru=
n /dev/sda<br>checking for existing Lustre data: found<br><br>=C2=A0 =C2=A0=
Read previous values:<br>Target: =C2=A0 =C2=A0 fs-OST0000<br>Index: =C2=A0 =
=C2=A0 =C2=A00<br>Lustre FS: =C2=A0fs<br>Mount type: ldiskfs<br>Flags: =C2=
=A0 =C2=A0 =C2=A00x1002<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 (OST no_primnode )<br>Persistent mount opts: ,errors=3Dremount-ro<br>Param=
eters: mgsnode=3D10.99.100.221@tcp1 failover.node=3D10.99.100.152@tcp1,10.9=
9.100.152@tcp1<br><br><br>=C2=A0 =C2=A0Permanent disk data:<br>Target: =C2=
=A0 =C2=A0 fs-OST0000<br>Index: =C2=A0 =C2=A0 =C2=A00<br>Lustre FS: =C2=A0f=
s<br>Mount type: ldiskfs<br>Flags: =C2=A0 =C2=A0 =C2=A00x1002<br>=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (OST no_primnode )<br>Persistent mou=
nt opts: ,errors=3Dremount-ro<br>Parameters: mgsnode=3D10.99.100.221@tcp1 f=
ailover.node=3D10.99.100.152@tcp1,10.99.100.152@tcp1<br><br>exiting before =
disk write.<br><br><br>[oss000 proc]# cat /proc/fs/lustre/osc/fs-OST0000-os=
c-ffff89c57672e000/import<br>import:<br>=C2=A0 =C2=A0 name: fs-OST0000-osc-=
ffff89c57672e000<br>=C2=A0 =C2=A0 target: fs-OST0000_UUID<br>=C2=A0 =C2=A0 =
state: IDLE<br>=C2=A0 =C2=A0 connect_flags: [ write_grant, server_lock, ver=
sion, request_portal, max_byte_per_rpc, early_lock_cancel, adaptive_timeout=
s, lru_resize, alt_checksum_algorithm, fid_is_enabled, version_recovery, gr=
ant_shrink, full20, layout_lock, 64bithash, object_max_bytes, jobstats, ein=
progress, grant_param, lvb_type, short_io, lfsck, bulk_mbits, second_flags,=
 lockaheadv2, increasing_xid, client_encryption, lseek, reply_mbits ]<br>=
=C2=A0 =C2=A0 connect_data:<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0flags: 0xa0425af2=
e3440078<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0instance: 39<br>=C2=A0 =C2=A0 =C2=A0=
 =C2=A0target_version: 2.15.3.0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0initial_grant=
: 8437760<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0max_brw_size: 4194304<br>=C2=A0 =C2=
=A0 =C2=A0 =C2=A0grant_block_size: 4096<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0grant=
_inode_size: 32<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0grant_max_extent_size: 671088=
64<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0grant_extent_tax: 24576<br>=C2=A0 =C2=A0 =
=C2=A0 =C2=A0cksum_types: 0xf7<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0max_object_byt=
es: 17592186040320<br>=C2=A0 =C2=A0 import_flags: [ replayable, pingable, c=
onnect_tried ]<br>=C2=A0 =C2=A0 connection:<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0f=
ailover_nids: [ 0@lo, 0@lo ]<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0current_connecti=
on: 0@lo<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0connection_attempts: 1<br>=C2=A0 =C2=
=A0 =C2=A0 =C2=A0generation: 1<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0in-progress_in=
validations: 0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0idle: 36 sec<br>=C2=A0 =C2=A0 =
rpcs:<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0inflight: 0<br>=C2=A0 =C2=A0 =C2=A0 =C2=
=A0unregistering: 0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0timeouts: 0<br>=C2=A0 =C2=
=A0 =C2=A0 =C2=A0avg_waittime: 2627 usec<br>=C2=A0 =C2=A0 service_estimates=
:<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0services: 1 sec<br>=C2=A0 =C2=A0 =C2=A0 =C2=
=A0network: 1 sec<br>=C2=A0 =C2=A0 transactions:<br>=C2=A0 =C2=A0 =C2=A0 =
=C2=A0last_replay: 0<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0peer_committed: 0<br>=C2=
=A0 =C2=A0 =C2=A0 =C2=A0last_checked: 0</font></div>

--00000000000057710e06262dd16f--

--===============3948452406150143387==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3948452406150143387==--
