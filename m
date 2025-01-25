Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CF1F3C0218C
	for <lustre-devel@archiver.kernel.org>; Sat, 25 Jan 2025 09:10:38 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Yg86G5L9xz1xPC;
	Sat, 25 Jan 2025 01:10:30 -0800 (PST)
Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com
 [209.85.128.45])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Yg85k5mSmz1wcc
 for <lustre-devel@lists.lustre.org>; Sat, 25 Jan 2025 01:10:02 -0800 (PST)
Received: by mail-wm1-f45.google.com with SMTP id
 5b1f17b1804b1-43621d27adeso18976765e9.2
 for <lustre-devel@lists.lustre.org>; Sat, 25 Jan 2025 01:10:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1737796194; x=1738400994; darn=lists.lustre.org;
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:from:to:cc:subject:date:message-id:reply-to;
 bh=5Is2MTi/bT3t3jqbSigi4zCl6e7+zDELGWffXTsQv2A=;
 b=JkKXHauy6sWD9bpPT1om7fHM58W0HJJ19WB0NXwR4M+IbKtL+2phPJ9HtDwG3Vr1Ju
 MkiXax3wV86WPwOKv5wz5NbFASLVXBtSvxs0JybFgE5D7E9Vi4hzQzvBoDuygWQah7xK
 pKFM3M/kx7snDlqtO8c4DaeW84fLX2EFDlCXL4gkiVgKb5bAwUzrBrokmkVCiO38GY5B
 olBcN1A85Iv6Xu/l/iNSUCmBUOBjLElYDGAyrFxsWvkayF0KlrKiIgOpXcyJrRKdRj5F
 k2+h+a4yQRK+oAdlQTPKH50E+8OvB+DxAQPRAIg0IjhFdMpRKC6D9EtjG6eBU+lwNJg2
 2YvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1737796194; x=1738400994;
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=5Is2MTi/bT3t3jqbSigi4zCl6e7+zDELGWffXTsQv2A=;
 b=T7HsekstCX/CCvRUwgSONwi4sk2Wn2ByGfG2QnAZoGnrMuNVaz5TU3g7Gf62ZpxVMa
 Pp8odxYFemMuGfkiaulGzpkuuj+7DMCkum3p43/dHnKWo9DumtcDGT6dI8Ukql9IsqkX
 DZ/7tVf3FETBrxG+zAN2qTfBoSYq6V0XAFHfiPx9xvlpkR2ABNjCY5drZrSa11EZF5r5
 Bm6oGoRydozr63HAj/bsHO/gkTkMGSGNxzKZ3ewIjzEs01/LIKpRzuZ/kpNTw6ORAgoB
 5xv4QCkPkCMqAoBQa6TBCsh/WJCgH1FiECWFLM6eCbTY7eWIrt5Q//DWBf02ryQ284pP
 pisg==
X-Forwarded-Encrypted: i=1;
 AJvYcCUJ2a61vrvxQJpr9Bg4XlQm2AFq3W58LUKHEsemudemRW96V1sT3SteJ05FHKvfivo5m9DnlM9i8x+2TWI=@lists.lustre.org
X-Gm-Message-State: AOJu0YydfoyGFccfVae9k0IB3f8vHw2Z3NU4XpAyXTaM/Hxdq3I2KrSU
 FzWhglk66gQsMTbVwSejlsHU8Uf1Fqf8ZGpJO4jfYg8zOOS/DQEK
X-Gm-Gg: ASbGncsJr+zGV+5nBOnptVaA+NgauyrPk0IGlGMVZGQDGGFeWPUYj6nDxK5M5JIcfib
 qPosGcm2zZNKhZvwq+Gs+8y5LO5UqRC5v8eIwHpPLUwYuMCDBXlmG77gbZbd+NS5mjG7h96QiN8
 ySCl6a3uJ0glcV3u8EpLWf8GGKeFpMaRGmfPslpPkNla4hpOd2lkqz307yZUSFfB8BZ3pQuSlRO
 D7m0j5Rsi0gkMDwPX1cneobuNbYXKuFPEfCkYQGWAIrHbhVrwnprHOlnYB/UKEPj8V5/D+7TSma
 MYb7m0MtEylmbLeiESTVsmL8VWE=
X-Google-Smtp-Source: AGHT+IHuybsoSRi9e/breDjVLk6R9lkscXK86HaKxcTKB9OZQcAfMEU3iiL2FajZ7T0rF85IlxC+fQ==
X-Received: by 2002:a05:600c:3b02:b0:434:a7f1:6545 with SMTP id
 5b1f17b1804b1-43891441f27mr282680205e9.27.1737796193574; 
 Sat, 25 Jan 2025 01:09:53 -0800 (PST)
