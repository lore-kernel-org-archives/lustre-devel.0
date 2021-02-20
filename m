Return-Path: <SRS0=M+uU=HW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82792C433E0
	for <lustre-devel@archiver.kernel.org>; Sat, 20 Feb 2021 03:01:09 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 16B8F61606
	for <lustre-devel@archiver.kernel.org>; Sat, 20 Feb 2021 03:01:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16B8F61606
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=opendrives.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2492F21FBE1;
	Fri, 19 Feb 2021 19:01:08 -0800 (PST)
Received: from mail-ej1-f53.google.com (mail-ej1-f53.google.com
 [209.85.218.53])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AD7D321FB65
 for <lustre-devel@lists.lustre.org>; Fri, 19 Feb 2021 19:01:05 -0800 (PST)
Received: by mail-ej1-f53.google.com with SMTP id g5so17714591ejt.2
 for <lustre-devel@lists.lustre.org>; Fri, 19 Feb 2021 19:01:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=opendrives-com.20150623.gappssmtp.com; s=20150623;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=abvad557k4vjf2B8Jzp3unrIigIyF+v3H2ANeyBgbYc=;
 b=1LtJMaKb7I9HkMlPkxhS1PIywsNPK8a+rC2SYco5AjByWuM9nToBOvk4h0k0XPorjt
 xoY/NgXW6U5pDumjmpoySCL2Qz9bRcLun5oNECm3KJ0BUBj4bX4OHsdmKgm2Wy1C+bZK
 bb6fPFckzWMsT22HsuycBskOsjMwl5ZDBfVEmkvFmd36Nu9FcPghoWAalQOIRkYaCzCP
 BAh5Flxd5aGz2IIY1wnteOdeh5fQQIDLott/NB9+5IuH/BWC4lJa+0w+/UmwK3omWwpV
 Xqzw4U8OKlzXYYmDZxPUI3Wh4V3u2nqFxXPoysf9qYwLPLo0XQMutTAiEvGUnIn5Qn5k
 w82A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=abvad557k4vjf2B8Jzp3unrIigIyF+v3H2ANeyBgbYc=;
 b=rVdYDAlt27RJH3ljBqsOp4O8wx4HdiCEs4eAdp/f8eV/JW4BwQ6dsvGzp+Nr7MeFcA
 t8N9GkBHIuRQAZV3OC4PcuyZ0xDSXhn+bXzdBFNVXy9CFL9RDMwcyv5YL72xjYfIH4Co
 xnFXYuYxumEXexfC8tY9iq9uUEedOM5/niPEpdDF/HTexQbFniJvD5pCRu++azssreg/
 g+TXOaZycisX7qKyHBF5F0vfHjrwvpD5nCzp7Zxy2NakWcabFXjhJ5B6ptNcbKJuI4t0
 ZfDkJNDHj/P+TfZgt5Y25YrGR8BVyAJMLep0q5B/h0tmnhHIqXJK+7qOEOONwMM5wcxj
 5y5w==
X-Gm-Message-State: AOAM531d5HSmcvzf14d8r5y4D7Dzuf1Rcec5ASz78QyMoOTGvi96gdEg
 1pBmmEX17xU3twjV2g+vrqZILZWG3ffIoOoIMwB1+Q==
X-Google-Smtp-Source: ABdhPJzUOpUbv6DrQ6yZTFs/+u67YojIYVV7mNK8nxdVK2MNHkzuvM91zAGdUHKWdkP9WI+oNE6XnmVe6omNBcFH/ZE=
X-Received: by 2002:a17:907:1b02:: with SMTP id
 mp2mr11734040ejc.419.1613790064219; 
 Fri, 19 Feb 2021 19:01:04 -0800 (PST)
MIME-Version: 1.0
References: <CANdLGj7=6X1ixcyNOguUAzxTTnegD3h2zfgaEso+Fv5E7YejVA@mail.gmail.com>
 <477F0D07-A7E1-488A-8E06-FE6C2E748FE1@whamcloud.com>
 <CANdLGj7o4yJf3byyM4LaAm+ZfNkAswTjU+HSUeK2yK+Yw4cvVg@mail.gmail.com>
 <E4233477-F17B-4DD4-BC89-4DEAAD4590E5@whamcloud.com>
In-Reply-To: <E4233477-F17B-4DD4-BC89-4DEAAD4590E5@whamcloud.com>
From: Christian Kuntz <c.kuntz@opendrives.com>
Date: Fri, 19 Feb 2021 19:00:53 -0800
Message-ID: <CANdLGj4nJPfc6WA1ZrOeGhfjX+60QX_v_2xC7XDbHuSMXN3KCA@mail.gmail.com>
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
Content-Type: multipart/mixed; boundary="===============7012750093139603677=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7012750093139603677==
Content-Type: multipart/alternative; boundary="000000000000852b4605bbbbc70d"

--000000000000852b4605bbbbc70d
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Thanks for the confirmation!

