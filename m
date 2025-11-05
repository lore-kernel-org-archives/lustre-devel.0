Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C71EFCCFA04
	for <lustre-devel@archiver.kernel.org>; Wed,  5 Nov 2025 00:45:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1RBX5Gxyz235D;
	Tue, 04 Nov 2025 16:33:24 -0800 (PST)
Received: from mail-oa1-f43.google.com (mail-oa1-f43.google.com
 [209.85.160.43])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1R8Y0n7Kz20fJ
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:31:41 -0800 (PST)
Received: by mail-oa1-f43.google.com with SMTP id
 586e51a60fabf-3de7e765439so1405480fac.1
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:31:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=google.com; s=20230601; t=1762302497; x=1762907297; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=ugBXnIZI1uU+962HPCh7NMnfD32WmI3RurpvULr5C7I=;
 b=P/8JX4oxpkvWrjq5Vm4gi5czO13vHlmZROc+rPDE/Q3E33HxY/fd6H0yx3cEBtX+6z
 L8Dh66LZt0HzomvN1tEQyfMXzk7yH/J3fhLX7qvNoXXJF0pR451EBjLfV816OL3ylw+v
 aA4NgWFFv80EGZCDsQYaS/RQzvF6x+G1JO2L/POnJ8Bj1beGcoBLIGi3RpdLovwGvSIQ
 mOUthq3PDCCS+R4s6N3bUDqBIwN/0+PAo0gfYuPrylJEYmR1SfpD8KVlMF6YM2HVxlkl
 nrp4O9ubCtSyQ6A4ofYaaM1O8b9GwhwPNar5YV6LLP0tz6YhvAItEBLmZ+65c7Dsauzj
 gmfw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762302497; x=1762907297;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=ugBXnIZI1uU+962HPCh7NMnfD32WmI3RurpvULr5C7I=;
 b=KGLGia7H13jgbCFaeqf5y+oQcbJxkcxTrL0lpIokCL4PP18fMMaHvxD6IBIVYAYjMd
 gQ0mIilRCuT3kQ/gKTOEpxDbuk6tL5jxQEplQ74yLbq4WgaX5sd1wNGs0C0B5VvgjXTd
 LJQOUo3+zB6NXLhK+7zTKZwB5xgQ8ypjsY/33q6NA60r23bGmgsc4DgSHZGqc/1GFxOq
 CnItvAuoPAYMmFH7Bze22/jhgcV9qPiIuSJT/5TXxpqYjQ9wyszNVvhlBUFf0fSEvfNo
 yjkIkOirxk6QeoFMy5ZG7humDXvqdg2h6tZeP1/ABZvWb9NuBIvlLvZtyc+1qq+3v2iv
 Rp1Q==
X-Forwarded-Encrypted: i=1;
 AJvYcCW2+rrzTxX9F1njoCj1IMOaabjab9wIZ50u578/D9WMEO5ABljrH5gNB7SOPiEmNWeWMm/qOh0Ev4T/TIw=@lists.lustre.org
X-Gm-Message-State: AOJu0Yx+pC9R85iLRL9IveGHBiaY/Hcx+1kHOpP5sxfdNugjxHAcpIhz
 OQjNVP2MEttbpC7Es5RU8Yg6BRwPX2W3nRvSMHsdFRuX2JTtu6AgdgMnvdEldjogqFhXLleWVBe
 DeZOQn4CE3oSuK+8l0esBf+gcH57kQ2/eiBehouyc
X-Gm-Gg: ASbGncseibMaVDKwZuFMqVs9gJVUtHMw2feRo0vh3zxIDow+YZvdATgfI6qWOulK1iV
 7Sm200LcOH7qYSxxMt0hGORu14N2za/1EcnWrmhv7GMtx+eAa3NNVPU3HfMlTH17IqMLYv+0Npl
 SMskk7SgZzWMC+2e0F8zBS9oU6NiQAy4jd0azRxrDyFfj8D024FyjtXS1WLzF+7cJC9/7rxFT7e
 vKiGWOuj0AieO5D8/NvErhShFX0XT7VAr5eipaFk79Y7806bjjpxyIz+uuL5Fi6Dzcm97hearpv
 O1wDRCYKgorXdovZm+W14aWZ92zY
