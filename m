Return-Path: <SRS0=W2nY=HV=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8BA8C433E0
	for <lustre-devel@archiver.kernel.org>; Fri, 19 Feb 2021 09:11:22 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 58F9664EAF
	for <lustre-devel@archiver.kernel.org>; Fri, 19 Feb 2021 09:11:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58F9664EAF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=opendrives.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1DEDF21F662;
	Fri, 19 Feb 2021 01:11:21 -0800 (PST)
Received: from mail-ej1-f51.google.com (mail-ej1-f51.google.com
 [209.85.218.51])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 947F821F55D
 for <lustre-devel@lists.lustre.org>; Fri, 19 Feb 2021 01:11:18 -0800 (PST)
Received: by mail-ej1-f51.google.com with SMTP id u20so10604820ejb.7
 for <lustre-devel@lists.lustre.org>; Fri, 19 Feb 2021 01:11:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=opendrives-com.20150623.gappssmtp.com; s=20150623;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=kGcXSXlaNR4Zd/4g2wntHEqj3deoVgvUyY2HBv+Vt78=;
 b=pse67KmVMBivqxr94CZLz932scNBaMVRlAG46KBtlGNLfs8r8pUHQQao0fk7rbYVkn
 nKM2MCBhiNB3yek+NdY183JwMxSklJ+lFmrCoBztHDN8gEG77gfj1NjWN+Y43GIsxCAX
 QgoNhoPomnVFmQRjiI9fbNLUDKdhe/PFZk6dAkaeAs8hFd5jupd5t7+TPpl8ykItz98X
 Dy7juKhAxVfp7bha8sID6NIjoNJdQlIW6ogcL1oS8m18W6UXm4qZOWCm+40CY46Q9lM+
 NlGI37qFvLLHcwTY8idqkTxsR0zCtPNsaOiUkOC650+BLy2gVL49bYKUb9xHUb/RnJqH
 rYDA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=kGcXSXlaNR4Zd/4g2wntHEqj3deoVgvUyY2HBv+Vt78=;
 b=PibYHfUjGsVKEA6mbMuv70lsN/4bgBdxgl2IESDP4Pr2Ozq9jRKeobfZf2xr4wFPDR
 1w1PvTGgyOfgMHGch6PxOJJxivbhevADMQIvAss4xLyZrI/qp/Bnu0itN0BHqHXDOwNi
 WjZM2L2SMey0h1pdU7iWMN8sp1ysxCozbYuFT2AT2X1WTqWAO/CHjQ2Nd2uHYw+AVB6c
 XDB5ngjzptTLKDH4VH4cupF3RUBzTpB0/Qi8cYE68QBS8SqYZvoW1ZJykGQxMaYzeLbC
 o+35am1KFXATIh8M9rwbMH8XG9WidThm8s0xdQU0zNxTPpTQPniW5B7JDmFTPeUhEnWZ
 xUmQ==
X-Gm-Message-State: AOAM5330HmUMxs9OPqFG5pAeWLtRAbhr6QaLbnbnSngwFoaonTQ1Sgws
 /TOUqao9GPeqj2SJmzGAd1726dm9GSmFaf5i8sQh4g==
X-Google-Smtp-Source: ABdhPJz93vPGOyjkhUzwYtoj6pCNkqBUpl6RUqG0SlbKoRTwxzQ4k9OiYikQv3fzJEsZI1GQmUjWCEbory0rXS724IQ=
X-Received: by 2002:a17:906:296a:: with SMTP id
 x10mr7779378ejd.240.1613725877355; 
 Fri, 19 Feb 2021 01:11:17 -0800 (PST)
MIME-Version: 1.0
References: <CANdLGj7=6X1ixcyNOguUAzxTTnegD3h2zfgaEso+Fv5E7YejVA@mail.gmail.com>
 <477F0D07-A7E1-488A-8E06-FE6C2E748FE1@whamcloud.com>
In-Reply-To: <477F0D07-A7E1-488A-8E06-FE6C2E748FE1@whamcloud.com>
From: Christian Kuntz <c.kuntz@opendrives.com>
Date: Fri, 19 Feb 2021 01:11:06 -0800
Message-ID: <CANdLGj7o4yJf3byyM4LaAm+ZfNkAswTjU+HSUeK2yK+Yw4cvVg@mail.gmail.com>
To: Andreas Dilger <adilger@whamcloud.com>
Subject: Re: [lustre-devel] Testing 2.14 on Debian + ZFS
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
Cc: Lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============5388388819044896542=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============5388388819044896542==
Content-Type: multipart/alternative; boundary="000000000000af56da05bbacd593"

--000000000000af56da05bbacd593
Content-Type: text/plain; charset="UTF-8"

Thanks for your time and the thoughtful response.