After going in a few circles, I think I've got it figured out and would
appreciate some pointers on how to proceed:

To preface, the way I'm building is from source-dirs after a package build
(which is admittedly kind of janky as I write it out now). It would appear
that the configure scripting will look in "zfs/include", and thus miss the
new "zfs/include/os/..." directories that hold some important header files,
causing configuration variables to miss-set in config.h thus creating the
compile-time problems of type mismatches and redefinitions I was seeing.

 I was able to confirm manually setting some of the configuration defs and
adding the new header dirs to the makefile fixed the problem, but I'm a
little confused as to how to proceed in patching. Since the configuration
scripting and the makefiles seem to expect only a single include-dir of
header files for both zfs and spl respectively, I'm wondering what the best
approach to patching this behavior would be.

Thanks for your time and consideration,
Christian

On Fri, Feb 19, 2021 at 12:13 PM Andreas Dilger <adilger@whamcloud.com>
wrote:

> This is exactly the right place for such discussions.
>
> Once you have patches, please submit to Gerrit for review, testing, and
> landing:
>
> https://wiki.lustre.org/Using_Gerrit
>
> Cheers, Andreas
>
> On Feb 19, 2021, at 02:11, Christian Kuntz <c.kuntz@opendrives.com> wrote=
:
>
> =EF=BB=BF
> Thanks for your time and the thoughtful response.
>
> Looking at this a bit more, it seems to be caused by the recent ZFS 2.0
> changes for linux and freebsd support, namely the `include/os/linux` path=
s
> that provide `<sys/types.h>` that ZFS is trying to use. Adding them into
> the includes for the osd-zfs directory has fixed the references being
> broken, and now I'm contending some redefinitions and argument type
> mismatches. I'll try and sort this out, in the meantime is there a better
> place for me to place messages about this? I know this mailing list isn't
> used very frequently and I'd hate to flood it with such off-the-beaten-pa=
th
> stuff.
>
> Best,
> Christian
>
> On Thu, Feb 18, 2021 at 3:09 AM Andreas Dilger <adilger@whamcloud.com>
> wrote:
>
>> On Feb 12, 2021, at 16:07, Christian Kuntz <c.kuntz@opendrives.com>
>> wrote:
>>
>>
>> Hello,
>>
>> I hope I'm communicating in the right place here, I'm currently working
>> to compile Lustre 2.14.0-RC2 on Debian 10.7 with ZFS 2.0.2 for OSDs. If
>> there's anything I can do to help with the testing effort or help Lustre=
's
>> Debian support be more robust, please let me know! I hope I'm not too la=
te
>> in the release cycle to contribute.
>>
>>
>> Thanks for the offer of testing.  Unfortunately we are very late in the
>> 2.14.0 release cycle (we are hoping to make the final release in the nex=
t
>> week or so, barring any critical defects).  However, even if any changes
>> miss the final 2.14.0 release, having patches available to fix any issue=
s
>> you run into will make it easier for the next person to build on Debian.
>>
>> Ideally, any required fixes for Debian building should go into the Lustr=
e
>> tree directly rather than into a separate "downstream" package, so that
>> "make debs" works out-of-the-box.  We do build Ubuntu 18.04 and 20.04
>> clients regularly, and ZFS 2.0 servers on RHEL7/8, but I don't know if
>> anyone is building the server code on Debian/Ubuntu on a regular basis.
>>
>> On the topic of compiling, I'm currently working to get debian packages
>> made and running into a compilation issue that didn't seem to present on=
 my
>> previous endeavors with 2.13 and 0.7. I've got the kernel and zfs locall=
y
>> built and their packages made, and lustre's configure step successfully
>> completes, but when it comes to compiling it appears that the osd-zfs
>> portion has some broken include links:
>>
>> In file included from /zfs-linux-2.0.2/include/sys/arc.h:32,
>>                  from /lustre-debian/lustre/osd-zfs/osd_internal.h:51,
>>                  from /lustre-debian/lustre/osd-zfs/osd_handler.c:52:
>> /zfs-linux-2.0.2/include/sys/zfs_context.h:45:10: fatal error:
>> sys/types.h: No such file or directory
>>  #include <sys/types.h>
>>
>> For reference, my configure and make looks like:
>> ./configure --with-linux=3D/linux-4.19.171-2/  \
>>
>>  --with-linux-obj=3Dlinux-4.19.171-2/debian/build/build_amd64_none_amd64=
 \
