Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3E93C4338F
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 01:59:51 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3868561051
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 01:59:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 3868561051
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=opendrives.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BE2E621CA0F;
	Sun, 22 Aug 2021 18:59:50 -0700 (PDT)
Received: from mail-ed1-f51.google.com (mail-ed1-f51.google.com
 [209.85.208.51])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A9C1E21C9BF
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 18:59:48 -0700 (PDT)
Received: by mail-ed1-f51.google.com with SMTP id s3so11522628edd.11
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 18:59:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=opendrives.com; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=2U+MBbOX33TDYrVDght5kF+RfiQm1jgH8pxmrrxq4vc=;
 b=VhbtE+VrhTORoPYQEikH1JviGWQvy9VJLfyateIRNDf1WKi2UL31nuYScXa8UN71Mk
 A614/DkqGmmqy0VPKYftPRfZj/uFK4KNtP9bwBRN2A1cbB5wHvJYNqpj0Bpn3t11bjZj
 qYvWiqOUIEJZ/gh8SsXUqq/6CUgtxt/3cibyJJZsGic77bpjqNjioP1vcMzrcNeGWo1F
 wN7UlEh7DLPCAsJ1A9kOv5SzpHsuC77A3gWU4mREZkYK6KsE8md9JEWriC/xeokwV1t/
 XVXtYMHY2MBNPGu+rCCsiy3X2L32gwZMEUDE9Fab18Jk9pSNHRIb4P0KT9zMVHhTMtgL
 AnEg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=2U+MBbOX33TDYrVDght5kF+RfiQm1jgH8pxmrrxq4vc=;
 b=TmU1wtnn0LeFF6IlFlRmtgDAD7QdV5s845OPHefcsn/ocjzFF1jzfgN82n7GgLe0k+
 C423rjaRab1s9T/sS0/AqZVnyl0u/OjimDifXvPUx8fTXI3qsHosOsoU8aHszAr0x7Yb
 Grw6ftWHqjSCx7y3Ie+CCywrIS//JQ7PjC9zIpogf0VhqL6B/5aglyzQ4tMZdZFYQw5O
 J1fCbEytsL/lGx9DU8NpP9tsUoz1E+TIry/1K6UudQBsgP6HnD2PkWFrQrrJpfbTJsWl
 Us86VjOAvysMMqwq++dGDfg2fMbG7tJQWKUrkz9wN2kp0/AznkhzkCVbf4gy7eyNdQA3
 2RXA==
X-Gm-Message-State: AOAM53005jABDh6JaoEx650+MSDkKjCBkc+EUwvj52+yWPq1cpceOpar
 /aE1ZPhWehjd9le/b4OO1/vPqmKFXyLAbSd4OgtiZQ==
X-Google-Smtp-Source: ABdhPJzo6C8tsr+kWrcWOuOQuFkjGiwt43Cvdu+RJS7Y5wiHe3+ttY6yf2Dw78YKYUsleoa36/KGV5LRZd66dMZS0SY=
X-Received: by 2002:aa7:ca4b:: with SMTP id j11mr8406513edt.342.1629683987471; 
 Sun, 22 Aug 2021 18:59:47 -0700 (PDT)
MIME-Version: 1.0
References: <CANdLGj7=6X1ixcyNOguUAzxTTnegD3h2zfgaEso+Fv5E7YejVA@mail.gmail.com>
 <477F0D07-A7E1-488A-8E06-FE6C2E748FE1@whamcloud.com>
 <CANdLGj7o4yJf3byyM4LaAm+ZfNkAswTjU+HSUeK2yK+Yw4cvVg@mail.gmail.com>
 <E4233477-F17B-4DD4-BC89-4DEAAD4590E5@whamcloud.com>
 <CANdLGj4nJPfc6WA1ZrOeGhfjX+60QX_v_2xC7XDbHuSMXN3KCA@mail.gmail.com>
 <BY5PR09MB5427C96986B487A6E8BCDF86F8819@BY5PR09MB5427.namprd09.prod.outlook.com>
 <CANdLGj6VBe2Po8NK8Ypcm-0P8ewHzbUqLOZo4bG6Fa58qAG8gQ@mail.gmail.com>
