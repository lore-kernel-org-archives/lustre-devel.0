Return-Path: <SRS0=2HMJ=MV=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_IMAGE_ONLY_20,HTML_MESSAGE,
	HTML_SHORT_LINK_IMG_3,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B68DBC4338F
	for <lustre-devel@archiver.kernel.org>; Thu, 29 Jul 2021 23:31:59 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2DCAF60F23
	for <lustre-devel@archiver.kernel.org>; Thu, 29 Jul 2021 23:31:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 2DCAF60F23
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=opendrives.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 61771352926;
	Thu, 29 Jul 2021 16:31:58 -0700 (PDT)
Received: from mail-ed1-f53.google.com (mail-ed1-f53.google.com
 [209.85.208.53])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BDE78352424
 for <lustre-devel@lists.lustre.org>; Thu, 29 Jul 2021 16:31:56 -0700 (PDT)
Received: by mail-ed1-f53.google.com with SMTP id x14so10394588edr.12
 for <lustre-devel@lists.lustre.org>; Thu, 29 Jul 2021 16:31:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=opendrives.com; s=google;
 h=mime-version:from:date:message-id:subject:to;
 bh=FhLlLPN4nM3TthGbiXr7k4r0tnCkpF3H574cB1EFwzA=;
 b=AlUFs2mlrd7PYSFyqOY9lFKd2FvABOzln34A56Iay0mNSjEP3Jt2ejtDmLhynLbDZ2
 wWRvsYsPVwsRonUJBA1sgroGPht8COtTqbLY16g8mQxCpNNhTGhq1JiHICszTz0Mzk3J
 5GstknBAxGzl80k2af6S6YOwYUTiPVxAC+bfkAWr5g7bTSvAeOu4ngsZt1LnZQcy4BzH
 AyIL8Ex5NO8iBR52ZJTUJ5T6Wy56snEjTZmqeHDKn+nv3bDXwWL+LHLQ5tDfPzqj3Oze
 6cTA5an8B+ACIvv0WylMxH44j4wLk/40l2cICMtbROwnJz6hX247v0oezBje+D3g1M01
 5BVA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
 bh=FhLlLPN4nM3TthGbiXr7k4r0tnCkpF3H574cB1EFwzA=;
 b=TD2qUNq3Mtys4fXmwAHMWsmJez7Al3P+yrFXMxm/V7sJTtLB/hWtQqKObtaQzqzoLU
 YUYaiqtC+xeC8YoQP4uGSAR+xie1hibU+5NhzYErRLEd1LbO+R9kPElOKqCxLzQSyrjn
 q8wHyczFXPjNubgFhKsraOewAyu/g21tPsRuZaKKdlWCpS2csVzXrrQMm6wtNiIGZ/Gz
 jsL42ZWSPX6k0W4WdFH9Q2PKhpAa80DYfPVxCKj7fUJCdnLElBfuhZd/25wBoWCvIGPg
 +MZg2pjUhAgCGp1MdjzpDlpobzoOD9RzwM0/ac/5gtNciZCDQEqOcO+p5Ww5GOvramuw
 vNjg==
X-Gm-Message-State: AOAM5326aXl1Z0mDqxTCfWxGPFc91yn9F6QtOhxITLuc2HLcnEQzPaPt
 p1c9XifqUyL6tbgUe9bLfLSOorgxSz3KAx7sdms/uQk/lnm87yklkzfmxTe57ymg9oqbdUYB2TG
 Zxz38XTqGR4s4I0aaBxv1/ZdJOWU46IO7S3na54HuMpk=
X-Google-Smtp-Source: ABdhPJwmUTsnL1PKCJsFRakAka8iwYfG75WEBsnG9QHTRUYAZeNbDo/gmMjsURwb8Wflq8HC3YLe7vGCQ+QsK6OK9mA=
X-Received: by 2002:a50:da0e:: with SMTP id z14mr8955075edj.73.1627601515258; 
 Thu, 29 Jul 2021 16:31:55 -0700 (PDT)
