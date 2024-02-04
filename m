Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7F369C4828F
	for <lustre-devel@archiver.kernel.org>; Sun,  4 Feb 2024 17:35:01 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4TSc8d0JZmz1y6q;
	Sun,  4 Feb 2024 09:34:57 -0800 (PST)
Received: from mail-yb1-f182.google.com (mail-yb1-f182.google.com
 [209.85.219.182])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4TSc8T2hyMz1wLM
 for <lustre-devel@lists.lustre.org>; Sun,  4 Feb 2024 09:34:49 -0800 (PST)
Received: by mail-yb1-f182.google.com with SMTP id
 3f1490d57ef6-dc6cbe1ac75so1717703276.1
 for <lustre-devel@lists.lustre.org>; Sun, 04 Feb 2024 09:34:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=charlotte.edu; s=google; t=1707068087; x=1707672887; darn=lists.lustre.org; 
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=MSIgjcHaAs9SKAzX+8tL/TX3x/MO3eUrcguo+RFko+I=;
 b=VtFWaOimPT8q1ClZHci7GmHRze/cazaZPUrkR/EzLD2zvNvRi4Eg2IeyOElLtRkryR
 k6IC9lUGY5DoOzVApVEXKr494l11RXJmhge06bMiWuO44YzAu6FZ+8cjpJDApII/FQ4g
 cW260rO1SHpzvj2jorOpDulnv3hcK/f5ELUmggttKpiGnFpXZAHEv+fSjCAenREan1dO
 AKBQxTYqyHKXCYr4nbssDn8AZGa08SItV6AoPIt7zG4KEeCNcaZW/kd95o7g271JRY4Q
 giW9/MGHoPNvVIfkFxbBN2Wo81OKJ61YXAatnbe7SvPrUiRI1itqvTjO1maD210qENeo
 avdg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1707068087; x=1707672887;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=MSIgjcHaAs9SKAzX+8tL/TX3x/MO3eUrcguo+RFko+I=;
 b=ppLTl0kHvWE5aPRoQ272yz3oWWIF7/EUc1ztryj87nx/iZ2NhuyKb3hCKO6LvJCPe6
 3/hLWv7ElRffYGhiajdmagzpV1lDc1OZoTtXPzg11tSkzUDDtZskaqnBkERU/mDNU9h+
 0R6QMuvPC6ujuFxEv3i8JlUGn6hRACkpuQnRxH1XogZbSR2f5SecrMAza7oxHhl8MFfY
 w9n9QA2K7hW9kbroTQyKLK9k9cInMysJbZz4KkY/5DErKIQwEuvpP1ZnpuJi5lNw4KI/
 KUoPe2m2w6EKdgLyFG3FqhhTSqE01eBdn94E30CatCfc5ua1hxsSoem4IPRvCAwiMc3j
 xAQQ==
X-Gm-Message-State: AOJu0YzG9Tg/7H7/jRDE8CTR4nAT9Q7raN2AhT6IdMF7aTfA8rLj4tRY
 taaypsq1zAyMapKAo9uDbjzpb2CBi9q6isf4Z5Pu4suWBqqR0JlOdh2cmFU89kPdPjhBSne7X7I
 qQCvir5Dy+GBwYjoiU7SYpX/uX5ODTsZsW9ijTQ==
X-Google-Smtp-Source: AGHT+IG0IgETAt8JZSxwTKNoX/vwA4wpORzGHgIEm3ko6uKP4MMieA34BHPuh47zvEhbB3ArmBlQiu8t58etgVBbaIE=
X-Received: by 2002:a05:6902:1345:b0:dc6:b1ab:b400 with SMTP id
 g5-20020a056902134500b00dc6b1abb400mr2668291ybu.18.1707068087340; Sun, 04 Feb
 2024 09:34:47 -0800 (PST)
MIME-Version: 1.0
References: <CACyzrcQosBre=vRYDN+VeB=o=9bB-mJGT=NrQBhJi_59Eqe7jw@mail.gmail.com>
 <LO2P265MB7274C2E5806D5C1E9655B5B4AB792@LO2P265MB7274.GBRP265.PROD.OUTLOOK.COM>
 <CACyzrcQEW_R2byC5AzvF7GwbD1z9o25MgnY2DS8yRd8ePrUz6g@mail.gmail.com>
 <1825EEAC-C476-44ED-8C88-C52A713E2273@ddn.com>