Received: from smtpclient.apple ([178.19.96.90])
 by smtp.gmail.com with ESMTPSA id
 5b1f17b1804b1-438bd4d2a82sm54296065e9.36.2025.01.25.01.09.52
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Sat, 25 Jan 2025 01:09:53 -0800 (PST)
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
Message-Id: <8BDA07C1-B0B5-4B3F-8F6D-3B900067C20A@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3776.700.51.11.1\))
Date: Sat, 25 Jan 2025 12:09:40 +0300
In-Reply-To: <173776106776.22054.6112299548499507604@noble.neil.brown.name>
To: NeilBrown <neilb@suse.de>
References: <339AF895-36E5-4FAF-B1E1-E69B2AB130EF@gmail.com>
 <173776106776.22054.6112299548499507604@noble.neil.brown.name>
X-Mailer: Apple Mail (2.3776.700.51.11.1)
Subject: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============7050565830297564441=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


--===============7050565830297564441==
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_69DA8A8C-0B44-4A58-9781-E91B70840763"


--Apple-Mail=_69DA8A8C-0B44-4A58-9781-E91B70840763
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8



> 25 =D1=8F=D0=BD=D0=B2. 2025=E2=80=AF=D0=B3., =D0=B2 02:24, NeilBrown =
<neilb@suse.de> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB(=D0=B0):
>=20
> On Thu, 23 Jan 2025, Alexey Lyahkov wrote:
>>=20
>>=20
>>=20
>>    Keeping different kernels up to date with new updates is something
>>    that
>>    the linux-stable team does all the time.  We do it at SUSE to.  It
>>    isn't
>>    that hard.
>>    You identify which patches *need* to be backported (ideally when
>>    the
>>    patch is created but that isn't always easy) and you use tools to
>>    help
>>    you backport them.
>>=20
>> So Lustre developers needs control all stable kernels and think which
>> patch needs back ported and send it to Distro owner=20
>> And for each LTS kernels on the kernel.org.. I think it increase a =
work
>> dramatically.
>=20
> No.  Lustre developers don't need to care about the stable kernels at
> all.  The stable team does that an explicitly say they don't want it =
to
> be a burden on maintainers.
Lustre maintainers don=E2=80=99t needs review code which affects a =
Lustre? It=E2=80=99s something new for me.
I understand a drivers changes should don=E2=80=99t reviewed by lustre =
team.
But arch/=E2=80=A6 fs/ .. mm/... kernel/ needs attention.
Lack to review will cause a very large quality degradation after short =
time.
As I point early - I think none of linux maintainers have a lustre =
cluster to test a patches before land.
They can do test own part and how to build at all. But how it affects a =
Lustre? A specially in performance area.
Small examples from past.
Small optimisation for page_accessed() and LRU lists fixes a problem =
with ext4 bitmap in memory and improve lustre performace for 10%. Due =
lack of read during write. (https://lwn.net/Articles/548830/)
Small change in jbd2 code - like replace list_add to list_add_tail - =
improve performance for 5-15% due journal handle starvation solved.
(https://www.spinics.net/lists/linux-ext4/msg84888.html)

So yes, Lustre developers can move  LTS kernels as unsupported area and =
if it=E2=80=99s broken just suggest to install an out-of-tree module =
with supported kernel. But did linux kernel needs a broken code in tree =
really?


> The lustre team *can* decide to have some involvement - adding Fixes
> tags, adding Cc: stable, even submitting backports which don't apply
> trivially.  But there is no requirement from anywhere.
>=20
> The lustre community only need to focus on one upstream.
And have a broken lustre client once it don=E2=80=99t tested. Or lustre =
client will hit a performance degradation.


Neil, Tim,=20

> Lustre develops who work for employers who sell support for older
> kernels might need to handle backports to those kernels and it is in
> everybody's interest not to make that unduly different e.g.  by
> separating bug fixes from features etc.
>=20
Lustre primary area is =E2=80=98older=E2=80=99 kernels. As I point early =
half of customers uses a RHEL7, second 30% is RHEL8.
And just 2% uses a modern kernels.


> The lustre community may well choose to host and share those =
backports,
> and maybe even include them in testing.  But I suspect that would be
> driven by vendors who sell support.  It certainly wouldn't be imposed =
by
> the upstream community.
>=20
> Exactly how we work with distros like Redhat, SUSE, Ubuntu would =
depend
> on what can be negotiated with them.
> Some might be willing to accept backports and release them in
> maintenance updates.  Some might not.
> In that case the way to support their kernel for your customers would =
be
> to start with the source for a particular maint update, add the =
missing
> patches, build, and distribute the result.
> You probably would only need to do this for each servie-pack, not for
> each update.
>=20
> It isn't really different from what it done today, but it would be =
done
> in a different way.
>=20
> Thanks,
> NeilBrown


--Apple-Mail=_69DA8A8C-0B44-4A58-9781-E91B70840763
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"overflow-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;"><br =
id=3D"lineBreakAtBeginningOfMessage"><div><br><blockquote =
type=3D"cite"><div>25 =D1=8F=D0=BD=D0=B2. 2025=E2=80=AF=D0=B3., =D0=B2 =
02:24, NeilBrown &lt;neilb@suse.de&gt; =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=
=D0=BB(=D0=B0):</div><br class=3D"Apple-interchange-newline"><div><div>On =
Thu, 23 Jan 2025, Alexey Lyahkov wrote:<br><blockquote =
type=3D"cite"><br><br><br> &nbsp;&nbsp;&nbsp;Keeping different kernels =
up to date with new updates is something<br> &nbsp;&nbsp;&nbsp;that<br> =
&nbsp;&nbsp;&nbsp;the linux-stable team does all the time. &nbsp;We do =
it at SUSE to. &nbsp;It<br> &nbsp;&nbsp;&nbsp;isn't<br> =
&nbsp;&nbsp;&nbsp;that hard.<br> &nbsp;&nbsp;&nbsp;You identify which =
patches *need* to be backported (ideally when<br> =
&nbsp;&nbsp;&nbsp;the<br> &nbsp;&nbsp;&nbsp;patch is created but that =
isn't always easy) and you use tools to<br> &nbsp;&nbsp;&nbsp;help<br> =
&nbsp;&nbsp;&nbsp;you backport them.<br><br>So Lustre developers needs =
control all stable kernels and think which<br>patch needs back ported =
and send it to Distro owner <br>And for each LTS kernels on the =
kernel.org.. I think it increase a =
work<br>dramatically.<br></blockquote><br>No. &nbsp;Lustre developers =
don't need to care about the stable kernels at<br>all. &nbsp;The stable =
team does that an explicitly say they don't want it to<br>be a burden on =
maintainers.<br></div></div></blockquote><div>Lustre maintainers don=E2=80=
=99t needs review code which affects a Lustre? It=E2=80=99s something =
new for me.</div><div>I understand a drivers changes should don=E2=80=99t =
reviewed by lustre team.</div><div>But arch/=E2=80=A6 fs/ .. mm/... =
kernel/ needs attention.</div><div>Lack to review will cause a very =
large quality degradation after short time.</div><div>As I point early - =
I think none of linux maintainers have a lustre cluster to test a =
patches before land.</div><div>They can do test own part and how to =
build at all. But how it affects a Lustre? A specially in performance =
area.</div><div>Small examples from past.</div><div>Small optimisation =
for page_accessed() and LRU lists fixes a problem with ext4 bitmap in =
memory and improve lustre performace for 10%. Due lack of read during =
write. (<a =
href=3D"https://lwn.net/Articles/548830/">https://lwn.net/Articles/548830/=
</a>)</div><div>Small change in jbd2 code - like replace list_add to =
list_add_tail - improve performance for 5-15% due journal handle =
starvation solved.</div><div>(<a =
href=3D"https://www.spinics.net/lists/linux-ext4/msg84888.html">https://ww=
w.spinics.net/lists/linux-ext4/msg84888.html</a>)</div><div><br></div><div=
>So yes, Lustre developers can move &nbsp;LTS kernels as unsupported =
area and if it=E2=80=99s broken just suggest to install an out-of-tree =
module with supported kernel. But did linux kernel needs a broken code =
in tree really?</div><div><br></div><div><br></div><blockquote =
type=3D"cite"><div><div>The lustre team *can* decide to have some =
involvement - adding Fixes<br>tags, adding Cc: stable, even submitting =
backports which don't apply<br>trivially. &nbsp;But there is no =
requirement from anywhere.<br><br></div></div></blockquote><blockquote =
type=3D"cite"><div><div>The lustre community only need to focus on one =
upstream.<br></div></div></blockquote><div>And have a broken lustre =
client once it don=E2=80=99t tested. Or lustre client will hit a =
performance degradation.</div><div><br></div><div><br></div><div>Neil, =
Tim,&nbsp;</div><div><br></div><blockquote type=3D"cite"><div><div>Lustre =
develops who work for employers who sell support for older<br>kernels =
might need to handle backports to those kernels and it is =
in<br>everybody's interest not to make that unduly different e.g. =
&nbsp;by<br>separating bug fixes from features =
etc.<br><br></div></div></blockquote><div>Lustre primary area is =
=E2=80=98older=E2=80=99 kernels. As I point early half of customers uses =
a RHEL7, second 30% is RHEL8.</div><div>And just 2% uses a modern =
kernels.</div><div><br></div><br><blockquote type=3D"cite"><div><div>The =
lustre community may well choose to host and share those =
backports,<br>and maybe even include them in testing. &nbsp;But I =
suspect that would be<br>driven by vendors who sell support. &nbsp;It =
certainly wouldn't be imposed by<br>the upstream =
community.<br><br>Exactly how we work with distros like Redhat, SUSE, =
Ubuntu would depend<br>on what can be negotiated with them.<br>Some =
might be willing to accept backports and release them in<br>maintenance =
updates. &nbsp;Some might not.<br>In that case the way to support their =
kernel for your customers would be<br>to start with the source for a =
particular maint update, add the missing<br>patches, build, and =
distribute the result.<br>You probably would only need to do this for =
each servie-pack, not for<br>each update.<br><br>It isn't really =
different from what it done today, but it would be done<br>in a =
different =
way.<br><br>Thanks,<br>NeilBrown<br></div></div></blockquote></div><br></b=
ody></html>=

--Apple-Mail=_69DA8A8C-0B44-4A58-9781-E91B70840763--

--===============7050565830297564441==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7050565830297564441==--