MIME-Version: 1.0
From: Christian Kuntz <c.kuntz@opendrives.com>
Date: Thu, 29 Jul 2021 16:31:44 -0700
Message-ID: <CANdLGj6GDFX08SqsseGDej7xHDLWvA=95gnUhNuh0jjkJxGnkw@mail.gmail.com>
To: Lustre-devel <lustre-devel@lists.lustre.org>
Subject: [lustre-devel] zfs module taints osd_zfs and causes modprobe to fail
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
Content-Type: multipart/mixed; boundary="===============1284482557828432073=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1284482557828432073==
Content-Type: multipart/alternative; boundary="000000000000274fe405c84b82e0"

--000000000000274fe405c84b82e0
Content-Type: text/plain; charset="UTF-8"

Hi all,

Resident crazy guy Christian here, I'm compiling lustre 2.14 on kernel
4.19.194 with ZFS 2.0.3 and running into a bit of a challenge thanks to this
kernel commit
<https://github.com/torvalds/linux/commit/262e6ae7081df304fc625cf368d5c2cbba2bb991>
.

In short, `modprobe lustre` succeeds but `modprobe osd_zfs` fails and
generates this output in dmesg:

[82645.937126] osd_zfs: module_layout: kernel tainted.
[82645.937526] osd_zfs: module uses symbols from proprietary module zfs,
inheriting taint.
[82645.938356] osd_zfs: Unknown symbol ktime_get_real_seconds (err -2)
[82645.938568] osd_zfs: Unknown symbol ktime_get_seconds (err -2)

From what I can gather, the license taint from zfs floats up to osd_zfs,
and since osd_zfs becomes tainted as a non-GPL module it can no longer
utilize the GPL-only symbols from ktime, causing the module insertion to
fail.

As far as I can tell, my options are to either patch the taint inheritance
out of the kernel, add new functions to osd_zfs that replace the
functionality of ktim_get_real_seconds and ktime_get_seconds (honestly,
that feels a bit intimidating), or remove the gpl only requirement from
osd_zfs. Has anyone else run into this and found working solutions yet?

Cheers,
Christian

-- 
 
<https://opendrives.ac-page.com/nabshow2021?utm_source=emailsig&utm_medium=email&utm_campaign=NAB2021>

--000000000000274fe405c84b82e0
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi all,<br><br>Resident crazy guy Christian here, I&#39;m =
compiling lustre 2.14 on kernel 4.19.194 with ZFS 2.0.3 and running into a =
bit of a challenge thanks to=C2=A0<a href=3D"https://github.com/torvalds/li=
nux/commit/262e6ae7081df304fc625cf368d5c2cbba2bb991">this kernel commit</a>=
.<br><br>In short, `modprobe lustre` succeeds but `modprobe osd_zfs` fails =
and generates this output in dmesg:<br><br>[82645.937126] osd_zfs: module_l=
ayout: kernel tainted.<br>[82645.937526] osd_zfs: module uses symbols from =
proprietary module zfs, inheriting taint.<br>[82645.938356] osd_zfs: Unknow=
n symbol ktime_get_real_seconds (err -2)<br>[82645.938568] osd_zfs: Unknown=
 symbol ktime_get_seconds (err -2)<br><br>From what I can gather, the licen=
se taint from zfs floats up to osd_zfs, and since osd_zfs becomes tainted a=
s a non-GPL module it can no longer utilize the GPL-only symbols from ktime=
, causing the module insertion to fail.=C2=A0<br><br>As far as I can tell, =
my options are to either patch the taint inheritance out of the kernel, add=
 new functions to osd_zfs that replace the functionality of ktim_get_real_s=
econds and ktime_get_seconds (honestly, that feels a bit intimidating), or =
remove the gpl only requirement from osd_zfs. Has anyone else run into this=
 and found working solutions yet?<br><br>Cheers,<br>Christian</div>

<br>
<a href=3D"https://opendrives.ac-page.com/nabshow2021?utm_source=3Demailsig=
&amp;utm_medium=3Demail&amp;utm_campaign=3DNAB2021" target=3D"_blank"><img =
src=3D"https://signature.opendrives.com/NAB2021%20Email%20Sig%20500px%20C.p=
ng" alt=3D"https://opendrives.ac-page.com/nabshow2021?utm_source=3Demailsig=
&amp;utm_medium=3Demail&amp;utm_campaign=3DNAB2021"></a><br>
--000000000000274fe405c84b82e0--

--===============1284482557828432073==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1284482557828432073==--