Looking at this a bit more, it seems to be caused by the recent ZFS 2.0
changes for linux and freebsd support, namely the `include/os/linux` paths
that provide `<sys/types.h>` that ZFS is trying to use. Adding them into
the includes for the osd-zfs directory has fixed the references being
broken, and now I'm contending some redefinitions and argument type
mismatches. I'll try and sort this out, in the meantime is there a better
place for me to place messages about this? I know this mailing list isn't
used very frequently and I'd hate to flood it with such off-the-beaten-path
stuff.

Best,
Christian

On Thu, Feb 18, 2021 at 3:09 AM Andreas Dilger <adilger@whamcloud.com>
wrote:

> On Feb 12, 2021, at 16:07, Christian Kuntz <c.kuntz@opendrives.com> wrote:
>
>
> Hello,
>
> I hope I'm communicating in the right place here, I'm currently working to
> compile Lustre 2.14.0-RC2 on Debian 10.7 with ZFS 2.0.2 for OSDs. If
> there's anything I can do to help with the testing effort or help Lustre's
> Debian support be more robust, please let me know! I hope I'm not too late
> in the release cycle to contribute.
>
>
> Thanks for the offer of testing.  Unfortunately we are very late in the
> 2.14.0 release cycle (we are hoping to make the final release in the next
> week or so, barring any critical defects).  However, even if any changes
> miss the final 2.14.0 release, having patches available to fix any issues
> you run into will make it easier for the next person to build on Debian.
>
> Ideally, any required fixes for Debian building should go into the Lustre
> tree directly rather than into a separate "downstream" package, so that
> "make debs" works out-of-the-box.  We do build Ubuntu 18.04 and 20.04
> clients regularly, and ZFS 2.0 servers on RHEL7/8, but I don't know if
> anyone is building the server code on Debian/Ubuntu on a regular basis.
>
> On the topic of compiling, I'm currently working to get debian packages
> made and running into a compilation issue that didn't seem to present on my
> previous endeavors with 2.13 and 0.7. I've got the kernel and zfs locally
> built and their packages made, and lustre's configure step successfully
> completes, but when it comes to compiling it appears that the osd-zfs
> portion has some broken include links:
>
> In file included from /zfs-linux-2.0.2/include/sys/arc.h:32,
>                  from /lustre-debian/lustre/osd-zfs/osd_internal.h:51,
>                  from /lustre-debian/lustre/osd-zfs/osd_handler.c:52:
> /zfs-linux-2.0.2/include/sys/zfs_context.h:45:10: fatal error:
> sys/types.h: No such file or directory
>  #include <sys/types.h>
>
> For reference, my configure and make looks like:
> ./configure --with-linux=/linux-4.19.171-2/  \
>
>  --with-linux-obj=linux-4.19.171-2/debian/build/build_amd64_none_amd64 \
>              --with-zfs=/zfs-linux-2.0.2 \
>               --enable-server --enable-modules --disable-ldiskfs
> make -j"$(nproc)" debs
>
>
> From the error and some probing, it looks like zfs_context.h expects some
> header files to be in their libc standard `/usr/include/sys` (or somewhere
> abouts), but lustre's make process is pulling them from the linux sources
> in `SRC/include/linux/`. Predictably, I found this out the hard way by
> adding `-I/usr/include` to the Makefile for the zfs osds and getting
> battered with errors and warnings about duplicate definitions.
>
>
> It may be that you are looking at this from the wrong angle.  Rather than
> trying to include more userspace headers, it might be worthwhile to see why
> <sys/arc.h> is being included by osd_internal.h and maybe there is a more
> appropriate header that could be used in the kernel?  Failing that, it
> isn't clear wh zfs_context.h is including the <sys/type.h> header from
> userspace when building with __KERNEL__ set?  Kernel code should be using
> <linux/types.h>.
>
> Cheers, Andreas
> --
> Andreas Dilger
> Principal Lustre Architect
> Whamcloud
>
>
>
>
>
>
>

--000000000000af56da05bbacd593
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Thanks for your time and the thoughtful response.<br><br>L=
ooking at this a bit more, it seems=C2=A0to be caused by the recent ZFS 2.0=
 changes for linux and freebsd support, namely=C2=A0the `include/os/linux` =
paths that=C2=A0provide `&lt;sys/types.h&gt;` that ZFS is trying to use. Ad=
ding them into the includes for the osd-zfs directory has fixed the referen=
ces being broken, and now I&#39;m contending some redefinitions and argumen=
t type mismatches. I&#39;ll try and sort this out, in the meantime is there=
 a better place for me to place messages about this? I know this mailing li=
st isn&#39;t used very frequently and I&#39;d hate to flood it with such of=
f-the-beaten-path stuff.<br><br>Best,<br>Christian</div><br><div class=3D"g=
mail_quote"><div dir=3D"ltr" class=3D"gmail_attr">On Thu, Feb 18, 2021 at 3=
:09 AM Andreas Dilger &lt;<a href=3D"mailto:adilger@whamcloud.com" target=
=3D"_blank">adilger@whamcloud.com</a>&gt; wrote:<br></div><blockquote class=
=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rg=
b(204,204,204);padding-left:1ex">