In-Reply-To: <1825EEAC-C476-44ED-8C88-C52A713E2273@ddn.com>
Date: Sun, 4 Feb 2024 12:34:36 -0500
Message-ID: <CACyzrcQ6iaPE0_BxPRZTBZLrZD_WvunmawVnvvQkwBVjm9mu3w@mail.gmail.com>
To: Andreas Dilger <adilger@whamcloud.com>
Subject: Re: [lustre-devel] [EXTERNAL] Re: Direct Modification of Lustre
 Metadata on Disk
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
From: Saisha Kamat via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Saisha Kamat <skamat1@charlotte.edu>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============8587270121869797978=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8587270121869797978==
Content-Type: multipart/alternative; boundary="000000000000f4303c061091c2c1"

--000000000000f4303c061091c2c1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Thank you for the clarification. I am proceeding to check the
CFS_FAIL_CHECK().

On Thu, Feb 1, 2024 at 3:59 PM Andreas Dilger <adilger@whamcloud.com> wrote=
:

> You cannot use debugfs to modify a mounted filesystem, no differently tha=
n
> you cannot replace the tire on your car while you are driving it on the
> highway...
>
> If you want to inject corruption into the filesystem while it is mounted
> (without corrupting the whole filesystem), you could use "CFS_FAIL_CHECK(=
)"
> to add fault injection points directly into the code, as is done by LFSCK
> to create specific corruptions and then repair them (see
> lustre/tests/sanity-lfsck.sh).
>
> Cheers, Andreas
>
>
> On Jan 31, 2024, at 18:41, Saisha Kamat via lustre-devel <
> lustre-devel@lists.lustre.org> wrote:
>
> Hello Artem,
>
> I apologize for the delay in my response. I also want to thank you for
> the suggestion.
> However, our objective is to inject modifications while Lustre is
> mounted, specifically targeting xattr faults such as LMA, Linkea, and
> Lovea. Could you please advise on which debugfs utility I can use for
> this purpose?
>
> We would greatly appreciate your guidance and clarity on these matters.
>
> Thanks and Regards,
> Saisha
>
> On Fri, Jan 26, 2024 at 5:24=E2=80=AFPM Blagodarenko Artem
> <artem.blagodarenko@gmail.com> wrote:
>
>
> [Caution: Email from External Sender. Do not click or open links or
> attachments unless you know this sender.]
>
>
> Hi Saisha,
>
>
>
> Thanks for your interest in Lustre FS and research efforts.
>
> Regarding your question. Had MDS been mounted when there was the xattre
> direct modification attempt?
>
> If yes, then xattr data consistency is not guaranteed.
>
> If it is possible, unmount MDS, make modifications, and mount it back.
>
>
>
> If MDS backend is LDISKFS, after unmounting MDS, you can mount it as
>
>
>
> Mount -t ldiskfs <path_to_dev> <mount_point> and modify any file.
>
> There is also debugfs utility which allows perform many useful
> modifications without mounting.
>
>
>
> Best regards,
>
> Artem Blagodarenko
>
>
>
> Best rega
>
> From: lustre-devel lustre-devel-bounces@lists.lustre.org on behalf of
> Saisha Kamat via lustre-devel lustre-devel@lists.lustre.org
> Date: Friday, 26 January 2024 at 19:58
> To: lustre-devel@lists.lustre.org lustre-devel@lists.lustre.org
> Subject: [lustre-devel] Direct Modification of Lustre Metadata on Disk
>
> Hello,
>
> I am a Ph.D. student at UNC-Charlotte, focusing on research related to
> the Lustre File System. As part of my project, I am investigating
> scenarios involving the direct modification of xattr metadata on the
> Lustre disk, without unmounting the Lustre servers.
>
> To achieve this, I have attempted to open the MDS (Metadata Server)
> disk partition as a file descriptor, locate the target file and its
> xattr, and write a faulty value. However, I have encountered an
> unexpected issue where my changes appear to be saved to memory and are
> not being synchronized with the disk.
> After completing the write operation, when I read the same xattr
> again, it reflects the corrupted value. Strangely, when using the
> "getfattr" command, the original, correct value is displayed. This
> discrepancy has raised doubts about whether Lustre permits direct
> modifications to its metadata on the disk.
> Furthermore, I observed that even after unmounting and remounting the
> Lustre file system, the xattr continues to display the corrupted value
> upon reading, whereas "getfattr" still returns the original, correct
> value.
>
> Please help me understand whether Lustre allows direct modifications
> to its metadata on the disk and if there are any inherent limitations
> or considerations that I should be aware of.
> Additionally, any recommendations or alternative approaches for
> simulating faulty conditions for testing purposes would be highly
> valuable to my research.
>
> Thanks and Regards,
> Saisha
> _______________________________________________
> lustre-devel mailing list
> lustre-devel@lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel@lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Principal Architect
> Whamcloud
>
>
>
>
>
>
>
>

