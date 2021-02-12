Return-Path: <SRS0=5zKb=HO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF115C433E0
	for <lustre-devel@archiver.kernel.org>; Fri, 12 Feb 2021 23:08:03 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 43FE564DAD
	for <lustre-devel@archiver.kernel.org>; Fri, 12 Feb 2021 23:08:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43FE564DAD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=opendrives.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D452021F989;
	Fri, 12 Feb 2021 15:08:02 -0800 (PST)
Received: from mail-ed1-f51.google.com (mail-ed1-f51.google.com
 [209.85.208.51])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A747921F8DD
 for <lustre-devel@lists.lustre.org>; Fri, 12 Feb 2021 15:08:00 -0800 (PST)
Received: by mail-ed1-f51.google.com with SMTP id g21so1661733edm.6
 for <lustre-devel@lists.lustre.org>; Fri, 12 Feb 2021 15:08:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=opendrives-com.20150623.gappssmtp.com; s=20150623;
 h=mime-version:from:date:message-id:subject:to;
 bh=evQ+NFWCA1vtg+YQ0VHqRCjaWdPzO41ecv4lKo+wjWs=;
 b=g7DEMj1Tgzu87vdQHxk1yPbkjXw4+2/mUlNtVl0cwZkI/PAqLiq1d/4Nj0H0ltthYJ
 0VX7SHDT75W7IQ3QlrlKi0N7jauAk/ED5jW+hK1ivd5flVqTkbwN1G0wFRnkrPkBkdTe
 MCgV5Mz0wOcoLI+0LFgOkPtwUipuquelF7TiVpu3tKb7HZ9mcWcBPAQNgNW93OwmGP5v
 kxW/igckZ8A6cB3qclOJ+z4WAyo504g40/UZDPnzwnimPMd+CReOLTX5fysQ6w/zu2E4
 CNzlThrIwMqj3vslzTT+elUxON6+rZ0FwUM12xfp9OF7Dz1LyLpajit+9Wl5UnHHcWKJ
 BwkQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
 bh=evQ+NFWCA1vtg+YQ0VHqRCjaWdPzO41ecv4lKo+wjWs=;
 b=dxw7ZK6vSkQ62e07Qkyjg+YM5FVzIV5C7E5qFUPvJwR4iQmbSlOu0DLxyfDCXeZ/HL
 jwWebjVzkb4tIF6xWLsgjFBtHBnhFTmdsT7qZjqrwxJdF71Giny6b7ZsiS0KLKnK2iRP
 bZDayox2ByZTm5z7KxXlrw1Zr73r6WRisrl5MnxbW4xUpzvHOjWwLaP+5bUmHs/Oqp0f
 WtSHB+rVpjLCEqOLZpo3twMPkXRZJlaGiz2OTH2Ld2hG0iZ0Nf2SuMRiWHku31dR5t0L
 7lNl4GCpaZsQce9DyKCW3/SZUUYmqmr7ST9xUh1WbZNBMU/Pu7+RDvmwqEhlq/9RX8WT
 LsKA==
X-Gm-Message-State: AOAM533KRZUsOlYzXPUsanWCi4Jyb1G1zXYPr7S0c2JK2yse/5rDvTOf
 zwL1SJT97M9IssTxYEYQGI1rjcFky+9N92EneTbHA6mIuXsnBbPP
X-Google-Smtp-Source: ABdhPJweNNvu7k1VQ+VzigfyaG1qWmTZH9KHfID1vvmEP8AFHRXjTNXFCMNJsxS6qUCtoemGoDvKUqX1mySeQAdRew0=
X-Received: by 2002:a50:ccc1:: with SMTP id b1mr5864942edj.307.1613171279194; 
 Fri, 12 Feb 2021 15:07:59 -0800 (PST)
MIME-Version: 1.0
From: Christian Kuntz <c.kuntz@opendrives.com>
Date: Fri, 12 Feb 2021 15:07:47 -0800
Message-ID: <CANdLGj7=6X1ixcyNOguUAzxTTnegD3h2zfgaEso+Fv5E7YejVA@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Testing 2.14 on Debian + ZFS
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Content-Type: multipart/mixed; boundary="===============0281945477457439437=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0281945477457439437==
Content-Type: multipart/alternative; boundary="0000000000000efed805bb2bb593"

--0000000000000efed805bb2bb593
Content-Type: text/plain; charset="UTF-8"

Hello,