>>              --with-zfs=3D/zfs-linux-2.0.2 \
>>               --enable-server --enable-modules --disable-ldiskfs
>> make -j"$(nproc)" debs
>>
>>
>> From the error and some probing, it looks like zfs_context.h expects som=
e
>> header files to be in their libc standard `/usr/include/sys` (or somewhe=
re
>> abouts), but lustre's make process is pulling them from the linux source=
s
>> in `SRC/include/linux/`. Predictably, I found this out the hard way by
>> adding `-I/usr/include` to the Makefile for the zfs osds and getting
>> battered with errors and warnings about duplicate definitions.
>>
>>
>> It may be that you are looking at this from the wrong angle.  Rather tha=
n
>> trying to include more userspace headers, it might be worthwhile to see =
why
>> <sys/arc.h> is being included by osd_internal.h and maybe there is a mor=
e
>> appropriate header that could be used in the kernel?  Failing that, it
>> isn't clear wh zfs_context.h is including the <sys/type.h> header from
>> userspace when building with __KERNEL__ set?  Kernel code should be usin=
g
>> <linux/types.h>.
>>
>> Cheers, Andreas
>> --
>> Andreas Dilger
>> Principal Lustre Architect
>> Whamcloud
>>
>>
>>
>>
>>
>>
>>

--000000000000852b4605bbbbc70d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Thanks for the confirmation!=C2=A0<br><br>After going in a=
 few circles, I think I&#39;ve got it figured out and would appreciate some=
 pointers on how to proceed:<br><br>To preface, the way I&#39;m building is=
 from source-dirs after a package=C2=A0build (which is admittedly kind of j=
anky as I write it out now). It would appear that the configure scripting w=
ill look in &quot;zfs/include&quot;, and thus miss the new &quot;zfs/includ=
e/os/...&quot; directories that hold some important header files, causing c=
onfiguration variables to miss-set in config.h thus creating the compile-ti=
me problems of type mismatches and redefinitions I was seeing.<br><br>=C2=
=A0I was able to confirm manually setting some of the configuration defs an=
d adding the new header dirs to the makefile fixed the problem, but I&#39;m=
 a little confused as to how to proceed in patching. Since the configuratio=
n scripting and the makefiles seem to expect only a single include-dir of h=
eader files for both zfs and spl respectively, I&#39;m wondering what the b=
est approach to patching this behavior would be.<br><br>Thanks for your tim=
e and consideration,<br>Christian</div><br><div class=3D"gmail_quote"><div =
dir=3D"ltr" class=3D"gmail_attr">On Fri, Feb 19, 2021 at 12:13 PM Andreas D=
ilger &lt;<a href=3D"mailto:adilger@whamcloud.com">adilger@whamcloud.com</a=
>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px=
 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">



<div dir=3D"auto">
This is exactly the right place for such discussions.=C2=A0
<div><br>
</div>
<div>Once you have patches, please submit to Gerrit for review, testing, an=
d landing:</div>
<div><br>
</div>
<div><a href=3D"https://wiki.lustre.org/Using_Gerrit" target=3D"_blank">htt=
ps://wiki.lustre.org/Using_Gerrit</a><br>
<div dir=3D"ltr"><br>
</div>
<div dir=3D"ltr">Cheers, Andreas</div>
<div dir=3D"ltr"><br>
<blockquote type=3D"cite">On Feb 19, 2021, at 02:11, Christian Kuntz &lt;<a=
 href=3D"mailto:c.kuntz@opendrives.com" target=3D"_blank">c.kuntz@opendrive=
s.com</a>&gt; wrote:<br>
<br>
</blockquote>
</div>
<blockquote type=3D"cite">
<div dir=3D"ltr">=EF=BB=BF
<div dir=3D"ltr">Thanks for your time and the thoughtful response.<br>
<br>
Looking at this a bit more, it seems=C2=A0to be caused by the recent ZFS 2.=
0 changes for linux and freebsd support, namely=C2=A0the `include/os/linux`=
 paths that=C2=A0provide `&lt;sys/types.h&gt;` that ZFS is trying to use. A=
dding them into the includes for the osd-zfs directory
 has fixed the references being broken, and now I&#39;m contending some red=
efinitions and argument type mismatches. I&#39;ll try and sort this out, in=
 the meantime is there a better place for me to place messages about this? =
I know this mailing list isn&#39;t used very
 frequently and I&#39;d hate to flood it with such off-the-beaten-path stuf=
f.<br>
<br>
Best,<br>
Christian</div>
<br>
<div class=3D"gmail_quote">
<div dir=3D"ltr" class=3D"gmail_attr">On Thu, Feb 18, 2021 at 3:09 AM Andre=
as Dilger &lt;<a href=3D"mailto:adilger@whamcloud.com" target=3D"_blank">ad=
ilger@whamcloud.com</a>&gt; wrote:<br>
</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left:1px solid rgb(204,204,204);padding-left:1ex">
<div>On Feb 12, 2021, at 16:07, Christian Kuntz &lt;<a href=3D"mailto:c.kun=
tz@opendrives.com" target=3D"_blank">c.kuntz@opendrives.com</a>&gt; wrote:<=
br>
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
he kernel and zfs locally built and their packages
 made, and lustre&#39;s configure step successfully completes, but when it =
comes to compiling it appears that the osd-zfs portion has some broken incl=
ude links:<br>
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
</blockquote>
</div>
</div>
</blockquote>
</div>
</div>

</blockquote></div>

--000000000000852b4605bbbbc70d--

--===============7012750093139603677==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7012750093139603677==--
