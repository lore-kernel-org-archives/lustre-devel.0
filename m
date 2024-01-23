Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 79E0DC47DDB
	for <lustre-devel@archiver.kernel.org>; Tue, 23 Jan 2024 17:03:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4TKD1R0gTdz1y7L;
	Tue, 23 Jan 2024 09:03:07 -0800 (PST)
Received: from mail-ed1-f54.google.com (mail-ed1-f54.google.com
 [209.85.208.54])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4TKD1H42qTz1y3q
 for <lustre-devel@lists.lustre.org>; Tue, 23 Jan 2024 09:02:59 -0800 (PST)
Received: by mail-ed1-f54.google.com with SMTP id
 4fb4d7f45d1cf-55a5e7fa471so4036374a12.1
 for <lustre-devel@lists.lustre.org>; Tue, 23 Jan 2024 09:02:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1706029377; x=1706634177; darn=lists.lustre.org;
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=Qrkknl7jk6Rndp+QypoCz3e6jJczVZnX+FP77zKzsF8=;
 b=AO7X7Utb/NdrZm1pfmXAIBwtfi+JnsKh97dCxZGv8+SYoyapud+Qw9rq8BqumKmtgy
 hsveyxBeMqpmXzRckmf/7e7ljRqrL5sNMfukB3M/g+Sm7EP2R0ixgBTxtv4pWYAeWqNm
 LIEUvnYD73lb5jiqkbcHqAuRSYj/gmVtZ/c2y/m9sVpYtkClD2A6b9DbwO9E6bGtk9Ik
 0+ri5KVxDk4+m3E0z5U4ZgAv0zG417wQtoNOWmO0+ZlJNKVP2YZw4c6l38GkrhOU16Ek
 c7TqO96c/ntRVoSr6mt6XeowOUuci2+1JCBBLDbb7x49gaTzS2XwXxo9He9edngDOYz0
 qp9A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1706029377; x=1706634177;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=Qrkknl7jk6Rndp+QypoCz3e6jJczVZnX+FP77zKzsF8=;
 b=vSIETqigY8Hui8E1CwNB6/JAEvKwb6eBA9jy9cDyCedV9zBlPefvdcN7A98pqqKHys
 xc4I7Sm6XmIExdTtLK6RiCPR5AOdJCfYlpHeGVvsb/cVHRhjj2zHBIxrTkU4cqZJJMrx
 Iy734Xg1HtkqEegwJYziRt9YoK91u+CGXAPc3Jzf/pOC3JntVe4nJDrm/LDYhGzXxwpq
 RxDbjYdkkh9fdmG/alMRoWTyHB/Rf8GHwh4Ieb+hWD9wMeuf+sukLjnBk0FwcJ+S2Mga
 eI4V7De9yh75Vn5tRMLwS3y9KD1ZUGAbJA4QMyDnVMcamfXgh6lepuKb+yEAlMCzXxTe
 FC1w==
X-Gm-Message-State: AOJu0YwLXcybMLw7/HdggUZMK1tCxV2nzv67SmMeDiiICYRQYKoft1dZ
 JUyFNo58tYT7z+PODLBKQurUdiBlLoRSwflrWC5glsI/jWQK/hyEpPmQMJHRIn5fnSRDK/BA9qo
 9XYoD/l0fOKVKLynBo8LgZAmxpbxVK5hZeIk=
X-Google-Smtp-Source: AGHT+IHtSas9G8Ym2xI30uwJViJEYY+E3tQWBwHXSBAP4z2LcI9vLHnNym1KigDbxltG2pFYCGdQdesLKF7h/YNXbNo=
X-Received: by 2002:a05:6402:3108:b0:55c:20f7:4ef8 with SMTP id
 dc8-20020a056402310800b0055c20f74ef8mr953625edb.23.1706029376917; Tue, 23 Jan
 2024 09:02:56 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 23 Jan 2024 12:02:44 -0500
Message-ID: <CAPq+oAL+kCR6aeDVjqa5t2L7nPrVYfyxACu_i47v4_uDEpY_2Q@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Strange behavior with tunefs.lustre. Is this a bug?
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
From: Backer via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Backer <backer.kolo@gmail.com>
Content-Type: multipart/mixed; boundary="===============2906123780242880016=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============2906123780242880016==
Content-Type: multipart/alternative; boundary="000000000000fcd5c9060f9fead3"

--000000000000fcd5c9060f9fead3
Content-Type: text/plain; charset="UTF-8"

I am seeing a behavior with tunefs.lustre. After changing the failover node
and trying to mount an OST, getting getting the following error:

The target service's index is already in use. (/dev/sdd)


After the above error, and performing --writeconf once, I can repeat these
steps (see below) any number of times and any OSS without --writeconf.


This is an effort to mount an OST to a new OSS. I reproduced this issue
after simplifying some steps and reproducing the behavior (see below)
consistently. I was wondering if anyone could help me to understand this?

[root@OSS-2 opc]# lctl list_nids

10.99.101.18@tcp1

[root@OSS-2 opc]#


[root@OSS-2 opc]# mkfs.lustre --reformat  --ost --fsname="testfs"
--index="64"  --mgsnode "10.99.101.6@tcp1" --mgsnode "10.99.101.7@tcp1"
--servicenode "10.99.101.18@tcp1" "/dev/sdd"


   Permanent disk data:

Target:     testfs:OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1062

              (OST first_time update no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.18@tcp1


device size = 51200MB

formatting backing filesystem ldiskfs on /dev/sdd

target name   testfs:OST0040

kilobytes     52428800

options        -J size=1024 -I 512 -i 69905 -q -O
extents,uninit_bg,mmp,dir_nlink,quota,project,huge_file,^fast_commit,flex_bg
-G 256 -E resize="4290772992",lazy_journal_init="0",lazy_itable_init="0" -F

mkfs_cmd = mke2fs -j -b 4096 -L testfs:OST0040  -J size=1024 -I 512 -i
69905 -q -O
extents,uninit_bg,mmp,dir_nlink,quota,project,huge_file,^fast_commit,flex_bg
-G 256 -E resize="4290772992",lazy_journal_init="0",lazy_itable_init="0" -F
/dev/sdd 52428800k

Writing CONFIGS/mountdata


[root@OSS-2 opc]# tunefs.lustre --dryrun /dev/sdd

checking for existing Lustre data: found


   Read previous values:

Target:     testfs-OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1062

              (OST first_time update no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.18@tcp1



   Permanent disk data:

Target:     testfs:OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1062

              (OST first_time update no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.18@tcp1


exiting before disk write.

[root@OSS-2 opc]#


[root@OSS-2 opc]# tunefs.lustre --erase-param failover.node --servicenode
10.99.101.18@tcp1 /dev/sdd

checking for existing Lustre data: found


   Read previous values:

Target:     testfs-OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1062

              (OST first_time update no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.18@tcp1



   Permanent disk data:

Target:     testfs:OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1062

              (OST first_time update no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.18@tcp1


Writing CONFIGS/mountdata


[root@OSS-2 opc]# mkdir /testfs-OST0040

[root@OSS-2 opc]# mount -t lustre /dev/sdd  /testfs-OST0040

mount.lustre: increased
'/sys/devices/platform/host5/session3/target5:0:0/5:0:0:1/block/sdd/queue/max_sectors_kb'
from 1024 to 16384

[root@OSS-2 opc]#


[root@OSS-2 opc]# tunefs.lustre --dryrun /dev/sdd

checking for existing Lustre data: found


   Read previous values:

Target:     testfs-OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1002

              (OST no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.18@tcp1



   Permanent disk data:

Target:     testfs-OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1002

              (OST no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.18@tcp1


exiting before disk write.

[root@OSS-2 opc]#



Going over to OSS-3 and trying to mount OST.  At this stage OSS-2 is
completely powered off.



[root@OSS-3 opc]# lctl list_nids

10.99.101.19@tcp1

[root@OSS-3 opc]#


Parameters looks same as OSS-2


[root@OSS-3 opc]#  tunefs.lustre --dryrun /dev/sdd

checking for existing Lustre data: found


   Read previous values:

Target:     testfs-OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1002

              (OST no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.18@tcp1



   Permanent disk data:

Target:     testfs-OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1002

              (OST no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.18@tcp1


exiting before disk write.

[root@OSS-3 opc]#


Changing failover node to current node.


[root@OSS-3 opc]# tunefs.lustre --erase-param failover.node --servicenode
10.99.101.19@tcp1 /dev/sdd

checking for existing Lustre data: found


   Read previous values:

Target:     testfs-OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1002

              (OST no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.18@tcp1



   Permanent disk data:

Target:     testfs-OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1042

              (OST update no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.19@tcp1



<waits here for MPP time out (multi mount protection>

After it completes the write, for some reason this OST is being marked as
'first_time' flag 0x1062 in next command.

[root@OSS-3 opc]#  tunefs.lustre --dryrun /dev/sdd

checking for existing Lustre data: found


   Read previous values:

Target:     testfs-OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1062

              (OST first_time update no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.19@tcp1



   Permanent disk data:

Target:     testfs:OST0040

Index:      64

Lustre FS:  testfs

Mount type: ldiskfs

Flags:      0x1062

              (OST first_time update no_primnode )

Persistent mount opts: ,errors=remount-ro

Parameters:  mgsnode=10.99.101.6@tcp1:10.99.101.7@tcp1
failover.node=10.99.101.19@tcp1


exiting before disk write.

[root@OSS-3 opc]#




Mount doesn't work here because it is marked as first time and this OST is
not first time as it was already mounted using OST-2 OSS, and MGS knows
about it.

[root@OSS-3 opc]#  mkdir /testfs-OST0040

[root@OSS-3 opc]# mount -t lustre /dev/sdd  /testfs-OST0040

mount.lustre: mount /dev/sdd at /testfs-OST0040 failed: Address already in
use

The target service's index is already in use. (/dev/sdd)

[root@OSS-3 opc]#


From here, if I do tunefs.lustre with --writeconf, it works. Once this is
done, repeating the above experiment any number of times on any servers
works fine as expected without using --writeconf. (FYI Note: --writeconfig
is mentioned as a dangerous command)

--000000000000fcd5c9060f9fead3
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>I am seeing a behavior with tunefs.lustre. After chan=
ging the failover node and trying to mount an OST, getting getting the foll=
owing error:=C2=A0</div><div><br></div><div><p style=3D"font-variant-numeri=
c:normal;font-variant-east-asian:normal;font-variant-alternates:normal;font=
-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14=
px;line-height:normal;font-family:Menlo;margin:0px;color:rgb(0,0,0)"><span =
style=3D"font-variant-ligatures:no-common-ligatures">The target service&#39=
;s index is already in use. (/dev/sdd)</span></p><p style=3D"font-variant-n=
umeric:normal;font-variant-east-asian:normal;font-variant-alternates:normal=
;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-si=
ze:14px;line-height:normal;font-family:Menlo;margin:0px;color:rgb(0,0,0)"><=
span style=3D"font-family:Arial,Helvetica,sans-serif;font-size:small;color:=
rgb(34,34,34)"><br></span></p><p style=3D"font-variant-numeric:normal;font-=
variant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;=
font-feature-settings:normal;font-stretch:normal;line-height:normal;margin:=
0px">After the above error, and performing --writeconf once, I can repeat t=
hese steps (see below) any number of times and any OSS without --writeconf.=
=C2=A0</p><p style=3D"font-variant-numeric:normal;font-variant-east-asian:n=
ormal;font-variant-alternates:normal;font-kerning:auto;font-feature-setting=
s:normal;font-stretch:normal;line-height:normal;margin:0px"><br></p><p styl=
e=3D"font-variant-numeric:normal;font-variant-east-asian:normal;font-varian=
t-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-str=
etch:normal;font-size:14px;line-height:normal;font-family:Menlo;margin:0px;=
color:rgb(0,0,0)"><span style=3D"font-family:Arial,Helvetica,sans-serif;fon=
t-size:small;color:rgb(34,34,34)">This is an effort to mount an OST to a ne=
w OSS. I reproduced this issue after simplifying=C2=A0some steps and reprod=
ucing the behavior (see below) consistently. I was wondering if anyone coul=
d help me to understand this?=C2=A0</span><br></p></div><div><br></div><div=
><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian=
:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-setti=
ngs:normal;font-stretch:normal;font-size:14px;line-height:normal;font-famil=
y:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-l=
igatures">[root@OSS-2 opc]# lctl list_nids</span></p><p style=3D"margin:0px=
;font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-al=
ternates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch=
:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0=
)"><span style=3D"font-variant-ligatures:no-common-ligatures">10.99.101.18@=
tcp1</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-vari=
ant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;font=
-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:nor=
mal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatur=
es:no-common-ligatures">[root@OSS-2 opc]#</span></p><p style=3D"margin:0px;=
font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alt=
ernates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:=
normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)=
;min-height:16px"><span style=3D"font-variant-ligatures:no-common-ligatures=
"></span><br></p><p style=3D"margin:0px;font-variant-numeric:normal;font-va=
riant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;fo=
nt-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:n=
ormal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligat=
ures:no-common-ligatures">[root@OSS-2 opc]# mkfs.lustre --reformat=C2=A0=C2=
=A0--ost --fsname=3D&quot;testfs&quot; --index=3D&quot;64&quot;=C2=A0=C2=A0=
--mgsnode &quot;10.99.101.6@tcp1&quot; --mgsnode &quot;10.99.101.7@tcp1&quo=
t; --servicenode &quot;10.99.101.18@tcp1&quot; &quot;/dev/sdd&quot;</span><=
/p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asi=
an:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-set=
tings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-fam=
ily:Menlo;color:rgb(0,0,0);min-height:16px"><span style=3D"font-variant-lig=
atures:no-common-ligatures"></span><br></p><p style=3D"margin:0px;font-vari=
ant-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:n=
ormal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;fo=
nt-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span s=
tyle=3D"font-variant-ligatures:no-common-ligatures">=C2=A0=C2=A0=C2=A0Perma=
nent disk data:</span></p><p style=3D"margin:0px;font-variant-numeric:norma=
l;font-variant-east-asian:normal;font-variant-alternates:normal;font-kernin=
g:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line=
-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-vari=
ant-ligatures:no-common-ligatures">Target:=C2=A0=C2=A0 =C2=A0=C2=A0testfs:O=
ST0040</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-va=
riant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;fo=
nt-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:n=
ormal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligat=
ures:no-common-ligatures">Index:=C2=A0 =C2=A0 =C2=A0=C2=A064</span></p><p s=
tyle=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:norm=
al;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:n=
ormal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Men=
lo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatu=
res">Lustre FS:=C2=A0=C2=A0testfs</span></p><p style=3D"margin:0px;font-var=
iant-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:=
normal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;f=
ont-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span =
style=3D"font-variant-ligatures:no-common-ligatures">Mount type: ldiskfs</s=
pan></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-eas=
t-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-featur=
e-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;fon=
t-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-c=
ommon-ligatures">Flags:=C2=A0 =C2=A0 =C2=A0=C2=A00x1062</span></p><p style=
=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;f=
ont-variant-alternates:normal;font-kerning:auto;font-feature-settings:norma=
l;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;c=
olor:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures"=
>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0(OST first_time upda=
te no_primnode )</span></p><p style=3D"margin:0px;font-variant-numeric:norm=
al;font-variant-east-asian:normal;font-variant-alternates:normal;font-kerni=
ng:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;lin=
e-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-var=
iant-ligatures:no-common-ligatures">Persistent mount opts: ,errors=3Dremoun=
t-ro</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-vari=
ant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;font=
-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:nor=
mal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatur=
es:no-common-ligatures">Parameters:=C2=A0=C2=A0mgsnode=3D10.99.101.6@tcp1:1=
0.99.101.7@tcp1 failover.node=3D10.99.101.18@tcp1</span></p><p style=3D"mar=
gin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-var=
iant-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-=
stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rg=
b(0,0,0);min-height:16px"><span style=3D"font-variant-ligatures:no-common-l=
igatures"></span><br></p><p style=3D"margin:0px;font-variant-numeric:normal=
;font-variant-east-asian:normal;font-variant-alternates:normal;font-kerning=
:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-=
height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-varia=
nt-ligatures:no-common-ligatures">device size =3D 51200MB</span></p><p styl=
e=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;=
font-variant-alternates:normal;font-kerning:auto;font-feature-settings:norm=
al;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;=
color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures=
">formatting backing filesystem ldiskfs on /dev/sdd</span></p><p style=3D"m=
argin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-v=
ariant-alternates:normal;font-kerning:auto;font-feature-settings:normal;fon=
t-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:=
rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures"><spa=
n style=3D"white-space-collapse: preserve;">	</span>target name=C2=A0=C2=A0=
=C2=A0testfs:OST0040</span></p><p style=3D"margin:0px;font-variant-numeric:=
normal;font-variant-east-asian:normal;font-variant-alternates:normal;font-k=
erning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px=
;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font=
-variant-ligatures:no-common-ligatures"><span style=3D"white-space-collapse=
: preserve;">	</span>kilobytes=C2=A0=C2=A0 =C2=A0=C2=A052428800</span></p><=
p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:n=
ormal;font-variant-alternates:normal;font-kerning:auto;font-feature-setting=
s:normal;font-stretch:normal;font-size:14px;line-height:normal;font-family:=
Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-lig=
atures"><span style=3D"white-space-collapse: preserve;">	</span>options=C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0-J size=3D1024 -I 512 -i 69905 -q -O extents,=
uninit_bg,mmp,dir_nlink,quota,project,huge_file,^fast_commit,flex_bg -G 256=
 -E resize=3D&quot;4290772992&quot;,lazy_journal_init=3D&quot;0&quot;,lazy_=
itable_init=3D&quot;0&quot; -F</span></p><p style=3D"margin:0px;font-varian=
t-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:nor=
mal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;font=
-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span sty=
le=3D"font-variant-ligatures:no-common-ligatures">mkfs_cmd =3D mke2fs -j -b=
 4096 -L testfs:OST0040=C2=A0=C2=A0-J size=3D1024 -I 512 -i 69905 -q -O ext=
ents,uninit_bg,mmp,dir_nlink,quota,project,huge_file,^fast_commit,flex_bg -=
G 256 -E resize=3D&quot;4290772992&quot;,lazy_journal_init=3D&quot;0&quot;,=
lazy_itable_init=3D&quot;0&quot; -F /dev/sdd 52428800k</span></p><p style=
=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;f=
ont-variant-alternates:normal;font-kerning:auto;font-feature-settings:norma=
l;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;c=
olor:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures"=
>Writing CONFIGS/mountdata</span></p><p style=3D"margin:0px;font-variant-nu=
meric:normal;font-variant-east-asian:normal;font-variant-alternates:normal;=
font-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-siz=
e:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16p=
x"><span style=3D"font-variant-ligatures:no-common-ligatures"></span><br></=
p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asia=
n:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-sett=
ings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-fami=
ly:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-=
ligatures">[root@OSS-2 opc]# tunefs.lustre --dryrun /dev/sdd</span></p><p s=
tyle=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:norm=
al;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:n=
ormal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Men=
lo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatu=
res">checking for existing Lustre data: found</span></p><p style=3D"margin:=
0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-variant=
-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-stre=
tch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,=
0,0);min-height:16px"><span style=3D"font-variant-ligatures:no-common-ligat=
ures"></span><br></p><p style=3D"margin:0px;font-variant-numeric:normal;fon=
t-variant-east-asian:normal;font-variant-alternates:normal;font-kerning:aut=
o;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-heig=
ht:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-l=
igatures:no-common-ligatures">=C2=A0=C2=A0=C2=A0Read previous values:</span=
></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-a=
sian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-s=
ettings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-f=
amily:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-comm=
on-ligatures">Target:=C2=A0=C2=A0 =C2=A0=C2=A0testfs-OST0040</span></p><p s=
tyle=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:norm=
al;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:n=
ormal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Men=
lo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatu=
res">Index:=C2=A0 =C2=A0 =C2=A0=C2=A064</span></p><p style=3D"margin:0px;fo=
nt-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alter=
nates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:no=
rmal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)">=
<span style=3D"font-variant-ligatures:no-common-ligatures">Lustre FS:=C2=A0=
=C2=A0testfs</span></p><p style=3D"margin:0px;font-variant-numeric:normal;f=
ont-variant-east-asian:normal;font-variant-alternates:normal;font-kerning:a=
uto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-he=
ight:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant=
-ligatures:no-common-ligatures">Mount type: ldiskfs</span></p><p style=3D"m=
argin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-v=
ariant-alternates:normal;font-kerning:auto;font-feature-settings:normal;fon=
t-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:=
rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">Flag=
s:=C2=A0 =C2=A0 =C2=A0=C2=A00x1062</span></p><p style=3D"margin:0px;font-va=
riant-numeric:normal;font-variant-east-asian:normal;font-variant-alternates=
:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;=
font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span=
 style=3D"font-variant-ligatures:no-common-ligatures">=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0(OST first_time update no_primnode )</span=
></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-a=
sian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-s=
ettings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-f=
amily:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-comm=
on-ligatures">Persistent mount opts: ,errors=3Dremount-ro</span></p><p styl=
e=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;=
font-variant-alternates:normal;font-kerning:auto;font-feature-settings:norm=
al;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;=
color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures=
">Parameters:=C2=A0=C2=A0mgsnode=3D10.99.101.6@tcp1:10.99.101.7@tcp1 failov=
er.node=3D10.99.101.18@tcp1</span></p><p style=3D"margin:0px;font-variant-n=
umeric:normal;font-variant-east-asian:normal;font-variant-alternates:normal=
;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-si=
ze:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16=
px"><span style=3D"font-variant-ligatures:no-common-ligatures"></span><br><=
/p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asi=
an:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-set=
tings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-fam=
ily:Menlo;color:rgb(0,0,0);min-height:16px"><span style=3D"font-variant-lig=
atures:no-common-ligatures"></span><br></p><p style=3D"margin:0px;font-vari=
ant-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:n=
ormal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;fo=
nt-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span s=
tyle=3D"font-variant-ligatures:no-common-ligatures">=C2=A0=C2=A0=C2=A0Perma=
nent disk data:</span></p><p style=3D"margin:0px;font-variant-numeric:norma=
l;font-variant-east-asian:normal;font-variant-alternates:normal;font-kernin=
g:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line=
-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-vari=
ant-ligatures:no-common-ligatures">Target:=C2=A0=C2=A0 =C2=A0=C2=A0testfs:O=
ST0040</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-va=
riant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;fo=
nt-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:n=
ormal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligat=
ures:no-common-ligatures">Index:=C2=A0 =C2=A0 =C2=A0=C2=A064</span></p><p s=
tyle=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:norm=
al;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:n=
ormal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Men=
lo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatu=
res">Lustre FS:=C2=A0=C2=A0testfs</span></p><p style=3D"margin:0px;font-var=
iant-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:=
normal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;f=
ont-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span =
style=3D"font-variant-ligatures:no-common-ligatures">Mount type: ldiskfs</s=
pan></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-eas=
t-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-featur=
e-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;fon=
t-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-c=
ommon-ligatures">Flags:=C2=A0 =C2=A0 =C2=A0=C2=A00x1062</span></p><p style=
=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;f=
ont-variant-alternates:normal;font-kerning:auto;font-feature-settings:norma=
l;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;c=
olor:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures"=
>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0(OST first_time upda=
te no_primnode )</span></p><p style=3D"margin:0px;font-variant-numeric:norm=
al;font-variant-east-asian:normal;font-variant-alternates:normal;font-kerni=
ng:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;lin=
e-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-var=
iant-ligatures:no-common-ligatures">Persistent mount opts: ,errors=3Dremoun=
t-ro</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-vari=
ant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;font=
-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:nor=
mal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatur=
es:no-common-ligatures">Parameters:=C2=A0=C2=A0mgsnode=3D10.99.101.6@tcp1:1=
0.99.101.7@tcp1 failover.node=3D10.99.101.18@tcp1</span></p><p style=3D"mar=
gin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-var=
iant-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-=
stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rg=
b(0,0,0);min-height:16px"><span style=3D"font-variant-ligatures:no-common-l=
igatures"></span><br></p><p style=3D"margin:0px;font-variant-numeric:normal=
;font-variant-east-asian:normal;font-variant-alternates:normal;font-kerning=
:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-=
height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-varia=
nt-ligatures:no-common-ligatures">exiting before disk write.</span></p><p s=
tyle=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:norm=
al;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:n=
ormal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Men=
lo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatu=
res">[root@OSS-2 opc]#</span></p><p style=3D"margin:0px;font-variant-numeri=
c:normal;font-variant-east-asian:normal;font-variant-alternates:normal;font=
-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14=
px;line-height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><=
span style=3D"font-variant-ligatures:no-common-ligatures"></span><br></p><p=
 style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:no=
rmal;font-variant-alternates:normal;font-kerning:auto;font-feature-settings=
:normal;font-stretch:normal;font-size:14px;line-height:normal;font-family:M=
enlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-liga=
tures">[root@OSS-2 opc]# tunefs.lustre --erase-param failover.node --servic=
enode 10.99.101.18@tcp1 /dev/sdd</span></p><p style=3D"margin:0px;font-vari=
ant-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:n=
ormal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;fo=
nt-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span s=
tyle=3D"font-variant-ligatures:no-common-ligatures">checking for existing L=
ustre data: found</span></p><p style=3D"margin:0px;font-variant-numeric:nor=
mal;font-variant-east-asian:normal;font-variant-alternates:normal;font-kern=
ing:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;li=
ne-height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><span =
style=3D"font-variant-ligatures:no-common-ligatures"></span><br></p><p styl=
e=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;=
font-variant-alternates:normal;font-kerning:auto;font-feature-settings:norm=
al;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;=
color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures=
">=C2=A0=C2=A0=C2=A0Read previous values:</span></p><p style=3D"margin:0px;=
font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alt=
ernates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:=
normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)=
"><span style=3D"font-variant-ligatures:no-common-ligatures">Target:=C2=A0=
=C2=A0 =C2=A0=C2=A0testfs-OST0040</span></p><p style=3D"margin:0px;font-var=
iant-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:=
normal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;f=
ont-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span =
style=3D"font-variant-ligatures:no-common-ligatures">Index:=C2=A0 =C2=A0 =
=C2=A0=C2=A064</span></p><p style=3D"margin:0px;font-variant-numeric:normal=
;font-variant-east-asian:normal;font-variant-alternates:normal;font-kerning=
:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-=
height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-varia=
nt-ligatures:no-common-ligatures">Lustre FS:=C2=A0=C2=A0testfs</span></p><p=
 style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:no=
rmal;font-variant-alternates:normal;font-kerning:auto;font-feature-settings=
:normal;font-stretch:normal;font-size:14px;line-height:normal;font-family:M=
enlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-liga=
tures">Mount type: ldiskfs</span></p><p style=3D"margin:0px;font-variant-nu=
meric:normal;font-variant-east-asian:normal;font-variant-alternates:normal;=
font-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-siz=
e:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=
=3D"font-variant-ligatures:no-common-ligatures">Flags:=C2=A0 =C2=A0 =C2=A0=
=C2=A00x1062</span></p><p style=3D"margin:0px;font-variant-numeric:normal;f=
ont-variant-east-asian:normal;font-variant-alternates:normal;font-kerning:a=
uto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-he=
ight:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant=
-ligatures:no-common-ligatures">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0=C2=A0(OST first_time update no_primnode )</span></p><p style=3D"marg=
in:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-vari=
ant-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-s=
tretch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb=
(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">Persist=
ent mount opts: ,errors=3Dremount-ro</span></p><p style=3D"margin:0px;font-=
variant-numeric:normal;font-variant-east-asian:normal;font-variant-alternat=
es:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:norma=
l;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><sp=
an style=3D"font-variant-ligatures:no-common-ligatures">Parameters:=C2=A0=
=C2=A0mgsnode=3D10.99.101.6@tcp1:10.99.101.7@tcp1 failover.node=3D10.99.101=
.18@tcp1</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-=
variant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;=
font-feature-settings:normal;font-stretch:normal;font-size:14px;line-height=
:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><span style=3D"=
font-variant-ligatures:no-common-ligatures"></span><br></p><p style=3D"marg=
in:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-vari=
ant-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-s=
tretch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb=
(0,0,0);min-height:16px"><span style=3D"font-variant-ligatures:no-common-li=
gatures"></span><br></p><p style=3D"margin:0px;font-variant-numeric:normal;=
font-variant-east-asian:normal;font-variant-alternates:normal;font-kerning:=
auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-h=
eight:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-varian=
t-ligatures:no-common-ligatures">=C2=A0=C2=A0=C2=A0Permanent disk data:</sp=
an></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east=
-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature=
-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;font=
-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-co=
mmon-ligatures">Target:=C2=A0=C2=A0 =C2=A0=C2=A0testfs:OST0040</span></p><p=
 style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:no=
rmal;font-variant-alternates:normal;font-kerning:auto;font-feature-settings=
:normal;font-stretch:normal;font-size:14px;line-height:normal;font-family:M=
enlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-liga=
tures">Index:=C2=A0 =C2=A0 =C2=A0=C2=A064</span></p><p style=3D"margin:0px;=
font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alt=
ernates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:=
normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)=
"><span style=3D"font-variant-ligatures:no-common-ligatures">Lustre FS:=C2=
=A0=C2=A0testfs</span></p><p style=3D"margin:0px;font-variant-numeric:norma=
l;font-variant-east-asian:normal;font-variant-alternates:normal;font-kernin=
g:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line=
-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-vari=
ant-ligatures:no-common-ligatures">Mount type: ldiskfs</span></p><p style=
=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;f=
ont-variant-alternates:normal;font-kerning:auto;font-feature-settings:norma=
l;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;c=
olor:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures"=
>Flags:=C2=A0 =C2=A0 =C2=A0=C2=A00x1062</span></p><p style=3D"margin:0px;fo=
nt-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alter=
nates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:no=
rmal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)">=
<span style=3D"font-variant-ligatures:no-common-ligatures">=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0(OST first_time update no_primnode =
)</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant=
-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-fe=
ature-settings:normal;font-stretch:normal;font-size:14px;line-height:normal=
;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:=
no-common-ligatures">Persistent mount opts: ,errors=3Dremount-ro</span></p>=
<p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:=
normal;font-variant-alternates:normal;font-kerning:auto;font-feature-settin=
gs:normal;font-stretch:normal;font-size:14px;line-height:normal;font-family=
:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-li=
gatures">Parameters:=C2=A0=C2=A0mgsnode=3D10.99.101.6@tcp1:10.99.101.7@tcp1=
 failover.node=3D10.99.101.18@tcp1</span></p><p style=3D"margin:0px;font-va=
riant-numeric:normal;font-variant-east-asian:normal;font-variant-alternates=
:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;=
font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0);min-he=
ight:16px"><span style=3D"font-variant-ligatures:no-common-ligatures"></spa=
n><br></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-e=
ast-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-feat=
ure-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;f=
ont-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no=
-common-ligatures">Writing CONFIGS/mountdata</span></p><p style=3D"margin:0=
px;font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-=
alternates:normal;font-kerning:auto;font-feature-settings:normal;font-stret=
ch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0=
,0);min-height:16px"><span style=3D"font-variant-ligatures:no-common-ligatu=
res"></span><br></p><p style=3D"margin:0px;font-variant-numeric:normal;font=
-variant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto=
;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-heigh=
t:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-li=
gatures:no-common-ligatures">[root@OSS-2 opc]# mkdir /testfs-OST0040</span>=
</p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-as=
ian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-se=
ttings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-fa=
mily:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-commo=
n-ligatures">[root@OSS-2 opc]# mount -t lustre /dev/sdd=C2=A0=C2=A0/testfs-=
OST0040</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-v=
ariant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;f=
ont-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:=
normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-liga=
tures:no-common-ligatures">mount.lustre: increased &#39;/sys/devices/platfo=
rm/host5/session3/target5:0:0/5:0:0:1/block/sdd/queue/max_sectors_kb&#39; f=
rom 1024 to 16384</span></p><p style=3D"margin:0px;font-variant-numeric:nor=
mal;font-variant-east-asian:normal;font-variant-alternates:normal;font-kern=
ing:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;li=
ne-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-va=
riant-ligatures:no-common-ligatures">[root@OSS-2 opc]#</span></p><p style=
=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;f=
ont-variant-alternates:normal;font-kerning:auto;font-feature-settings:norma=
l;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;c=
olor:rgb(0,0,0);min-height:16px"><span style=3D"font-variant-ligatures:no-c=
ommon-ligatures"></span><br></p><p style=3D"margin:0px;font-variant-numeric=
:normal;font-variant-east-asian:normal;font-variant-alternates:normal;font-=
kerning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14p=
x;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"fon=
t-variant-ligatures:no-common-ligatures">[root@OSS-2 opc]# tunefs.lustre --=
dryrun /dev/sdd</span></p><p style=3D"margin:0px;font-variant-numeric:norma=
l;font-variant-east-asian:normal;font-variant-alternates:normal;font-kernin=
g:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line=
-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-vari=
ant-ligatures:no-common-ligatures">checking for existing Lustre data: found=
</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-=
east-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-fea=
ture-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;=
font-family:Menlo;color:rgb(0,0,0);min-height:16px"><span style=3D"font-var=
iant-ligatures:no-common-ligatures"></span><br></p><p style=3D"margin:0px;f=
ont-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alte=
rnates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:n=
ormal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"=
><span style=3D"font-variant-ligatures:no-common-ligatures">=C2=A0=C2=A0=C2=
=A0Read previous values:</span></p><p style=3D"margin:0px;font-variant-nume=
ric:normal;font-variant-east-asian:normal;font-variant-alternates:normal;fo=
nt-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-size:=
14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"=
font-variant-ligatures:no-common-ligatures">Target:=C2=A0=C2=A0 =C2=A0=C2=
=A0testfs-OST0040</span></p><p style=3D"margin:0px;font-variant-numeric:nor=
mal;font-variant-east-asian:normal;font-variant-alternates:normal;font-kern=
ing:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;li=
ne-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-va=
riant-ligatures:no-common-ligatures">Index:=C2=A0 =C2=A0 =C2=A0=C2=A064</sp=
an></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east=
-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature=
-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;font=
-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-co=
mmon-ligatures">Lustre FS:=C2=A0=C2=A0testfs</span></p><p style=3D"margin:0=
px;font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-=
alternates:normal;font-kerning:auto;font-feature-settings:normal;font-stret=
ch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0=
,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">Mount type:=
 ldiskfs</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-=
variant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;=
font-feature-settings:normal;font-stretch:normal;font-size:14px;line-height=
:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-lig=
atures:no-common-ligatures">Flags:=C2=A0 =C2=A0 =C2=A0=C2=A00x1002</span></=
p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asia=
n:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-sett=
ings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-fami=
ly:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-=
ligatures">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0(OST no_pr=
imnode )</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-=
variant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;=
font-feature-settings:normal;font-stretch:normal;font-size:14px;line-height=
:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-lig=
atures:no-common-ligatures">Persistent mount opts: ,errors=3Dremount-ro</sp=
an></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east=
-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature=
-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;font=
-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-co=
mmon-ligatures">Parameters:=C2=A0=C2=A0mgsnode=3D10.99.101.6@tcp1:10.99.101=
.7@tcp1 failover.node=3D10.99.101.18@tcp1</span></p><p style=3D"margin:0px;=
font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alt=
ernates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:=
normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)=
;min-height:16px"><span style=3D"font-variant-ligatures:no-common-ligatures=
"></span><br></p><p style=3D"margin:0px;font-variant-numeric:normal;font-va=
riant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;fo=
nt-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:n=
ormal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><span style=3D"fo=
nt-variant-ligatures:no-common-ligatures"></span><br></p><p style=3D"margin=
:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-varian=
t-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-str=
etch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0=
,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">=C2=A0=C2=
=A0=C2=A0Permanent disk data:</span></p><p style=3D"margin:0px;font-variant=
-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:norm=
al;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-=
size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span styl=
e=3D"font-variant-ligatures:no-common-ligatures">Target:=C2=A0=C2=A0 =C2=A0=
=C2=A0testfs-OST0040</span></p><p style=3D"margin:0px;font-variant-numeric:=
normal;font-variant-east-asian:normal;font-variant-alternates:normal;font-k=
erning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px=
;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font=
-variant-ligatures:no-common-ligatures">Index:=C2=A0 =C2=A0 =C2=A0=C2=A064<=
/span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-e=
ast-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-feat=
ure-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;f=
ont-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no=
-common-ligatures">Lustre FS:=C2=A0=C2=A0testfs</span></p><p style=3D"margi=
n:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-varia=
nt-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-st=
retch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(=
0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">Mount ty=
pe: ldiskfs</span></p><p style=3D"margin:0px;font-variant-numeric:normal;fo=
nt-variant-east-asian:normal;font-variant-alternates:normal;font-kerning:au=
to;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-hei=
ght:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-=
ligatures:no-common-ligatures">Flags:=C2=A0 =C2=A0 =C2=A0=C2=A00x1002</span=
></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-a=
sian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-s=
ettings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-f=
amily:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-comm=
on-ligatures">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0(OST no=
_primnode )</span></p><p style=3D"margin:0px;font-variant-numeric:normal;fo=
nt-variant-east-asian:normal;font-variant-alternates:normal;font-kerning:au=
to;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-hei=
ght:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-=
ligatures:no-common-ligatures">Persistent mount opts: ,errors=3Dremount-ro<=
/span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-e=
ast-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-feat=
ure-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;f=
ont-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no=
-common-ligatures">Parameters:=C2=A0=C2=A0mgsnode=3D10.99.101.6@tcp1:10.99.=
101.7@tcp1 failover.node=3D10.99.101.18@tcp1</span></p><p style=3D"margin:0=
px;font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-=
alternates:normal;font-kerning:auto;font-feature-settings:normal;font-stret=
ch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0=
,0);min-height:16px"><span style=3D"font-variant-ligatures:no-common-ligatu=
res"></span><br></p><p style=3D"margin:0px;font-variant-numeric:normal;font=
-variant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto=
;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-heigh=
t:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-li=
gatures:no-common-ligatures">exiting before disk write.</span></p><p style=
=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;f=
ont-variant-alternates:normal;font-kerning:auto;font-feature-settings:norma=
l;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;c=
olor:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures"=
>[root@OSS-2 opc]#</span></p><p style=3D"margin:0px;font-variant-numeric:no=
rmal;font-variant-east-asian:normal;font-variant-alternates:normal;font-ker=
ning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;l=
ine-height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><span=
 style=3D"font-variant-ligatures:no-common-ligatures"></span><br></p><p sty=
le=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal=
;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:nor=
mal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo=
;color:rgb(0,0,0)"><br></p><p style=3D"margin:0px;font-variant-numeric:norm=
al;font-variant-east-asian:normal;font-variant-alternates:normal;font-kerni=
ng:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;lin=
e-height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><span s=
tyle=3D"color:rgb(34,34,34);font-family:Arial,Helvetica,sans-serif;font-siz=
e:small">Going over to OSS-3 and trying to mount OST.=C2=A0 At this stage O=
SS-2 is completely powered off.=C2=A0</span><br></p><p style=3D"margin:0px;=
font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alt=
ernates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:=
normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)=
;min-height:16px"><span style=3D"font-variant-ligatures:no-common-ligatures=
"></span><br></p><p style=3D"margin:0px;font-variant-numeric:normal;font-va=
riant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;fo=
nt-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:n=
ormal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><span style=3D"fo=
nt-variant-ligatures:no-common-ligatures"></span><br></p><p style=3D"margin=
:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-varian=
t-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-str=
etch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0=
,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">[root@OSS=
-3 opc]# lctl list_nids=C2=A0</span></p><p style=3D"margin:0px;font-variant=
-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:norm=
al;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-=
size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span styl=
e=3D"font-variant-ligatures:no-common-ligatures">10.99.101.19@tcp1</span></=
p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asia=
n:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-sett=
ings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-fami=
ly:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-=
ligatures">[root@OSS-3 opc]#</span></p><p style=3D"margin:0px;font-variant-=
numeric:normal;font-variant-east-asian:normal;font-variant-alternates:norma=
l;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-s=
ize:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:1=
6px"><span style=3D"font-variant-ligatures:no-common-ligatures"></span><br>=
</p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-as=
ian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-se=
ttings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-fa=
mily:Menlo;color:rgb(0,0,0);min-height:16px"><span style=3D"color:rgb(34,34=
,34);font-family:Arial,Helvetica,sans-serif;font-size:small">Parameters loo=
ks same as OSS-2</span><br></p><p style=3D"margin:0px;font-variant-numeric:=
normal;font-variant-east-asian:normal;font-variant-alternates:normal;font-k=
erning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px=
;line-height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><sp=
an style=3D"font-variant-ligatures:no-common-ligatures"></span><br></p><p s=
tyle=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:norm=
al;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:n=
ormal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Men=
lo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatu=
res">[root@OSS-3 opc]#=C2=A0=C2=A0tunefs.lustre --dryrun /dev/sdd</span></p=
><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian=
:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-setti=
ngs:normal;font-stretch:normal;font-size:14px;line-height:normal;font-famil=
y:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-l=
igatures">checking for existing Lustre data: found</span></p><p style=3D"ma=
rgin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-va=
riant-alternates:normal;font-kerning:auto;font-feature-settings:normal;font=
-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:r=
gb(0,0,0);min-height:16px"><span style=3D"font-variant-ligatures:no-common-=
ligatures"></span><br></p><p style=3D"margin:0px;font-variant-numeric:norma=
l;font-variant-east-asian:normal;font-variant-alternates:normal;font-kernin=
g:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line=
-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-vari=
ant-ligatures:no-common-ligatures">=C2=A0=C2=A0=C2=A0Read previous values:<=
/span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-e=
ast-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-feat=
ure-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;f=
ont-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no=
-common-ligatures">Target:=C2=A0=C2=A0 =C2=A0=C2=A0testfs-OST0040</span></p=
><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian=
:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-setti=
ngs:normal;font-stretch:normal;font-size:14px;line-height:normal;font-famil=
y:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-l=
igatures">Index:=C2=A0 =C2=A0 =C2=A0=C2=A064</span></p><p style=3D"margin:0=
px;font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-=
alternates:normal;font-kerning:auto;font-feature-settings:normal;font-stret=
ch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0=
,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">Lustre FS:=
=C2=A0=C2=A0testfs</span></p><p style=3D"margin:0px;font-variant-numeric:no=
rmal;font-variant-east-asian:normal;font-variant-alternates:normal;font-ker=
ning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;l=
ine-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-v=
ariant-ligatures:no-common-ligatures">Mount type: ldiskfs</span></p><p styl=
e=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;=
font-variant-alternates:normal;font-kerning:auto;font-feature-settings:norm=
al;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;=
color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures=
">Flags:=C2=A0 =C2=A0 =C2=A0=C2=A00x1002</span></p><p style=3D"margin:0px;f=
ont-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alte=
rnates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:n=
ormal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"=
><span style=3D"font-variant-ligatures:no-common-ligatures">=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0(OST no_primnode )</span></p><p sty=
le=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal=
;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:nor=
mal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo=
;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligature=
s">Persistent mount opts: ,errors=3Dremount-ro</span></p><p style=3D"margin=
:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-varian=
t-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-str=
etch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0=
,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">Parameter=
s:=C2=A0=C2=A0mgsnode=3D10.99.101.6@tcp1:10.99.101.7@tcp1 failover.node=3D1=
0.99.101.18@tcp1</span></p><p style=3D"margin:0px;font-variant-numeric:norm=
al;font-variant-east-asian:normal;font-variant-alternates:normal;font-kerni=
ng:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;lin=
e-height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><span s=
tyle=3D"font-variant-ligatures:no-common-ligatures"></span><br></p><p style=
=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;f=
ont-variant-alternates:normal;font-kerning:auto;font-feature-settings:norma=
l;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;c=
olor:rgb(0,0,0);min-height:16px"><span style=3D"font-variant-ligatures:no-c=
ommon-ligatures"></span><br></p><p style=3D"margin:0px;font-variant-numeric=
:normal;font-variant-east-asian:normal;font-variant-alternates:normal;font-=
kerning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14p=
x;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"fon=
t-variant-ligatures:no-common-ligatures">=C2=A0=C2=A0=C2=A0Permanent disk d=
ata:</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-vari=
ant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;font=
-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:nor=
mal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatur=
es:no-common-ligatures">Target:=C2=A0=C2=A0 =C2=A0=C2=A0testfs-OST0040</spa=
n></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-=
asian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-=
settings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-=
family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-com=
mon-ligatures">Index:=C2=A0 =C2=A0 =C2=A0=C2=A064</span></p><p style=3D"mar=
gin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-var=
iant-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-=
stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rg=
b(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">Lustre=
 FS:=C2=A0=C2=A0testfs</span></p><p style=3D"margin:0px;font-variant-numeri=
c:normal;font-variant-east-asian:normal;font-variant-alternates:normal;font=
-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14=
px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"fo=
nt-variant-ligatures:no-common-ligatures">Mount type: ldiskfs</span></p><p =
style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:nor=
mal;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:=
normal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Me=
nlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligat=
ures">Flags:=C2=A0 =C2=A0 =C2=A0=C2=A00x1002</span></p><p style=3D"margin:0=
px;font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-=
alternates:normal;font-kerning:auto;font-feature-settings:normal;font-stret=
ch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0=
,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0(OST no_primnode )</span></p><p=
 style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:no=
rmal;font-variant-alternates:normal;font-kerning:auto;font-feature-settings=
:normal;font-stretch:normal;font-size:14px;line-height:normal;font-family:M=
enlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-liga=
tures">Persistent mount opts: ,errors=3Dremount-ro</span></p><p style=3D"ma=
rgin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-va=
riant-alternates:normal;font-kerning:auto;font-feature-settings:normal;font=
-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:r=
gb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">Param=
eters:=C2=A0=C2=A0mgsnode=3D10.99.101.6@tcp1:10.99.101.7@tcp1 failover.node=
=3D10.99.101.18@tcp1</span></p><p style=3D"margin:0px;font-variant-numeric:=
normal;font-variant-east-asian:normal;font-variant-alternates:normal;font-k=
erning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px=
;line-height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><sp=
an style=3D"font-variant-ligatures:no-common-ligatures"></span><br></p><p s=
tyle=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:norm=
al;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:n=
ormal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Men=
lo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatu=
res">exiting before disk write.</span></p><p style=3D"margin:0px;font-varia=
nt-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:no=
rmal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;fon=
t-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span st=
yle=3D"font-variant-ligatures:no-common-ligatures">[root@OSS-3 opc]#</span>=
</p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-as=
ian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-se=
ttings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-fa=
mily:Menlo;color:rgb(0,0,0);min-height:16px"><span style=3D"font-variant-li=
gatures:no-common-ligatures"></span><br></p><p style=3D"margin:0px;font-var=
iant-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:=
normal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;f=
ont-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span =
style=3D"color:rgb(34,34,34);font-family:Arial,Helvetica,sans-serif;font-si=
ze:small">Changing failover node to current node.</span><br></p><p style=3D=
"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font=
-variant-alternates:normal;font-kerning:auto;font-feature-settings:normal;f=
ont-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;colo=
r:rgb(0,0,0);min-height:16px"><span style=3D"font-variant-ligatures:no-comm=
on-ligatures"></span><br></p><p style=3D"margin:0px;font-variant-numeric:no=
rmal;font-variant-east-asian:normal;font-variant-alternates:normal;font-ker=
ning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;l=
ine-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-v=
ariant-ligatures:no-common-ligatures">[root@OSS-3 opc]# tunefs.lustre --era=
se-param failover.node --servicenode 10.99.101.19@tcp1 /dev/sdd</span></p><=
p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:n=
ormal;font-variant-alternates:normal;font-kerning:auto;font-feature-setting=
s:normal;font-stretch:normal;font-size:14px;line-height:normal;font-family:=
Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-lig=
atures">checking for existing Lustre data: found</span></p><p style=3D"marg=
in:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-vari=
ant-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-s=
tretch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb=
(0,0,0);min-height:16px"><span style=3D"font-variant-ligatures:no-common-li=
gatures"></span><br></p><p style=3D"margin:0px;font-variant-numeric:normal;=
font-variant-east-asian:normal;font-variant-alternates:normal;font-kerning:=
auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-h=
eight:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-varian=
t-ligatures:no-common-ligatures">=C2=A0=C2=A0=C2=A0Read previous values:</s=
pan></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-eas=
t-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-featur=
e-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;fon=
t-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-c=
ommon-ligatures">Target:=C2=A0=C2=A0 =C2=A0=C2=A0testfs-OST0040</span></p><=
p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:n=
ormal;font-variant-alternates:normal;font-kerning:auto;font-feature-setting=
s:normal;font-stretch:normal;font-size:14px;line-height:normal;font-family:=
Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-lig=
atures">Index:=C2=A0 =C2=A0 =C2=A0=C2=A064</span></p><p style=3D"margin:0px=
;font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-al=
ternates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch=
:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0=
)"><span style=3D"font-variant-ligatures:no-common-ligatures">Lustre FS:=C2=
=A0=C2=A0testfs</span></p><p style=3D"margin:0px;font-variant-numeric:norma=
l;font-variant-east-asian:normal;font-variant-alternates:normal;font-kernin=
g:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line=
-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-vari=
ant-ligatures:no-common-ligatures">Mount type: ldiskfs</span></p><p style=
=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;f=
ont-variant-alternates:normal;font-kerning:auto;font-feature-settings:norma=
l;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;c=
olor:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures"=
>Flags:=C2=A0 =C2=A0 =C2=A0=C2=A00x1002</span></p><p style=3D"margin:0px;fo=
nt-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alter=
nates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:no=
rmal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)">=
<span style=3D"font-variant-ligatures:no-common-ligatures">=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0(OST no_primnode )</span></p><p sty=
le=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal=
;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:nor=
mal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo=
;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligature=
s">Persistent mount opts: ,errors=3Dremount-ro</span></p><p style=3D"margin=
:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-varian=
t-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-str=
etch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0=
,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">Parameter=
s:=C2=A0=C2=A0mgsnode=3D10.99.101.6@tcp1:10.99.101.7@tcp1 failover.node=3D1=
0.99.101.18@tcp1</span></p><p style=3D"margin:0px;font-variant-numeric:norm=
al;font-variant-east-asian:normal;font-variant-alternates:normal;font-kerni=
ng:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;lin=
e-height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><span s=
tyle=3D"font-variant-ligatures:no-common-ligatures"></span><br></p><p style=
=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;f=
ont-variant-alternates:normal;font-kerning:auto;font-feature-settings:norma=
l;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;c=
olor:rgb(0,0,0);min-height:16px"><span style=3D"font-variant-ligatures:no-c=
ommon-ligatures"></span><br></p><p style=3D"margin:0px;font-variant-numeric=
:normal;font-variant-east-asian:normal;font-variant-alternates:normal;font-=
kerning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14p=
x;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"fon=
t-variant-ligatures:no-common-ligatures">=C2=A0=C2=A0=C2=A0Permanent disk d=
ata:</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-vari=
ant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;font=
-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:nor=
mal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatur=
es:no-common-ligatures">Target:=C2=A0=C2=A0 =C2=A0=C2=A0testfs-OST0040</spa=
n></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-=
asian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-=
settings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-=
family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-com=
mon-ligatures">Index:=C2=A0 =C2=A0 =C2=A0=C2=A064</span></p><p style=3D"mar=
gin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-var=
iant-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-=
stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rg=
b(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">Lustre=
 FS:=C2=A0=C2=A0testfs</span></p><p style=3D"margin:0px;font-variant-numeri=
c:normal;font-variant-east-asian:normal;font-variant-alternates:normal;font=
-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14=
px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"fo=
nt-variant-ligatures:no-common-ligatures">Mount type: ldiskfs</span></p><p =
style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:nor=
mal;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:=
normal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Me=
nlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligat=
ures">Flags:=C2=A0 =C2=A0 =C2=A0=C2=A00x1042</span></p><p style=3D"margin:0=
px;font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-=
alternates:normal;font-kerning:auto;font-feature-settings:normal;font-stret=
ch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0=
,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0(OST update no_primnode )</span=
></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-a=
sian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-s=
ettings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-f=
amily:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-comm=
on-ligatures">Persistent mount opts: ,errors=3Dremount-ro</span></p><p styl=
e=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;=
font-variant-alternates:normal;font-kerning:auto;font-feature-settings:norm=
al;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;=
color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures=
">Parameters:=C2=A0=C2=A0mgsnode=3D10.99.101.6@tcp1:10.99.101.7@tcp1 failov=
er.node=3D10.99.101.19@tcp1</span></p><p style=3D"margin:0px;font-variant-n=
umeric:normal;font-variant-east-asian:normal;font-variant-alternates:normal=
;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-si=
ze:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16=
px"><span style=3D"font-variant-ligatures:no-common-ligatures"></span><br><=
/p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asi=
an:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-set=
tings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-fam=
ily:Menlo;color:rgb(0,0,0)"><br></p><div>&lt;waits here for MPP time out (m=
ulti mount protection&gt;</div><div><br></div><p style=3D"margin:0px;font-v=
ariant-numeric:normal;font-variant-east-asian:normal;font-variant-alternate=
s:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal=
;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0);min-h=
eight:16px"><span style=3D"font-variant-ligatures:no-common-ligatures"></sp=
an></p><div>After it completes the write, for some reason this OST is being=
 marked as &#39;first_time&#39; flag 0x1062 in next command.=C2=A0</div><di=