X-Google-Smtp-Source: AGHT+IGqO70KjwfmS00GT7m08byKIeqMvPw0OoIUVDAsJbsH/vnKKVQKX7Ox3R23diXCQir4Xqq1wrhYU2PTEy9Z9W0=
X-Received: by 2002:a05:6870:c34f:b0:3e1:7fa9:9c01 with SMTP id
 586e51a60fabf-3e19b73fd06mr576451fac.39.1762302496506; Tue, 04 Nov 2025
 16:28:16 -0800 (PST)
MIME-Version: 1.0
References: <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
 <0092A54A-6EEF-4CD3-8AFD-7B0066A08810@gmail.com>
 <D8E0F0C0-1A5F-413A-82EA-F3CFA473D2E1@amazon.com>
 <28B74585-1877-4A33-9218-FD50AE72D33D@ddn.com>
 <74326E79-3FCD-41F5-B5DA-95EA2CC48435@gmail.com>
 <A0DE1BFF-A1D4-4104-8333-E6D771F46713@dilger.ca>
In-Reply-To: <A0DE1BFF-A1D4-4104-8333-E6D771F46713@dilger.ca>
Date: Tue, 4 Nov 2025 16:28:05 -0800
X-Gm-Features: AWmQ_bkZpTK-wn9X7hRiM1t9Rml06s-72PRG-WPCsAfX3fxjl1qUggjouQzYpJY
Message-ID: <CAEp8vphfZW4CjgQpCQi6yDBACoTP_3n-5EAFckrOi802_Ajmjw@mail.gmail.com>
To: Andreas Dilger <adilger@dilger.ca>
Subject: Re: [lustre-devel] RFC: Spill device for Lustre OSD
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
From: Jinshan Xiong via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Jinshan Xiong <jinshanx@google.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============2938527279369961605=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============2938527279369961605==
Content-Type: multipart/alternative; boundary="0000000000004b06af0642ce0698"

--0000000000004b06af0642ce0698
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 4, 2025 at 4:20=E2=80=AFPM Andreas Dilger via lustre-devel <
lustre-devel@lists.lustre.org> wrote:

> On Nov 4, 2025, at 4:42 PM, Jinshan Xiong wrote:
> > On Nov 4, 2025, at 15:07, Andreas Dilger <adilger@ddn.com> wrote:
> >> Timothy Day <timday@amazon.com> wrote:
> >>> Overall, I think the concept is interesting. It reminds me of how
> >>> Bcachefs handle multi-device support. Each device can be
> >>> designated as holding metadata or data replicas. And you
> >>> can control the promotion and migration between different
> >>> targets (all managed by a migration daemon). But this design is
> >>> too limited, IMHO. If we're going to accept the additional complexity
> >>> in the OSD, the solution has to be extensible. What if I want to
> >>> replicate to multiple targets? What if I want more than two tiers?
> >>> What if I want to transparently migrate data from one spill device to
> >>> another? We don't need this for the initial implementation, sure.
> >>> But these seem like natural extensions.
> >
> > It=E2=80=99s possible to extend the design to have multiple spill devic=
es in the
> OSD; you could have two spill devices and mirror them, or raid0 to make a
> larger device. I don=E2=80=99t see the design would not allow you to do t=
hat.
> >
> >> This is essentially replicating Lustre file layouts in the end, which
> >> was my original suggestion - to use FLR and/or PCC-RO foreign
> >> mirror layouts for this, even if it is not directly accessible from
> >> clients.  That avoids reimplementing tools/formats that already
> >> exist in Lustre today for relatively little benefit.
> >
> > One of the goals is to not have a file system-level scanner, which is
> not good. Otherwise, we can just use FLR-based tiered storage.
>
> I don't see how the layout xattr format is related to filesystem-level
> scanning?  This is "just" the xattr format *STORED ON THE OST OBJECT*,
> and it could be handled by direct device-level (OST) scan tools as well.
>

I see. I initially thought you proposed the spill device would function as
a mirror and that the existing software stack would handle it.

Are we going to store the spilled object's status in the layout? It sounds
difficult because you will have to initiate a layout change from the OSTs.
I think we still need to store such an xattr locally in the OST object.


>
> This would allow mirrors (FLR), multiple spill devices (multiple FLR
> mirrors), concatenated devices (PFL), etc.  It just avoids adding new
> formats that need to be parsed, printed, etc.
>
> Cheers, Andreas
>
>
>
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel@lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>