--000000000000f4303c061091c2c1
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto">Thank you for the clarification. I am proceeding to check=
 the CFS_FAIL_CHECK().=C2=A0</div><div><br><div class=3D"gmail_quote"><div =
dir=3D"ltr" class=3D"gmail_attr">On Thu, Feb 1, 2024 at 3:59 PM Andreas Dil=
ger &lt;<a href=3D"mailto:adilger@whamcloud.com">adilger@whamcloud.com</a>&=
gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0=
px 0px 0.8ex;border-left-width:1px;border-left-style:solid;padding-left:1ex=
;border-left-color:rgb(204,204,204)">



<div style=3D"line-break:after-white-space">
You cannot use debugfs to modify a mounted filesystem, no differently than =
you cannot replace the tire on your car while you are driving it on the hig=
hway...
<div><br>
</div>
<div>If you want to inject corruption into the filesystem while it is mount=
ed (without corrupting the whole filesystem), you could use &quot;CFS_FAIL_=
CHECK()&quot; to add fault injection points directly into the code, as is d=
one by LFSCK to create specific corruptions
 and then repair them (see lustre/tests/sanity-lfsck.sh).</div>
<div><br>
</div>
<div>Cheers, Andreas</div></div><div style=3D"line-break:after-white-space"=
><div><br>
<div><br>
<blockquote type=3D"cite">
<div>On Jan 31, 2024, at 18:41, Saisha Kamat via lustre-devel &lt;<a href=
=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-devel@li=
sts.lustre.org</a>&gt; wrote:</div>
<br>
<div>
<div>Hello Artem,<br>
<br>
I apologize for the delay in my response. I also want to thank you for<br>
the suggestion.<br>
However, our objective is to inject modifications while Lustre is<br>
mounted, specifically targeting xattr faults such as LMA, Linkea, and<br>
Lovea. Could you please advise on which debugfs utility I can use for<br>
this purpose?<br>
<br>
We would greatly appreciate your guidance and clarity on these matters.<br>
<br>
Thanks and Regards,<br>
Saisha<br>
<br>
On Fri, Jan 26, 2024 at 5:24=E2=80=AFPM Blagodarenko Artem<br>
&lt;<a href=3D"mailto:artem.blagodarenko@gmail.com" target=3D"_blank">artem=
.blagodarenko@gmail.com</a>&gt; wrote:<br>
<blockquote type=3D"cite"><br>
[Caution: Email from External Sender. Do not click or open links or attachm=
ents unless you know this sender.]<br>
<br>
<br>
Hi Saisha,<br>
<br>
<br>
<br>
Thanks for your interest in Lustre FS and research efforts.<br>
<br>
Regarding your question. Had MDS been mounted when there was the xattre dir=
ect modification attempt?<br>
<br>
If yes, then xattr data consistency is not guaranteed.<br>
<br>
If it is possible, unmount MDS, make modifications, and mount it back.<br>
<br>
<br>
<br>
If MDS backend is LDISKFS, after unmounting MDS, you can mount it as<br>
<br>
<br>
<br>
Mount -t ldiskfs &lt;path_to_dev&gt; &lt;mount_point&gt; and modify any fil=
e.<br>
<br>
There is also debugfs utility which allows perform many useful modification=
s without mounting.<br>
<br>
<br>
<br>
Best regards,<br>
<br>
Artem Blagodarenko<br>
<br>
<br>
<br>
Best rega<br>
<br>
From: lustre-devel <a href=3D"mailto:lustre-devel-bounces@lists.lustre.org"=
 target=3D"_blank">