In-Reply-To: <CANdLGj6VBe2Po8NK8Ypcm-0P8ewHzbUqLOZo4bG6Fa58qAG8gQ@mail.gmail.com>
From: Christian Kuntz <c.kuntz@opendrives.com>
Date: Sun, 22 Aug 2021 18:59:36 -0700
Message-ID: <CANdLGj7A9vhwjiFv0tV0Fg-vtXSCTsiLF38oOp6Mtyi+LDoaHQ@mail.gmail.com>
To: "Faaland, Olaf P." <faaland1@llnl.gov>
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
Content-Type: multipart/mixed; boundary="===============6394252563390128664=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6394252563390128664==
Content-Type: multipart/alternative; boundary="0000000000002b71d105ca305ff8"

--0000000000002b71d105ca305ff8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi all,

I thought that perhaps I'd just run into a weird edge-case being on Debian
and a little bleeding edge after seeing some other folks on the mailing
list compile without issue, but it looks like after some experimental work
on centos trying to get Lustre 2.14 and ZFS 2.0 compiled on the same box
that similar weirdness exists in the configuration steps where the autoconf
logic has a hard time finding function definitions thanks to the new
BSD+Linux source tree of ZFS. I'm going to revisit this and see if I can't
generate some patches that make the process a bit easier.

For my own reference, are there any more recent sources-of-truth for
compiling lustre from source than the one on the wiki?
<https://wiki.lustre.org/Installing_the_Lustre_Software> There's every
likelihood that I'm just missing some steps in the compilation process.

Cheers,
Christian

On Mon, Feb 22, 2021 at 7:41 PM Christian Kuntz <c.kuntz@opendrives.com>
wrote:

> Hi Olaf,
>
> Sure! For reference this is how I build zfs:
>
> ./autogen.sh
> fakeroot dpkg-buildpackage -us -uc -b -j$cpus
> # Build the kernel modules, not just dkms
> KVERS=3D$KERNEL_ABI KSRC=3D$WITHLINUX_HDR KOBJ=3D$WITHLINUXOBJ fakeroot
> debian/rules override_dh_binary-modules
>
> Then, when I build lustre, I do like:
> sh autogen.sh
> ./configure --with-linux=3D$WITHLINUX_HDR --with-linux-obj=3D$WITHLINUXOB=
J
> --with-zfs=3D$ZFS_SRC --enable-server --enable-modules --disable-ldiskfs
> make  debs
>
> My zfs source is given as the root zfs source directory, not the contents
> of explicit package dirs in ZFS_SRC/debian/ which is technically where al=
l
> the build artifacts live (for instance, the development headers that woul=
d
> end up on the machine would be in debian/libzfslinux-dev/usr/include) aft=
er
> a package build. After fiddling around with autoconf a bit (and learning
> it's just shell!), I landed on changing this bit of the autoconf:
> config/lustre-build-zfs.m4
>
> AC_DEFUN([LB_ZFS_USER], [
> dnl #
> dnl # Detect user space zfs development headers.
> dnl #
> AC_MSG_CHECKING([zfs devel headers])
>     AS_IF([test -z "${zfsinc}"], [
>         AS_IF([test -d "${zfssrc}/include/os/linux"], [
>               zfsinc=3D"-I${zfssrc}/include/os/linux/kernel
> -I${zfssrc}/include/os/linux/spl -I${zfssrc}/include/os/linux/zfs
> -I${zfssrc}/include"
>               zfslib=3D"-L$zfssrc/lib/libzfs/.libs/
> -L$zfssrc/lib/libnvpair/.libs"
>            ], [test -e "${zfssrc}/include/libzfs.h" && test -e
> "${zfssrc}/lib/libspl/include"], [
>               zfsinc=3D"-I $zfssrc/lib/libspl/include -I $zfssrc/include"
>               zfslib=3D"-L$zfssrc/lib/libzfs/.libs/
> -L$zfssrc/lib/libnvpair/.libs"
>           ], [test -d /usr/include/libzfs && test -d /usr/include/libspl]=
,
> [
>                zfsinc=3D"-I/usr/include/libspl -I /usr/include/libzfs"
>                zfslib=3D""
>          ], [
>       zfsinc=3D"[Not Found]"
>       zfslib=3D""
>      enable_zfs=3Dno
>    ])
> ])
> AC_MSG_RESULT([$zfsinc])
>
> I added a check around the new include/os style of the zfs header
> directories, which seems to be working OK, every config test is behaving =
as
> expected on my machine except for the multihost support one, which I'm
> chasing down a bit (sys/spa.h requires sys/sysmacros.h which requires...
> and so on). I also found that I had to modify the contents of
> config/lustre-build-linux.m4 to reflect the include dir change:
>
> AC_DEFUN([LB_LINUX_COMPILE_IFELSE],
> [m4_ifvaln([$1], [AC_LANG_CONFTEST([AC_LANG_SOURCE([$1])])])dnl
> rm -f build/conftest.o build/conftest.mod.c build/conftest.ko
> SUBARCH=3D$(echo $target_cpu | sed -e 's/powerpc.*/powerpc/' -e
> 's/ppc.*/powerpc/' -e 's/x86_64/x86/' -e 's/i.86/x86/' -e 's/k1om/x86/' -=
e
> 's/aarch64.*/arm64/' -e 's/armv7.*/arm/')
> AS_IF([AC_TRY_COMMAND(cp conftest.c build && make -d [$2] LDFLAGS=3D
> ${LD:+LD=3D"$LD"} CC=3D"$CC" -f $PWD/build/Makefile
> LUSTRE_LINUX_CONFIG=3D$LINUX_CONFIG LINUXINCLUDE=3D"$EXTRA_CHECK_INCLUDE
> -I$LINUX/arch/$SUBARCH/include -Iinclude -Iarch/$SUBARCH/include/generate=
d
> -I$LINUX/include -Iinclude2 -I$LINUX/include/uapi -Iinclude/generated
> -I$LINUX/arch/$SUBARCH/include/uapi -Iarch/$SUBARCH/include/generated/uap=
i
> -I$LINUX/include/uapi -Iinclude/generated/uapi ${SPL_OBJ:+-include
> $SPL_OBJ/spl_config.h} ${ZFS_OBJ:+-include $ZFS_OBJ/zfs_config.h}
> ${SPL:+-I$ZFS/lib/libspl/include/ } ${ZFS:+-I$ZFS/include/os/linux/
> -I$ZFS/include/os/linux/kernel -I$ZFS/include/os/linux/spl
> -I$ZFS/include/os/linux/zfs -I$ZFS/include } -include $CONFIG_INCLUDE"
> KBUILD_EXTRA_SYMBOLS=3D"${ZFS_OBJ:+$ZFS_OBJ/Module.symvers}
> $KBUILD_EXTRA_SYMBOLS" -o tmp_include_depends -o scripts -o
> include/config/MARKER -C $LINUX_OBJ
> EXTRA_CFLAGS=3D"-Werror-implicit-function-declaration $EXTRA_KCFLAGS"
> $MODULE_TARGET=3D$PWD/build) >/dev/null && AC_TRY_COMMAND([$3])],
>
> I *think* I'll need to adjust the SPL variable in there, but not sure
> thus far.
>
> With the above settings I've gotten everything to succesfully compile and
> package up aside from a small modification I had to make
> to lustre/utils/libmount_utils_zfs.c to prevent a name collision with
> spa_get_hostid. I believe this occurs because the configuration doesn't s=
et
> HAVE_ZFS_MULTIHOST appropriately.
>
>
> As you can see, I worked on it a little on the weekend :)
>
> Cheers,
> Christian
>
> On Mon, Feb 22, 2021 at 11:58 AM Faaland, Olaf P. <faaland1@llnl.gov>
> wrote:
>
>> Hi Christian,
>>
>> Can you explain in more detail what you mean by "building ... from
>> source-dirs after a package build"?  And can you identify the lines in
>> config/lustre-build-zfs.m4 that you're referring to?
>>
>> thank you,
>> -Olaf
>>
>> ________________________________________
>> From: Christian Kuntz <c.kuntz@opendrives.com>
>> Sent: Friday, February 19, 2021 7:00 PM
>> To: Andreas Dilger
>> Cc: Lustre-devel; Behlendorf, Brian D.; Faaland, Olaf P.
>> Subject: Re: [lustre-devel] Testing 2.14 on Debian + ZFS
>>
>> Thanks for the confirmation!
>>
>> After going in a few circles, I think I've got it figured out and would
>> appreciate some pointers on how to proceed:
>>
>> To preface, the way I'm building is from source-dirs after a package
>> build (which is admittedly kind of janky as I write it out now). It woul=
d
>> appear that the configure scripting will look in "zfs/include", and thus
>> miss the new "zfs/include/os/..." directories that hold some important
>> header files, causing configuration variables to miss-set in config.h th=
us
>> creating the compile-time problems of type mismatches and redefinitions =
I
>> was seeing.
>>
>>  I was able to confirm manually setting some of the configuration defs
>> and adding the new header dirs to the makefile fixed the problem, but I'=
m a
>> little confused as to how to proceed in patching. Since the configuratio=
n
>> scripting and the makefiles seem to expect only a single include-dir of
>> header files for both zfs and spl respectively, I'm wondering what the b=
est
>> approach to patching this behavior would be.
>>
>> Thanks for your time and consideration,
>> Christian
>>
>> On Fri, Feb 19, 2021 at 12:13 PM Andreas Dilger <adilger@whamcloud.com
>> <mailto:adilger@whamcloud.com>> wrote:
>> This is exactly the right place for such discussions.
>>
>> Once you have patches, please submit to Gerrit for review, testing, and
>> landing:
>>
>> https://wiki.lustre.org/Using_Gerrit<
>> https://urldefense.us/v2/url?u=3Dhttps-3A__wiki.lustre.org_Using-5FGerri=
t&d=3DDwMFaQ&c=3DpKoAVQro6qDbLoK0T8588B4mZJhJhC4e6QXJy0XnJec&r=3D2dxT0LLEUx=
0IbhFF8HRJVCTO_ihbEwKLn9gF7Kc8aG0&m=3DSU5sac04cekvaRvbUcheoU02W7EUu-F4sVkkr=
WHUnoE&s=3DgTcuGMUi5PycREbMB4La1s0dVNM8a5STb9pDVXZt-Lw&e=3D
>> >
>>
>> Cheers, Andreas
>>
>> On Feb 19, 2021, at 02:11, Christian Kuntz <c.kuntz@opendrives.com
>> <mailto:c.kuntz@opendrives.com>> wrote:
>>
>> =EF=BB=BF
>> Thanks for your time and the thoughtful response.
>>
>> Looking at this a bit more, it seems to be caused by the recent ZFS 2.0
>> changes for linux and freebsd support, namely the `include/os/linux` pat=
hs
>> that provide `<sys/types.h>` that ZFS is trying to use. Adding them into
>> the includes for the osd-zfs directory has fixed the references being
>> broken, and now I'm contending some redefinitions and argument type
>> mismatches. I'll try and sort this out, in the meantime is there a bette=
r
>> place for me to place messages about this? I know this mailing list isn'=
t
>> used very frequently and I'd hate to flood it with such off-the-beaten-p=
ath
>> stuff.
>>
>> Best,
>> Christian
>>
>> On Thu, Feb 18, 2021 at 3:09 AM Andreas Dilger <adilger@whamcloud.com
>> <mailto:adilger@whamcloud.com>> wrote:
>> On Feb 12, 2021, at 16:07, Christian Kuntz <c.kuntz@opendrives.com
>> <mailto:c.kuntz@opendrives.com>> wrote:
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

--0000000000002b71d105ca305ff8
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi all,<br><br>I thought that perhaps I&#39;d just run int=
o a weird edge-case being on Debian and a little bleeding edge after seeing=
 some other folks on the mailing list compile without issue, but it looks l=
ike after some experimental work on centos trying to get Lustre 2.14 and ZF=
S 2.0 compiled on the same box that similar weirdness exists in the configu=
ration steps where the autoconf logic has a hard time finding function defi=
nitions thanks to the new BSD+Linux source tree of ZFS. I&#39;m going to re=
visit this and see if I can&#39;t generate some patches that make the proce=
ss a bit easier.<br><br>For my own reference, are there any more recent sou=
rces-of-truth for compiling lustre from source than=C2=A0<a href=3D"https:/=
/wiki.lustre.org/Installing_the_Lustre_Software">the one on the wiki?</a>=
=C2=A0There&#39;s every likelihood that I&#39;m just missing some steps in =
the compilation process.<br><br>Cheers,<br>Christian</div><br><div class=3D=
"gmail_quote"><div dir=3D"ltr" class=3D"gmail_attr">On Mon, Feb 22, 2021 at=
 7:41 PM Christian Kuntz &lt;<a href=3D"mailto:c.kuntz@opendrives.com">c.ku=
ntz@opendrives.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote=
" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);=
padding-left:1ex"><div dir=3D"ltr"><div>Hi Olaf,<br><br>Sure! For reference=
 this is how I build zfs:<br><br>./autogen.sh<br>fakeroot dpkg-buildpackage=
 -us -uc -b -j$cpus<br># Build the kernel modules, not just dkms<br>KVERS=
=3D$KERNEL_ABI KSRC=3D$WITHLINUX_HDR KOBJ=3D$WITHLINUXOBJ fakeroot debian/r=
ules override_dh_binary-modules<br><br>Then, when I build lustre, I do like=
:<br>sh autogen.sh<br>./configure --with-linux=3D$WITHLINUX_HDR --with-linu=
x-obj=3D$WITHLINUXOBJ --with-zfs=3D$ZFS_SRC --enable-server --enable-module=
s --disable-ldiskfs<br>make=C2=A0 debs<br><br>My zfs source is given as the=
 root zfs source directory, not the contents of explicit package dirs in ZF=
S_SRC/debian/ which is technically where all the build artifacts live (for =
instance, the development headers that would end up on the machine would be=
 in debian/libzfslinux-dev/usr/include) after a package build. After fiddli=
ng around with autoconf a bit (and learning it&#39;s just shell!), I landed=
 on changing this bit of the autoconf:<div>config/lustre-build-zfs.m4<br><b=
r>AC_DEFUN([LB_ZFS_USER], [<br>	dnl #<br>	dnl # Detect user space zfs devel=
opment headers.<br>	dnl #<br>	AC_MSG_CHECKING([zfs devel headers])<br>=C2=
=A0 =C2=A0 AS_IF([test -z &quot;${zfsinc}&quot;], [<br>=C2=A0 =C2=A0 =C2=A0=
 =C2=A0 AS_IF([test -d &quot;${zfssrc}/include/os/linux&quot;], [<br>=C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zfsinc=3D&quot;-I${zfssrc}/inclu=
de/os/linux/kernel -I${zfssrc}/include/os/linux/spl -I${zfssrc}/include/os/=
linux/zfs -I${zfssrc}/include&quot;<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 zfslib=3D&quot;-L$zfssrc/lib/libzfs/.libs/ -L$zfssrc/lib/libn=
vpair/.libs&quot;<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0], [test -e &=
quot;${zfssrc}/include/libzfs.h&quot; &amp;&amp; test -e &quot;${zfssrc}/li=
b/libspl/include&quot;], [<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 zfsinc=3D&quot;-I $zfssrc/lib/libspl/include -I $zfssrc/include&quot;<b=
r>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zfslib=3D&quot;-L$zfssrc=
/lib/libzfs/.libs/ -L$zfssrc/lib/libnvpair/.libs&quot;<br>=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 ], [test -d /usr/include/libzfs &amp;&amp; test -d /usr/i=
nclude/libspl], [<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0zfsinc=3D&quot;-I/usr/include/libspl -I /usr/include/libzfs&quot;<br>=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zfslib=3D&quot;&quot;<b=
r>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0], [<br>=C2=A0 =C2=A0 =C2=A0 zfsinc=3D&=
quot;[Not Found]&quot;<br>=C2=A0 =C2=A0 =C2=A0 zfslib=3D&quot;&quot;<br>=C2=
=A0 =C2=A0 =C2=A0enable_zfs=3Dno<br>=C2=A0 =C2=A0])<br>	])<br>	AC_MSG_RESUL=
T([$zfsinc])<br><br>I added a check around the new include/os style of the =
zfs header directories, which seems to be working OK, every config test is =
behaving as expected on my machine except for the multihost support one, wh=
ich I&#39;m chasing down a bit (sys/spa.h requires sys/sysmacros.h which re=
quires... and so on). I also found that I had to modify the contents of con=
fig/lustre-build-linux.m4 to reflect the include dir change:<br><br>AC_DEFU=
N([LB_LINUX_COMPILE_IFELSE],<br>[m4_ifvaln([$1], [AC_LANG_CONFTEST([AC_LANG=
_SOURCE([$1])])])dnl<br>rm -f build/conftest.o build/conftest.mod.c build/c=
onftest.ko<br>SUBARCH=3D$(echo $target_cpu | sed -e &#39;s/powerpc.*/powerp=
c/&#39; -e &#39;s/ppc.*/powerpc/&#39; -e &#39;s/x86_64/x86/&#39; -e &#39;s/=
i.86/x86/&#39; -e &#39;s/k1om/x86/&#39; -e &#39;s/aarch64.*/arm64/&#39; -e =
&#39;s/armv7.*/arm/&#39;)<br>AS_IF([AC_TRY_COMMAND(cp conftest.c build &amp=
;&amp; make -d [$2] LDFLAGS=3D ${LD:+LD=3D&quot;$LD&quot;} CC=3D&quot;$CC&q=
uot; -f $PWD/build/Makefile LUSTRE_LINUX_CONFIG=3D$LINUX_CONFIG LINUXINCLUD=
E=3D&quot;$EXTRA_CHECK_INCLUDE -I$LINUX/arch/$SUBARCH/include -Iinclude -Ia=
rch/$SUBARCH/include/generated -I$LINUX/include -Iinclude2 -I$LINUX/include=
/uapi -Iinclude/generated -I$LINUX/arch/$SUBARCH/include/uapi -Iarch/$SUBAR=
CH/include/generated/uapi -I$LINUX/include/uapi -Iinclude/generated/uapi ${=
SPL_OBJ:+-include $SPL_OBJ/spl_config.h} ${ZFS_OBJ:+-include $ZFS_OBJ/zfs_c=
onfig.h} ${SPL:+-I$ZFS/lib/libspl/include/ } ${ZFS:+-I$ZFS/include/os/linux=
/ -I$ZFS/include/os/linux/kernel -I$ZFS/include/os/linux/spl -I$ZFS/include=
/os/linux/zfs -I$ZFS/include } -include $CONFIG_INCLUDE&quot; KBUILD_EXTRA_=
SYMBOLS=3D&quot;${ZFS_OBJ:+$ZFS_OBJ/Module.symvers} $KBUILD_EXTRA_SYMBOLS&q=
uot; -o tmp_include_depends -o scripts -o include/config/MARKER -C $LINUX_O=
BJ EXTRA_CFLAGS=3D&quot;-Werror-implicit-function-declaration $EXTRA_KCFLAG=
S&quot; $MODULE_TARGET=3D$PWD/build) &gt;/dev/null &amp;&amp; AC_TRY_COMMAN=
D([$3])],=C2=A0<br><br>I <i>think</i>=C2=A0I&#39;ll need to adjust the SPL =
variable in there, but not sure thus far.=C2=A0<br><br>With the above setti=
ngs I&#39;ve gotten everything to succesfully compile and package up aside =
from a small modification I had to make to=C2=A0lustre/utils/libmount_utils=
_zfs.c to prevent a name collision with spa_get_hostid. I believe this occu=
rs because the configuration doesn&#39;t set HAVE_ZFS_MULTIHOST appropriate=
ly.<br><br><br>As you can see, I worked on it a little on the weekend :)<br=
><br>Cheers,<br>Christian<br></div></div></div><br><div class=3D"gmail_quot=
e"><div dir=3D"ltr" class=3D"gmail_attr">On Mon, Feb 22, 2021 at 11:58 AM F=
aaland, Olaf P. &lt;<a href=3D"mailto:faaland1@llnl.gov" target=3D"_blank">=
faaland1@llnl.gov</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote"=
 style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);p=
adding-left:1ex">Hi Christian,<br>
<br>
Can you explain in more detail what you mean by &quot;building ... from sou=
rce-dirs after a package build&quot;?=C2=A0 And can you identify the lines =
in config/lustre-build-zfs.m4 that you&#39;re referring to?<br>
<br>
thank you,<br>
-Olaf<br>
<br>
________________________________________<br>
From: Christian Kuntz &lt;<a href=3D"mailto:c.kuntz@opendrives.com" target=
=3D"_blank">c.kuntz@opendrives.com</a>&gt;<br>
Sent: Friday, February 19, 2021 7:00 PM<br>
To: Andreas Dilger<br>
Cc: Lustre-devel; Behlendorf, Brian D.; Faaland, Olaf P.<br>
Subject: Re: [lustre-devel] Testing 2.14 on Debian + ZFS<br>
<br>
Thanks for the confirmation!<br>
<br>
After going in a few circles, I think I&#39;ve got it figured out and would=
 appreciate some pointers on how to proceed:<br>
<br>
To preface, the way I&#39;m building is from source-dirs after a package bu=
ild (which is admittedly kind of janky as I write it out now). It would app=
ear that the configure scripting will look in &quot;zfs/include&quot;, and =
thus miss the new &quot;zfs/include/os/...&quot; directories that hold some=
 important header files, causing configuration variables to miss-set in con=
fig.h thus creating the compile-time problems of type mismatches and redefi=
nitions I was seeing.<br>
<br>
=C2=A0I was able to confirm manually setting some of the configuration defs=
 and adding the new header dirs to the makefile fixed the problem, but I&#3=
9;m a little confused as to how to proceed in patching. Since the configura=
tion scripting and the makefiles seem to expect only a single include-dir o=
f header files for both zfs and spl respectively, I&#39;m wondering what th=
e best approach to patching this behavior would be.<br>
<br>
Thanks for your time and consideration,<br>
Christian<br>
<br>
On Fri, Feb 19, 2021 at 12:13 PM Andreas Dilger &lt;<a href=3D"mailto:adilg=
er@whamcloud.com" target=3D"_blank">adilger@whamcloud.com</a>&lt;mailto:<a =
href=3D"mailto:adilger@whamcloud.com" target=3D"_blank">adilger@whamcloud.c=
om</a>&gt;&gt; wrote:<br>
This is exactly the right place for such discussions.<br>
<br>
Once you have patches, please submit to Gerrit for review, testing, and lan=
ding:<br>
<br>
<a href=3D"https://wiki.lustre.org/Using_Gerrit" rel=3D"noreferrer" target=
=3D"_blank">https://wiki.lustre.org/Using_Gerrit</a>&lt;<a href=3D"https://=
urldefense.us/v2/url?u=3Dhttps-3A__wiki.lustre.org_Using-5FGerrit&amp;d=3DD=
wMFaQ&amp;c=3DpKoAVQro6qDbLoK0T8588B4mZJhJhC4e6QXJy0XnJec&amp;r=3D2dxT0LLEU=
x0IbhFF8HRJVCTO_ihbEwKLn9gF7Kc8aG0&amp;m=3DSU5sac04cekvaRvbUcheoU02W7EUu-F4=
sVkkrWHUnoE&amp;s=3DgTcuGMUi5PycREbMB4La1s0dVNM8a5STb9pDVXZt-Lw&amp;e=3D" r=
el=3D"noreferrer" target=3D"_blank">https://urldefense.us/v2/url?u=3Dhttps-=
3A__wiki.lustre.org_Using-5FGerrit&amp;d=3DDwMFaQ&amp;c=3DpKoAVQro6qDbLoK0T=
8588B4mZJhJhC4e6QXJy0XnJec&amp;r=3D2dxT0LLEUx0IbhFF8HRJVCTO_ihbEwKLn9gF7Kc8=
aG0&amp;m=3DSU5sac04cekvaRvbUcheoU02W7EUu-F4sVkkrWHUnoE&amp;s=3DgTcuGMUi5Py=
cREbMB4La1s0dVNM8a5STb9pDVXZt-Lw&amp;e=3D</a>&gt;<br>
<br>
Cheers, Andreas<br>
<br>
On Feb 19, 2021, at 02:11, Christian Kuntz &lt;<a href=3D"mailto:c.kuntz@op=
endrives.com" target=3D"_blank">c.kuntz@opendrives.com</a>&lt;mailto:<a hre=
f=3D"mailto:c.kuntz@opendrives.com" target=3D"_blank">c.kuntz@opendrives.co=
m</a>&gt;&gt; wrote:<br>
<br>
=EF=BB=BF<br>
Thanks for your time and the thoughtful response.<br>
<br>
Looking at this a bit more, it seems to be caused by the recent ZFS 2.0 cha=
nges for linux and freebsd support, namely the `include/os/linux` paths tha=
t provide `&lt;sys/types.h&gt;` that ZFS is trying to use. Adding them into=
 the includes for the osd-zfs directory has fixed the references being brok=
en, and now I&#39;m contending some redefinitions and argument type mismatc=
hes. I&#39;ll try and sort this out, in the meantime is there a better plac=
e for me to place messages about this? I know this mailing list isn&#39;t u=
sed very frequently and I&#39;d hate to flood it with such off-the-beaten-p=
ath stuff.<br>
<br>
Best,<br>
Christian<br>
<br>
On Thu, Feb 18, 2021 at 3:09 AM Andreas Dilger &lt;<a href=3D"mailto:adilge=
r@whamcloud.com" target=3D"_blank">adilger@whamcloud.com</a>&lt;mailto:<a h=
ref=3D"mailto:adilger@whamcloud.com" target=3D"_blank">adilger@whamcloud.co=
m</a>&gt;&gt; wrote:<br>
On Feb 12, 2021, at 16:07, Christian Kuntz &lt;<a href=3D"mailto:c.kuntz@op=
endrives.com" target=3D"_blank">c.kuntz@opendrives.com</a>&lt;mailto:<a hre=
f=3D"mailto:c.kuntz@opendrives.com" target=3D"_blank">c.kuntz@opendrives.co=
m</a>&gt;&gt; wrote:<br>
<br>
Hello,<br>
<br>
I hope I&#39;m communicating in the right place here, I&#39;m currently wor=
king to compile Lustre 2.14.0-RC2 on Debian 10.7 with ZFS 2.0.2 for OSDs. I=
f there&#39;s anything I can do to help with the testing effort or help Lus=
tre&#39;s Debian support be more robust, please let me know! I hope I&#39;m=
 not too late in the release cycle to contribute.<br>
<br>
Thanks for the offer of testing.=C2=A0 Unfortunately we are very late in th=
e 2.14.0 release cycle (we are hoping to make the final release in the next=
 week or so, barring any critical defects).=C2=A0 However, even if any chan=
ges miss the final 2.14.0 release, having patches available to fix any issu=
es you run into will make it easier for the next person to build on Debian.=
<br>
<br>
Ideally, any required fixes for Debian building should go into the Lustre t=
ree directly rather than into a separate &quot;downstream&quot; package, so=
 that &quot;make debs&quot; works out-of-the-box.=C2=A0 We do build Ubuntu =
18.04 and 20.04 clients regularly, and ZFS 2.0 servers on RHEL7/8, but I do=
n&#39;t know if anyone is building the server code on Debian/Ubuntu on a re=
gular basis.<br>
<br>
On the topic of compiling, I&#39;m currently working to get debian packages=
 made and running into a compilation issue that didn&#39;t seem to present =
on my previous endeavors with 2.13 and 0.7. I&#39;ve got the kernel and zfs=
 locally built and their packages made, and lustre&#39;s configure step suc=
cessfully completes, but when it comes to compiling it appears that the osd=
-zfs portion has some broken include links:<br>
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
s in `SRC/include/linux/`. Predictably, I found this out the hard way by ad=
ding `-I/usr/include` to the Makefile for the zfs osds and getting battered=
 with errors and warnings about duplicate definitions.<br>
<br>
It may be that you are looking at this from the wrong angle.=C2=A0 Rather t=
han trying to include more userspace headers, it might be worthwhile to see=
 why &lt;sys/arc.h&gt; is being included by osd_internal.h and maybe there =
is a more appropriate header that could be used in the kernel?=C2=A0 Failin=
g that, it isn&#39;t clear wh zfs_context.h is including the &lt;sys/type.h=
&gt; header from userspace when building with __KERNEL__ set?=C2=A0 Kernel =
code should be using &lt;linux/types.h&gt;.<br>
<br>
Cheers, Andreas<br>
--<br>
Andreas Dilger<br>
Principal Lustre Architect<br>
Whamcloud<br>
<br>
<br>
<br>
<br>
<br>
<br>
</blockquote></div>
</blockquote></div>

--0000000000002b71d105ca305ff8--

--===============6394252563390128664==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6394252563390128664==--