I hope I'm communicating in the right place here, I'm currently working to
compile Lustre 2.14.0-RC2 on Debian 10.7 with ZFS 2.0.2 for OSDs. If
there's anything I can do to help with the testing effort or help Lustre's
Debian support be more robust, please let me know! I hope I'm not too late
in the release cycle to contribute.

On the topic of compiling, I'm currently working to get debian packages
made and running into a compilation issue that didn't seem to present on my
previous endeavors with 2.13 and 0.7. I've got the kernel and zfs locally
built and their packages made, and lustre's configure step successfully
completes, but when it comes to compiling it appears that the osd-zfs
portion has some broken include links:

In file included from /zfs-linux-2.0.2/include/sys/arc.h:32,
                 from /lustre-debian/lustre/osd-zfs/osd_internal.h:51,
                 from /lustre-debian/lustre/osd-zfs/osd_handler.c:52:
/zfs-linux-2.0.2/include/sys/zfs_context.h:45:10: fatal error: sys/types.h:
No such file or directory
 #include <sys/types.h>

For reference, my configure and make looks like:
./configure --with-linux=/linux-4.19.171-2/  \

 --with-linux-obj=linux-4.19.171-2/debian/build/build_amd64_none_amd64 \
             --with-zfs=/zfs-linux-2.0.2 \
              --enable-server --enable-modules --disable-ldiskfs
make -j"$(nproc)" debs


From the error and some probing, it looks like zfs_context.h expects some
header files to be in their libc standard `/usr/include/sys` (or somewhere
abouts), but lustre's make process is pulling them from the linux sources
in `SRC/include/linux/`. Predictably, I found this out the hard way by
adding `-I/usr/include` to the Makefile for the zfs osds and getting
battered with errors and warnings about duplicate definitions.

I'm more than happy to provide more detailed information on my setup, and
any and all suggestions/guidance is greatly appreciated!



Best regards,
Christian

--0000000000000efed805bb2bb593
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello,<br><br>I hope I&#39;m communicating in the right pl=
ace here, I&#39;m currently working to compile Lustre 2.14.0-RC2 on Debian =
10.7 with ZFS 2.0.2 for OSDs. If there&#39;s anything I can do to help with=
 the testing effort or help Lustre&#39;s Debian support be more robust, ple=
ase let me know! I hope I&#39;m not too late in the release cycle to contri=
bute.=C2=A0<br><br>On the topic of compiling, I&#39;m currently working to =
get debian packages made and running into a compilation issue that didn&#39=
;t seem to present on my previous endeavors with 2.13 and 0.7. I&#39;ve got=
 the kernel and zfs locally built and their packages made, and lustre&#39;s=
 configure step successfully completes, but when it comes to compiling it a=
ppears that the osd-zfs portion has some broken include links:<br><br>In fi=
le included from /zfs-linux-2.0.2/include/sys/arc.h:32,<br>=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0from /lustre-debian/lustre/=
osd-zfs/osd_internal.h:51,<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0from /lustre-debian/lustre/osd-zfs/osd_handler.c:52:<br>/z=
fs-linux-2.0.2/include/sys/zfs_context.h:45:10: fatal error: sys/types.h: N=
o such file or directory<br>=C2=A0#include &lt;sys/types.h&gt;<br><br>For r=
eference, my configure and make looks like:<br>./configure --with-linux=3D/=
linux-4.19.171-2/=C2=A0 \<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0--with-linux-obj=3Dlinux-4.19.171-2/debian/build/build_amd64_none_amd64 =
\<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0--with-zfs=3D/zfs-linu=
x-2.0.2 \<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 --enable-serv=
er --enable-modules --disable-ldiskfs<br>make -j&quot;$(nproc)&quot; debs<b=
r><br><br>From the error and some probing, it looks like zfs_context.h expe=
cts some header files to be in their libc standard `/usr/include/sys` (or s=
omewhere abouts), but lustre&#39;s make process is pulling them from the li=
nux sources in `SRC/include/linux/`. Predictably, I found this out the hard=
 way by adding `-I/usr/include` to the Makefile for the zfs osds and gettin=
g battered with errors and warnings about duplicate definitions.=C2=A0<br><=
br>I&#39;m more than happy to provide more detailed information on my setup=
, and any and all suggestions/guidance is greatly appreciated!<br><br><br><=
br>Best regards,<br>Christian</div>

--0000000000000efed805bb2bb593--

--===============0281945477457439437==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0281945477457439437==--
