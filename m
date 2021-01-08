Return-Path: <SRS0=fXOm=GL=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05186C433DB
	for <lustre-devel@archiver.kernel.org>; Fri,  8 Jan 2021 19:44:42 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8C0A423A79
	for <lustre-devel@archiver.kernel.org>; Fri,  8 Jan 2021 19:44:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C0A423A79
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3EB8B21CADD;
	Fri,  8 Jan 2021 11:44:40 -0800 (PST)
Received: from mail-yb1-f181.google.com (mail-yb1-f181.google.com
 [209.85.219.181])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 601C021C9A3
 for <lustre-devel@lists.lustre.org>; Fri,  8 Jan 2021 11:44:38 -0800 (PST)
Received: by mail-yb1-f181.google.com with SMTP id b64so10411234ybg.7
 for <lustre-devel@lists.lustre.org>; Fri, 08 Jan 2021 11:44:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:from:date:message-id:subject:to;
 bh=0B+/s2oO0fRpqqr0mluBhQcWrCRw7NUhEw5uvpsFlsk=;
 b=TO+tPXnt9s+yavpqpqDGWPuLRWuGCw96P5wUwNBLo7gGGw/oxcIp2z2XfvBUsZDTLR
 dZjlbz+keeXDXQE6qbPJV7dV7rpfHbwKwMA7/kZE2bkyTGPKQ2JsxrHhtJpgGfnJqjw7
 wTSwqoQBtI/afiaoF9x4HG6nLtDGBi1yH39r/t7Dpv0aewONRQKKnvDKvv9tE8hF6Wcl
 2xMyPZ+x1xqeunzb9IkAkljIy6PKjRBuKG57mOlSVNUa0H1RF8NFcJfbkd96nVGmvHuF
 LQ/uAwg83Pv4ESkCPWDR2VaBF2w64wfSkZCMWzQsN1eR+fnsfH45kpRHGn64r0FaGXL3
 Q/jw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
 bh=0B+/s2oO0fRpqqr0mluBhQcWrCRw7NUhEw5uvpsFlsk=;
 b=CbyG6TRZLwLXO8hgxxAEkxb+YhZQ1HRj/s5/EHJC/BO08NDwJNRtH1F01lPDGdYM1V
 bXXiGwAWXVkTLYGOJP1D4a6DZbMuNy4YkNBNLRJShVGhzktEBaUtgsDvxKAcJpT7C+7T
 mHuEeygIsehDihOgOWFvD8swFNoXNkKES3/jTyHbFw1rvKffG3LfbkD312PYGll0L5J/
 501JUlONUMx0BZUr8oLG9zlJ6gnZzAKD29MWj0xGW7Jg906kXDTzyRALZrshKlxa96nm
 L9PHMkzFlzId6GvWeYc1WdU6ON4Z+txrW2hujrtk6APcV87NR/yUHC27SS70qV2dCzoF
 Zdgw==
X-Gm-Message-State: AOAM531Kr2HriqtyLEkZZZAEmlOyvx62sade6lEaJRQDEuqq/txgSJLm
 aBWvyO0YRZ/Lhg+S2A6tiuUBV01F1BwIWBlmQtkRRj7Ohe4SKA==
X-Google-Smtp-Source: ABdhPJzAR25LbUvaAz5gqPWNjNjHUtA2tN98WL/bdYBCObyo7X3cA9nGHydgFdjftV6DE+tbQXaL0TE7JHI79Jw2RHs=
X-Received: by 2002:a25:5e42:: with SMTP id s63mr8485705ybb.202.1610135077218; 
 Fri, 08 Jan 2021 11:44:37 -0800 (PST)