v><br></div><p style=3D"margin:0px;font-variant-numeric:normal;font-variant=
-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-fe=
ature-settings:normal;font-stretch:normal;font-size:14px;line-height:normal=
;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:=
no-common-ligatures">[root@OSS-3 opc]#=C2=A0=C2=A0tunefs.lustre --dryrun /d=
ev/sdd</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-va=
riant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;fo=
nt-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:n=
ormal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligat=
ures:no-common-ligatures">checking for existing Lustre data: found</span></=
p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asia=
n:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-sett=
ings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-fami=
ly:Menlo;color:rgb(0,0,0);min-height:16px"><span style=3D"font-variant-liga=
tures:no-common-ligatures"></span><br></p><p style=3D"margin:0px;font-varia=
nt-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:no=
rmal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;fon=
t-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span st=
yle=3D"font-variant-ligatures:no-common-ligatures">=C2=A0=C2=A0=C2=A0Read p=
revious values:</span></p><p style=3D"margin:0px;font-variant-numeric:norma=
l;font-variant-east-asian:normal;font-variant-alternates:normal;font-kernin=
g:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line=
-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-vari=
ant-ligatures:no-common-ligatures">Target:=C2=A0=C2=A0 =C2=A0=C2=A0testfs-O=
ST0040</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-va=
riant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;fo=
nt-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:n=
ormal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligat=
ures:no-common-ligatures">Index:=C2=A0 =C2=A0 =C2=A0=C2=A064</span></p><p s=
tyle=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:norm=
al;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:n=
ormal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Men=
lo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatu=
res">Lustre FS:=C2=A0=C2=A0testfs</span></p><p style=3D"margin:0px;font-var=
iant-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:=
normal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;f=
ont-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span =
style=3D"font-variant-ligatures:no-common-ligatures">Mount type: ldiskfs</s=
pan></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-eas=
t-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-featur=
e-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;fon=
t-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-c=
ommon-ligatures">Flags:=C2=A0 =C2=A0 =C2=A0=C2=A00x1062</span></p><p style=
=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;f=
ont-variant-alternates:normal;font-kerning:auto;font-feature-settings:norma=
l;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;c=
olor:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures"=
>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0(OST first_time upda=
te no_primnode )</span></p><p style=3D"margin:0px;font-variant-numeric:norm=
al;font-variant-east-asian:normal;font-variant-alternates:normal;font-kerni=
ng:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;lin=
e-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-var=
iant-ligatures:no-common-ligatures">Persistent mount opts: ,errors=3Dremoun=
t-ro</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-vari=
ant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;font=
-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:nor=
mal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatur=
es:no-common-ligatures">Parameters:=C2=A0=C2=A0mgsnode=3D10.99.101.6@tcp1:1=
0.99.101.7@tcp1 failover.node=3D10.99.101.19@tcp1</span></p><p style=3D"mar=
gin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-var=
iant-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-=
stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rg=
b(0,0,0);min-height:16px"><span style=3D"font-variant-ligatures:no-common-l=
igatures"></span><br></p><p style=3D"margin:0px;font-variant-numeric:normal=
;font-variant-east-asian:normal;font-variant-alternates:normal;font-kerning=
:auto;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-=
height:normal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><span sty=
le=3D"font-variant-ligatures:no-common-ligatures"></span><br></p><p style=
=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;f=
ont-variant-alternates:normal;font-kerning:auto;font-feature-settings:norma=
l;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;c=
olor:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures"=
>=C2=A0=C2=A0=C2=A0Permanent disk data:</span></p><p style=3D"margin:0px;fo=
nt-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alter=
nates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:no=
rmal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)">=
<span style=3D"font-variant-ligatures:no-common-ligatures">Target:=C2=A0=C2=
=A0 =C2=A0=C2=A0testfs:OST0040</span></p><p style=3D"margin:0px;font-varian=
t-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:nor=
mal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;font=
-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span sty=
le=3D"font-variant-ligatures:no-common-ligatures">Index:=C2=A0 =C2=A0 =C2=
=A0=C2=A064</span></p><p style=3D"margin:0px;font-variant-numeric:normal;fo=
nt-variant-east-asian:normal;font-variant-alternates:normal;font-kerning:au=
to;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-hei=
ght:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-=
ligatures:no-common-ligatures">Lustre FS:=C2=A0=C2=A0testfs</span></p><p st=
yle=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:norma=
l;font-variant-alternates:normal;font-kerning:auto;font-feature-settings:no=
rmal;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menl=
o;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatur=
es">Mount type: ldiskfs</span></p><p style=3D"margin:0px;font-variant-numer=
ic:normal;font-variant-east-asian:normal;font-variant-alternates:normal;fon=
t-kerning:auto;font-feature-settings:normal;font-stretch:normal;font-size:1=
4px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"f=
ont-variant-ligatures:no-common-ligatures">Flags:=C2=A0 =C2=A0 =C2=A0=C2=A0=
0x1062</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-va=
riant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;fo=
nt-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:n=
ormal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligat=
ures:no-common-ligatures">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
=C2=A0(OST first_time update no_primnode )</span></p><p style=3D"margin:0px=
;font-variant-numeric:normal;font-variant-east-asian:normal;font-variant-al=
ternates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch=
:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0=
)"><span style=3D"font-variant-ligatures:no-common-ligatures">Persistent mo=
unt opts: ,errors=3Dremount-ro</span></p><p style=3D"margin:0px;font-varian=
t-numeric:normal;font-variant-east-asian:normal;font-variant-alternates:nor=
mal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;font=
-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span sty=
le=3D"font-variant-ligatures:no-common-ligatures">Parameters:=C2=A0=C2=A0mg=
snode=3D10.99.101.6@tcp1:10.99.101.7@tcp1 failover.node=3D10.99.101.19@tcp1=
</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-=
east-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-fea=
ture-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;=
font-family:Menlo;color:rgb(0,0,0);min-height:16px"><span style=3D"font-var=
iant-ligatures:no-common-ligatures"></span><br></p><p style=3D"margin:0px;f=
ont-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alte=
rnates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:n=
ormal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"=
><span style=3D"font-variant-ligatures:no-common-ligatures">exiting before =
disk write.</span></p><p style=3D"margin:0px;font-variant-numeric:normal;fo=
nt-variant-east-asian:normal;font-variant-alternates:normal;font-kerning:au=
to;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-hei=
ght:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-=
ligatures:no-common-ligatures">[root@OSS-3 opc]#=C2=A0</span></p><p style=
=3D"margin:0px;font-variant-numeric:normal;font-variant-east-asian:normal;f=
ont-variant-alternates:normal;font-kerning:auto;font-feature-settings:norma=
l;font-stretch:normal;font-size:14px;line-height:normal;font-family:Menlo;c=
olor:rgb(0,0,0);min-height:16px"><span style=3D"font-variant-ligatures:no-c=
ommon-ligatures"></span><br></p><p style=3D"margin:0px;font-variant-numeric=
:normal;font-variant-east-asian:normal;font-variant-alternates:normal;font-=
kerning:auto;font-feature-settings:normal;font-stretch:normal;font-size:14p=
x;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><br></p><div><br><=
/div><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-east-a=
sian:normal;font-variant-alternates:normal;font-kerning:auto;font-feature-s=
ettings:normal;font-stretch:normal;font-size:14px;line-height:normal;font-f=
amily:Menlo;color:rgb(0,0,0);min-height:16px"><span style=3D"font-variant-l=
igatures:no-common-ligatures"></span></p><div>Mount doesn&#39;t work here b=
ecause it is marked as first time and this OST is not first time as it was =
already mounted=C2=A0using OST-2 OSS, and MGS knows about it.=C2=A0</div><d=
iv><br></div><p style=3D"margin:0px;font-variant-numeric:normal;font-varian=
t-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-f=
eature-settings:normal;font-stretch:normal;font-size:14px;line-height:norma=
l;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures=
:no-common-ligatures">[root@OSS-3 opc]#=C2=A0=C2=A0mkdir /testfs-OST0040</s=
pan></p><p style=3D"margin:0px;font-variant-numeric:normal;font-variant-eas=
t-asian:normal;font-variant-alternates:normal;font-kerning:auto;font-featur=
e-settings:normal;font-stretch:normal;font-size:14px;line-height:normal;fon=
t-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-ligatures:no-c=
ommon-ligatures">[root@OSS-3 opc]# mount -t lustre /dev/sdd=C2=A0=C2=A0/tes=
tfs-OST0040</span></p><p style=3D"margin:0px;font-variant-numeric:normal;fo=
nt-variant-east-asian:normal;font-variant-alternates:normal;font-kerning:au=
to;font-feature-settings:normal;font-stretch:normal;font-size:14px;line-hei=
ght:normal;font-family:Menlo;color:rgb(0,0,0)"><span style=3D"font-variant-=
ligatures:no-common-ligatures">mount.lustre: mount /dev/sdd at /testfs-OST0=
040 failed: Address already in use</span></p><p style=3D"margin:0px;font-va=
riant-numeric:normal;font-variant-east-asian:normal;font-variant-alternates=
:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:normal;=
font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)"><span=
 style=3D"font-variant-ligatures:no-common-ligatures">The target service&#3=