lustre-devel-bounces@lists.lustre.org</a> on behalf of Saisha Kamat via lus=
tre-devel
<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-d=
evel@lists.lustre.org</a><br>
Date: Friday, 26 January 2024 at 19:58<br>
To: <a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lust=
re-devel@lists.lustre.org</a>
<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-d=
evel@lists.lustre.org</a><br>
Subject: [lustre-devel] Direct Modification of Lustre Metadata on Disk<br>
<br>
Hello,<br>
<br>
I am a Ph.D. student at UNC-Charlotte, focusing on research related to<br>
the Lustre File System. As part of my project, I am investigating<br>
scenarios involving the direct modification of xattr metadata on the<br>
Lustre disk, without unmounting the Lustre servers.<br>
<br>
To achieve this, I have attempted to open the MDS (Metadata Server)<br>
disk partition as a file descriptor, locate the target file and its<br>
xattr, and write a faulty value. However, I have encountered an<br>
unexpected issue where my changes appear to be saved to memory and are<br>
not being synchronized with the disk.<br>
After completing the write operation, when I read the same xattr<br>
again, it reflects the corrupted value. Strangely, when using the<br>
&quot;getfattr&quot; command, the original, correct value is displayed. Thi=
s<br>
discrepancy has raised doubts about whether Lustre permits direct<br>
modifications to its metadata on the disk.<br>
Furthermore, I observed that even after unmounting and remounting the<br>
Lustre file system, the xattr continues to display the corrupted value<br>
upon reading, whereas &quot;getfattr&quot; still returns the original, corr=
ect<br>
value.<br>
<br>
Please help me understand whether Lustre allows direct modifications<br>
to its metadata on the disk and if there are any inherent limitations<br>
or considerations that I should be aware of.<br>
Additionally, any recommendations or alternative approaches for<br>
simulating faulty conditions for testing purposes would be highly<br>
valuable to my research.<br>
<br>
Thanks and Regards,<br>
Saisha<br>
_______________________________________________<br>
lustre-devel mailing list<br>
<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-d=
evel@lists.lustre.org</a><br>
<a href=3D"http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org" ta=
rget=3D"_blank">http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.or=
g</a><br>
<br>
<br>
</blockquote>
_______________________________________________<br>
lustre-devel mailing list<br>
<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-d=
evel@lists.lustre.org</a><br>
<a href=3D"http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org" ta=
rget=3D"_blank">http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.or=
g</a><br>
</div>
</div>
</blockquote>
</div>
<br>
<div>
<div dir=3D"auto" style=3D"letter-spacing:normal;text-align:start;text-inde=
nt:0px;text-transform:none;white-space:normal;word-spacing:0px;text-decorat=
ion:none;line-break:after-white-space;color:rgb(0,0,0)">
<div dir=3D"auto" style=3D"letter-spacing:normal;text-align:start;text-inde=
nt:0px;text-transform:none;white-space:normal;word-spacing:0px;text-decorat=
ion:none;line-break:after-white-space;color:rgb(0,0,0)">
<div dir=3D"auto" style=3D"letter-spacing:normal;text-align:start;text-inde=
nt:0px;text-transform:none;white-space:normal;word-spacing:0px;text-decorat=
ion:none;line-break:after-white-space;color:rgb(0,0,0)">
<div dir=3D"auto" style=3D"letter-spacing:normal;text-align:start;text-inde=
nt:0px;text-transform:none;white-space:normal;word-spacing:0px;text-decorat=
ion:none;line-break:after-white-space;color:rgb(0,0,0)">
<div dir=3D"auto" style=3D"letter-spacing:normal;text-align:start;text-inde=
nt:0px;text-transform:none;white-space:normal;word-spacing:0px;text-decorat=
ion:none;line-break:after-white-space;color:rgb(0,0,0)">
<div dir=3D"auto" style=3D"letter-spacing:normal;text-align:start;text-inde=
nt:0px;text-transform:none;white-space:normal;word-spacing:0px;text-decorat=
ion:none;line-break:after-white-space;color:rgb(0,0,0)">
<div>Cheers, Andreas</div>
<div>--</div>
<div>Andreas Dilger</div>
<div>Lustre=C2=A0Principal Architect</div>
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
</div>
<br>
<br>
</div>
<br>
</div>
</div>

</blockquote></div></div>

--000000000000f4303c061091c2c1--

--===============8587270121869797978==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8587270121869797978==--