MIME-Version: 1.0
From: Nathan Rutman <nrutman@gmail.com>
Date: Fri, 8 Jan 2021 11:44:26 -0800
Message-ID: <CAA4iDz6+c4Qthf+aEYZf+7gugX_1mqoSucaB1RTrE2DkU6P1VQ@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] modern precreate
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
Content-Type: multipart/mixed; boundary="===============8998494049013725095=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8998494049013725095==
Content-Type: multipart/alternative; boundary="000000000000516fb205b868c908"

--000000000000516fb205b868c908
Content-Type: text/plain; charset="UTF-8"

Riffing on something Andreas said in a lustre-discuss thread, I'm
hoping someone can correct my understanding of how precreate works
currently.

Olden days:

MDS would ask each OST for a set of precreated objects via a MDT->OST
RPC. These have to be cleaned up during recovery, hence a cap. These
were used up as MDS assigned them to layouts, and so MDS has to go
back and get more, even for 0-length files.

Modern days, Lustre 2.5+:

MDT doesn't hold a pool of OST objects but instead takes an OST fid
range from a FLD server instead. Each MD object has a mapping with an
eventual OST object by this fid. The OST side just holds a small
number of anonymous objects and assigns the fid to an object when any
operation is executed without an existing FID->inode mapping on the
OST.There is no more precreate RPC necessary, since OSTs maintain
their own pool of anonymous objects and only use them up when data is
actually written, and can create more when running low. There is no
recovery cleanup needed on the OSTs.
In this case, there should be no performance difference between create
and mknod except for the FLD operation, and the number of OSTs should
not matter for create rates.

Is my understanding wrong? It clearly must be, since Andreas is still
talking OST_CREATE rpc and recovery implications, and we do see a
performance difference with mknod and creating files with layouts.

[lustre-discuss] Improving file create performance with larger create_count)

The max_create_count is between 32 and 20000 (for protocol recovery
reasons, since unused precreated objects are destroyed during
recovery, and we put a cap on how many objects could be destroyed to
avoid badness in case of a bug) so this is already at the maximum.
You should be able to increase the create_count to 20000 as well.
However, this value is "auto tuned" based on how long it takes the OSS
to create the requested objects.  If the OST_CREATE RPC takes too long
then the MDS will ask for fewer objects next time.
> * Is there a theoretical down side to pre-creating more objects?  (MDS or OSS memory usage?  Longer mount times? slower e2fsck?)
> A bit slower e2fsck, but compared to the total filesystem size this is minor.  The biggest issue is that the old precreated objects will be destroyed during MDS-OSS recovery and new ones created.

--000000000000516fb205b868c908
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><pre style=3D"white-space:pre-wrap;color:rgb(0,0,0)"><h1 s=
tyle=3D"white-space:normal"><span style=3D"font-weight:normal"><font size=
=3D"2" style=3D""></font></span></h1></pre><pre style=3D"white-space:pre-wr=
ap"><font color=3D"#000000" style=3D"background-color:rgb(255,255,255)" fac=
e=3D"arial, sans-serif">Riffing on something Andreas said in a lustre-discu=
ss thread, I&#39;m hoping someone can correct my understanding of how precr=
eate works currently.</font></pre><pre style=3D"white-space:pre-wrap"><font=
 color=3D"#000000" style=3D"background-color:rgb(255,255,255)" face=3D"aria=
l, sans-serif">Olden days: </font></pre><pre style=3D"white-space:pre-wrap"=
><font color=3D"#000000" style=3D"background-color:rgb(255,255,255)" face=
=3D"arial, sans-serif">MDS would ask each OST for a set of precreated objec=
ts via a MDT-&gt;OST RPC. These have to be cleaned up during recovery, henc=
e a cap. These were used up as MDS assigned them to layouts, and so MDS has=
 to go back and get more, even for 0-length files.</font></pre><pre style=
