Return-Path: <SRS0=LkXh=IK=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08078C433DB
	for <lustre-devel@archiver.kernel.org>; Fri, 12 Mar 2021 12:28:43 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0D8E964F6C
	for <lustre-devel@archiver.kernel.org>; Fri, 12 Mar 2021 12:28:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D8E964F6C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 82AC721F562;
	Fri, 12 Mar 2021 04:28:41 -0800 (PST)
Received: from mail-lf1-f46.google.com (mail-lf1-f46.google.com
 [209.85.167.46])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8C0AB312009
 for <lustre-devel@lists.lustre.org>; Thu, 11 Mar 2021 20:36:09 -0800 (PST)
Received: by mail-lf1-f46.google.com with SMTP id x4so36896588lfu.7
 for <lustre-devel@lists.lustre.org>; Thu, 11 Mar 2021 20:36:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=cloudlinux.com; s=google;
 h=from:message-id:mime-version:subject:date:in-reply-to:cc:to
 :references; bh=IqL9uq8U8U12Wdj3LF3h6kRNNrIrwkV/Zr7FzAtLQ5U=;
 b=FVbivas2LnVYcAOdiPrmWaUSVYN+r8oSvTzT3YD4nN032VRlzo0wQG2Ok1wXZWspWt
 jC9KtwFM8Ou/1hWTh2/200a6Oh4sYPv/QYZ4TP9OU4H1fcz3mDiG/OdRjOk5lnPp2wGh
 W6w92Oe/adLnYZY0I3rgZiK8f2RtHPqjLSYFZc6P2Rsfb7c5fRj25XmmzbDolINCHP8L
 XUz9+9dzmaTdWQPo556sMHKjT9Vi1KnWZFtrlODUUYffCtQ8++anI43Jz2MU9EGWnITS
 STvdDff/F3rwMdwueROzUWDX/8L1ZARRipwyk/7qSu6PjJsfbAhkxFVpN4a16ozUPPV2
 l14A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:message-id:mime-version:subject:date
 :in-reply-to:cc:to:references;
 bh=IqL9uq8U8U12Wdj3LF3h6kRNNrIrwkV/Zr7FzAtLQ5U=;
 b=TI8d1nZ902ZHQuwimBjRd3ibDmB2OePsRPQvFJV9QGIk+42snM2LMdWRbhc63YTKpP
 AXEOmPH11pPtIXS6fo4ojFlv/xgVfjYMA49kkjZx3/fndVPrsiKiLbrdc9/UJ2EvmRFX
 BG1aG1MMy96xI6or9tyR6u21PMSpiSb0cywdNHWZ1yWr7uI7YyzGRFYIdBqxNk2ze8Wb
 Ovq6tNAMjYp8hF4fhvJ0VnBbUUuQL8acpttpKSlqrzmYRQIc6XUBoKsz5HNIZKoN4ppC
 idJFS27xUh/xPabyjGE2+ssbT7kJdjfdKeuSc1OKUg49shhSwu3tjK1odH21WUIzJajB
 rmEw==
X-Gm-Message-State: AOAM530OXOErOaz/4UvoC0UIZaFCNshwlcQj2dxjXOiRkVNvr43cSu5c
 5bj/HrNFJSPVzMh4izvCq7rG1A==
X-Google-Smtp-Source: ABdhPJzLSul+9dRl3BfcJrjKZrqyABKgBgi+W7hqWa1Qh+ZdCbAIpxXTLT5+eugAxjQSuhYupMSEDA==
X-Received: by 2002:ac2:5221:: with SMTP id i1mr4279863lfl.160.1615523768196; 
 Thu, 11 Mar 2021 20:36:08 -0800 (PST)
Received: from [192.168.1.5] ([5.8.48.45])
 by smtp.gmail.com with ESMTPSA id f25sm1451455lfh.226.2021.03.11.20.36.07
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Thu, 11 Mar 2021 20:36:07 -0800 (PST)
Message-Id: <5BFA79A7-96F0-4C71-8266-5460DFD7A0F6@cloudlinux.com>
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.7\))
Date: Fri, 12 Mar 2021 07:36:05 +0300
In-Reply-To: <B489BBDF-36DA-4B79-BCB3-19FBBEEF75E2@amazon.com>
To: "Degremont, Aurelien" <degremoa@amazon.com>
References: <B489BBDF-36DA-4B79-BCB3-19FBBEEF75E2@amazon.com>
X-Mailer: Apple Mail (2.3445.9.7)
X-Mailman-Approved-At: Fri, 12 Mar 2021 04:28:39 -0800
Subject: Re: [lustre-devel] LDLM behaviour question
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
From: Alexey Lyashkov via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Alexey Lyashkov <umka@cloudlinux.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============6025183517572758847=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