<div>
On Feb 12, 2021, at 16:07, Christian Kuntz &lt;<a href=3D"mailto:c.kuntz@op=
endrives.com" target=3D"_blank">c.kuntz@opendrives.com</a>&gt; wrote:<br>
<div>
<blockquote type=3D"cite"><br>
<div>
<div dir=3D"ltr">Hello,<br>
<br>
I hope I&#39;m communicating in the right place here, I&#39;m currently wor=
king to compile Lustre 2.14.0-RC2 on Debian 10.7 with ZFS 2.0.2 for OSDs. I=
f there&#39;s anything I can do to help with the testing effort or help Lus=
tre&#39;s Debian support be more robust, please
 let me know! I hope I&#39;m not too late in the release cycle to contribut=
e.=C2=A0<br>
</div>
</div>
</blockquote>
<div><br>
</div>
Thanks for the offer of testing.=C2=A0 Unfortunately we are very late in th=
e 2.14.0 release cycle (we are hoping to make the final release in the next=
 week or so, barring any critical defects).=C2=A0 However, even if any chan=
ges miss the final 2.14.0 release, having
 patches available to fix any issues you run into will make it easier for t=
he next person to build on Debian.</div>
<div><br>
</div>
<div>Ideally, any required fixes for Debian building should go into the Lus=
tre tree directly rather than into a separate &quot;downstream&quot; packag=
e, so that &quot;make debs&quot; works out-of-the-box.=C2=A0 We do build Ub=
untu 18.04 and 20.04 clients regularly, and ZFS 2.0 servers
 on RHEL7/8, but I don&#39;t know if anyone is building the server code on =
Debian/Ubuntu on a regular basis. =C2=A0</div>
<div><br>
<blockquote type=3D"cite">
<div>
<div dir=3D"ltr">On the topic of compiling, I&#39;m currently working to ge=
t debian packages made and running into a compilation issue that didn&#39;t=
 seem to present on my previous endeavors with 2.13 and 0.7. I&#39;ve got t=
he kernel and zfs locally built and their
 packages made, and lustre&#39;s configure step successfully completes, but=
 when it comes to compiling it appears that the osd-zfs portion has some br=
oken include links:<br>
<br>
In file included from /zfs-linux-2.0.2/include/sys/arc.h:32,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0from /lustre-=
debian/lustre/osd-zfs/osd_internal.h:51,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0from /lustre-=
debian/lustre/osd-zfs/osd_handler.c:52:<br>
/zfs-linux-2.0.2/include/sys/zfs_context.h:45:10: fatal error: sys/types.h:=
 No such file or directory<br>
=C2=A0#include &lt;sys/types.h&gt;<br>
<br>
For reference, my configure and make looks like:<br>
./configure --with-linux=3D/linux-4.19.171-2/=C2=A0 \<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0--with-linux-obj=3Dlinux-4.=
19.171-2/debian/build/build_amd64_none_amd64 \<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0--with-zfs=3D/zfs-linux-2.0=
.2 \<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 --enable-server --enable-m=
odules --disable-ldiskfs<br>
make -j&quot;$(nproc)&quot; debs<br>
<br>
<br>
From the error and some probing, it looks like zfs_context.h expects some h=
eader files to be in their libc standard `/usr/include/sys` (or somewhere a=
bouts), but lustre&#39;s make process is pulling them from the linux source=
s in `SRC/include/linux/`. Predictably,
 I found this out the hard way by adding `-I/usr/include` to the Makefile f=
or the zfs osds and getting battered with errors and warnings about duplica=
te definitions.=C2=A0<br>
</div>
</div>
</blockquote>
<br>
</div>
<div>It may be that you are looking at this from the wrong angle.=C2=A0 Rat=
her than trying to include more userspace headers, it might be worthwhile t=
o see why &lt;sys/arc.h&gt; is being included by osd_internal.h and maybe t=
here is a more appropriate header that could
 be used in the kernel?=C2=A0 Failing that, it isn&#39;t clear wh zfs_conte=
xt.h is including the &lt;sys/type.h&gt; header from userspace when buildin=
g with __KERNEL__ set?=C2=A0 Kernel code should be using &lt;linux/types.h&=
gt;.</div>
<br>
<div>
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div>Cheers, Andreas</div>
<div>--</div>
<div>Andreas Dilger</div>
<div>Principal Lustre Architect</div>
<div>Whamcloud</div>
<div><br>
</div>
<div><br>
</div>
<div><br>
</div>
</div>
</div>
</div>
</div>
</div>
<br>
<br>
</div>
<br>
</div>

</blockquote></div>

--000000000000af56da05bbacd593--

--===============5388388819044896542==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5388388819044896542==--