=3D"white-space:pre-wrap"><font color=3D"#000000" style=3D"background-color=
:rgb(255,255,255)" face=3D"arial, sans-serif">Modern days, Lustre 2.5+:</fo=
nt></pre><pre style=3D"white-space:pre-wrap"><span style=3D"box-sizing:inhe=
rit;font-variant-ligatures:common-ligatures;white-space:normal;background-c=
olor:rgb(255,255,255)"><font color=3D"#000000" style=3D"" face=3D"arial, sa=
ns-serif">MDT doesn&#39;t hold a pool of OST objects but instead takes an O=
ST fid range from a FLD server instead. Each MD object has a mapping with a=
n eventual OST object by this fid. The OST side just holds a small number o=
f anonymous objects and assigns the fid to an object when any operation is =
executed without an existing FID-&gt;inode mapping on the OST.</font></span=
><span class=3D"gmail-c-mrkdwn__br" style=3D"box-sizing:inherit;display:blo=
ck;height:8px;font-variant-ligatures:common-ligatures;white-space:normal"><=
/span><font color=3D"#000000" style=3D"background-color:rgb(255,255,255)" f=
ace=3D"arial, sans-serif"><span style=3D"box-sizing:inherit;font-variant-li=
gatures:common-ligatures;white-space:normal">There is no more precreate RPC=
 necessary, since OSTs maintain their own pool of anonymous objects and onl=
y use them up when data is actually written, and can create more when runni=
ng low. There is no recovery cleanup needed on the OSTs.=C2=A0</span><br st=
yle=3D"box-sizing:inherit;font-variant-ligatures:common-ligatures;white-spa=
ce:normal"><span style=3D"box-sizing:inherit;font-variant-ligatures:common-=
ligatures;white-space:normal">In this case, there should be no performance =
difference between create and mknod except for the FLD operation, and the n=
umber of OSTs should not matter for create rates.</span></font></pre><pre s=
tyle=3D""><font color=3D"#000000" face=3D"arial, sans-serif"><span style=3D=
"font-variant-ligatures:common-ligatures;white-space:normal">Is my understa=
nding wrong? It clearly must be, since Andreas is still talking OST_CREATE =
rpc and recovery implications, and we do see a performance difference with =
mknod and creating files with layouts.<br></span></font><span class=3D"gmai=
l-c-mrkdwn__br" style=3D"white-space:normal;box-sizing:inherit;display:bloc=
k;height:8px;font-variant-ligatures:common-ligatures"></span><span class=3D=
"gmail-c-mrkdwn__br" style=3D"white-space:normal;box-sizing:inherit;display=
:block;height:8px;font-variant-ligatures:common-ligatures"><br></span></pre=
><pre style=3D"white-space:pre-wrap;color:rgb(0,0,0)"><blockquote class=3D"=
gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(20=
4,204,204);padding-left:1ex">[lustre-discuss] Improving file create perform=
ance with larger create_count)<span style=3D"font-family:Arial,Helvetica,sa=
ns-serif">=C2=A0</span><span style=3D"font-family:Arial,Helvetica,sans-seri=
f">=C2=A0</span></blockquote><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1=
ex">The max_create_count is between 32 and 20000 (for protocol recovery rea=
sons, since unused precreated objects are destroyed during recovery, and we=
 put a cap on how many objects could be destroyed to avoid badness in case =
of a bug) so this is already at the maximum.  You should be able to increas=
e the create_count to 20000 as well. However, this value is &quot;auto tune=
d&quot; based on how long it takes the OSS to create the requested objects.=
  If the OST_CREATE RPC takes too long then the MDS will ask for fewer obje=
cts next time.
* Is there a theoretical down side to pre-creating more objects?  (MDS or O=
SS memory usage?  Longer mount times? slower e2fsck?)
A bit slower e2fsck, but compared to the total filesystem size this is mino=
r.  The biggest issue is that the old precreated objects will be destroyed =
during MDS-OSS recovery and new ones created.</blockquote></pre><br class=
=3D"gmail-Apple-interchange-newline"></div>

--000000000000516fb205b868c908--

--===============8998494049013725095==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8998494049013725095==--