--===============6025183517572758847==
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_EAA4D1BF-8E0C-4B9E-8A0F-8C5F73A01F00"


--Apple-Mail=_EAA4D1BF-8E0C-4B9E-8A0F-8C5F73A01F00
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

Aur=C3=A9lien,



> 8 =D0=BC=D0=B0=D1=80=D1=82=D0=B0 2021 =D0=B3., =D0=B2 17:09, =
Degremont, Aurelien via lustre-devel <lustre-devel@lists.lustre.org> =
=D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB(=D0=B0):
>=20
> Hi all,
>=20
> I was not able to find a document giving this level of detail of LDLM =
behavior.
I think this aged book will good start. =
https://wiki.lustre.org/images/d/da/Understanding_Lustre_Filesystem_Intern=
als.pdf =
<https://wiki.lustre.org/images/d/da/Understanding_Lustre_Filesystem_Inter=
nals.pdf>


> I have a basic question regarding compatibility between IBITS lock for =
the same fid.
>=20
> Is it possible for the same MDT to lock the same FID, with 2 IBITS =
lock, with different bits? (ie: UPDATE vs LAYOUT)
> What's the behavior is not working?
>=20
Yes, this is possible. Same story as LOOKUP, OPEN, DOM =E2=80=A6


> Second question: what happen when you call multiple times =
mdt_object_lock() for the same fid/same bits on the same MDT?
>=20
> Thanks
>=20
> Aur=C3=A9lien=20
>=20
> _______________________________________________
> lustre-devel mailing list
> lustre-devel@lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org


--Apple-Mail=_EAA4D1BF-8E0C-4B9E-8A0F-8C5F73A01F00
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D""><div =
class=3D"">Aur=C3=A9lien,</div><div class=3D""><br class=3D""></div><div =
class=3D""><br class=3D""></div><div class=3D""><div><br =
class=3D""><blockquote type=3D"cite" class=3D""><div class=3D"">8 =
=D0=BC=D0=B0=D1=80=D1=82=D0=B0 2021 =D0=B3., =D0=B2 17:09, Degremont, =
Aurelien via lustre-devel &lt;<a =
href=3D"mailto:lustre-devel@lists.lustre.org" =
class=3D"">lustre-devel@lists.lustre.org</a>&gt; =
=D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB(=D0=B0):</div><br =
class=3D"Apple-interchange-newline"><div class=3D""><div class=3D"">Hi =
all,<br class=3D""><br class=3D"">I was not able to find a document =
giving this level of detail of LDLM behavior.<br =
class=3D""></div></div></blockquote><div><div class=3D"">I think this =
aged book will good start.&nbsp;<a =
href=3D"https://wiki.lustre.org/images/d/da/Understanding_Lustre_Filesyste=
m_Internals.pdf" =
class=3D"">https://wiki.lustre.org/images/d/da/Understanding_Lustre_Filesy=
stem_Internals.pdf</a></div><div class=3D""><br class=3D""></div></div><br=
 class=3D""><blockquote type=3D"cite" class=3D""><div class=3D""><div =
class=3D"">I have a basic question regarding compatibility between IBITS =
lock for the same fid.<br class=3D""><br class=3D"">Is it possible for =
the same MDT to lock the same FID, with 2 IBITS lock, with different =
bits? (ie: UPDATE vs LAYOUT)<br class=3D"">What's the behavior is not =
working?<br class=3D""><br class=3D""></div></div></blockquote><div>Yes, =
this is possible. Same story as LOOKUP, OPEN, DOM =E2=80=A6</div><div><br =
class=3D""></div><br class=3D""><blockquote type=3D"cite" class=3D""><div =
class=3D""><div class=3D"">Second question: what happen when you call =
multiple times mdt_object_lock() for the same fid/same bits on the same =
MDT?<br class=3D""><br class=3D""></div></div></blockquote><blockquote =
type=3D"cite" class=3D""><div class=3D""><div class=3D"">Thanks<br =
class=3D""><br class=3D"">Aur=C3=A9lien <br class=3D""><br =
class=3D"">_______________________________________________<br =
class=3D"">lustre-devel mailing list<br class=3D""><a =
href=3D"mailto:lustre-devel@lists.lustre.org" =
class=3D"">lustre-devel@lists.lustre.org</a><br =
class=3D"">http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org<br=
 class=3D""></div></div></blockquote></div><br =
class=3D""></div></body></html>=

--Apple-Mail=_EAA4D1BF-8E0C-4B9E-8A0F-8C5F73A01F00--

--===============6025183517572758847==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6025183517572758847==--