9;s index is already in use. (/dev/sdd)</span></p><p style=3D"margin:0px;fo=
nt-variant-numeric:normal;font-variant-east-asian:normal;font-variant-alter=
nates:normal;font-kerning:auto;font-feature-settings:normal;font-stretch:no=
rmal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(0,0,0)">=
<span style=3D"font-variant-ligatures:no-common-ligatures">[root@OSS-3 opc]=
#=C2=A0</span></p><p style=3D"margin:0px;font-variant-numeric:normal;font-v=
ariant-east-asian:normal;font-variant-alternates:normal;font-kerning:auto;f=
ont-feature-settings:normal;font-stretch:normal;font-size:14px;line-height:=
normal;font-family:Menlo;color:rgb(0,0,0);min-height:16px"><span style=3D"f=
ont-variant-ligatures:no-common-ligatures"></span><br></p><p style=3D"margi=
n:0px;font-variant-numeric:normal;font-variant-east-asian:normal;font-varia=
nt-alternates:normal;font-kerning:auto;font-feature-settings:normal;font-st=
retch:normal;font-size:14px;line-height:normal;font-family:Menlo;color:rgb(=
0,0,0)"><span style=3D"font-variant-ligatures:no-common-ligatures">From her=
e, if I do tunefs.lustre with --writeconf, it works. Once this is done, rep=
eating the above experiment any number of times on any servers works fine a=
s expected without using --writeconf. (FYI Note: --writeconfig is mentioned=
 as a dangerous command)</span></p><br class=3D"gmail-Apple-interchange-new=
line"></div></div>

--000000000000fcd5c9060f9fead3--

--===============2906123780242880016==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============2906123780242880016==--