--0000000000004b06af0642ce0698
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote g=
mail_quote_container"><div dir=3D"ltr" class=3D"gmail_attr">On Tue, Nov 4, =
2025 at 4:20=E2=80=AFPM Andreas Dilger via lustre-devel &lt;<a href=3D"mail=
to:lustre-devel@lists.lustre.org">lustre-devel@lists.lustre.org</a>&gt; wro=
te:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px =
0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">On Nov 4, 20=
25, at 4:42 PM, Jinshan Xiong wrote:<br>
&gt; On Nov 4, 2025, at 15:07, Andreas Dilger &lt;<a href=3D"mailto:adilger=
@ddn.com" target=3D"_blank">adilger@ddn.com</a>&gt; wrote:<br>
&gt;&gt; Timothy Day &lt;<a href=3D"mailto:timday@amazon.com" target=3D"_bl=
ank">timday@amazon.com</a>&gt; wrote:<br>
&gt;&gt;&gt; Overall, I think the concept is interesting. It reminds me of =
how<br>
&gt;&gt;&gt; Bcachefs handle multi-device support. Each device can be<br>
&gt;&gt;&gt; designated as holding metadata or data replicas. And you<br>
&gt;&gt;&gt; can control the promotion and migration between different<br>
&gt;&gt;&gt; targets (all managed by a migration daemon). But this design i=
s<br>
&gt;&gt;&gt; too limited, IMHO. If we&#39;re going to accept the additional=
 complexity<br>
&gt;&gt;&gt; in the OSD, the solution has to be extensible. What if I want =
to<br>
&gt;&gt;&gt; replicate to multiple targets? What if I want more than two ti=
ers?<br>
&gt;&gt;&gt; What if I want to transparently migrate data from one spill de=
vice to<br>
&gt;&gt;&gt; another? We don&#39;t need this for the initial implementation=
, sure.<br>
&gt;&gt;&gt; But these seem like natural extensions.<br>
&gt; <br>
&gt; It=E2=80=99s possible to extend the design to have multiple spill devi=
ces in the OSD; you could have two spill devices and mirror them, or raid0 =
to make a larger device. I don=E2=80=99t see the design would not allow you=
 to do that.<br>
&gt; <br>
&gt;&gt; This is essentially replicating Lustre file layouts in the end, wh=
ich<br>
&gt;&gt; was my original suggestion - to use FLR and/or PCC-RO foreign<br>
&gt;&gt; mirror layouts for this, even if it is not directly accessible fro=
m<br>
&gt;&gt; clients.=C2=A0 That avoids reimplementing tools/formats that alrea=
dy<br>
&gt;&gt; exist in Lustre today for relatively little benefit.<br>
&gt; <br>
&gt; One of the goals is to not have a file system-level scanner, which is =
not good. Otherwise, we can just use FLR-based tiered storage.<br>
<br>
I don&#39;t see how the layout xattr format is related to filesystem-level<=
br>
scanning?=C2=A0 This is &quot;just&quot; the xattr format *STORED ON THE OS=
T OBJECT*,<br>
and it could be handled by direct device-level (OST) scan tools as well.<br=
></blockquote><div><br></div><div>I see. I initially thought you proposed t=
he spill device would function as a mirror and that the existing software s=
tack would handle it.</div><div><br></div><div>Are we going to store the sp=
illed object&#39;s status in the layout? It sounds difficult because you wi=
ll have to initiate a layout change from the OSTs. I think we still need to=
 store such an xattr locally in the OST object.</div><div>=C2=A0</div><bloc=
kquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:=
1px solid rgb(204,204,204);padding-left:1ex">
<br>
This would allow mirrors (FLR), multiple spill devices (multiple FLR<br>
mirrors), concatenated devices (PFL), etc.=C2=A0 It just avoids adding new<=
br>
formats that need to be parsed, printed, etc.<br>
<br>
Cheers, Andreas<br>
<br>
<br>
<br>
<br>
<br>
_______________________________________________<br>
lustre-devel mailing list<br>
<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-d=
evel@lists.lustre.org</a><br>
<a href=3D"http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org" re=
l=3D"noreferrer" target=3D"_blank">http://lists.lustre.org/listinfo.cgi/lus=
tre-devel-lustre.org</a><br>
</blockquote></div></div>

--0000000000004b06af0642ce0698--

--===============2938527279369961605==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============2938527279369961605==--
