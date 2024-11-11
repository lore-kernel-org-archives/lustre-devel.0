Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id AEA79D2E9C0
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Nov 2024 08:49:40 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Xn3BS5DBTz1x47;
	Mon, 11 Nov 2024 00:49:20 -0800 (PST)
Received: from mail-ej1-f52.google.com (mail-ej1-f52.google.com
 [209.85.218.52])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Xn3BR0KGBz1wM0
 for <lustre-devel@lists.lustre.org>; Mon, 11 Nov 2024 00:49:19 -0800 (PST)
Received: by mail-ej1-f52.google.com with SMTP id
 a640c23a62f3a-a9a4031f69fso719760466b.0
 for <lustre-devel@lists.lustre.org>; Mon, 11 Nov 2024 00:49:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=googlemail.com; s=20230601; t=1731314957; x=1731919757; darn=lists.lustre.org;
 h=mime-version:subject:references:in-reply-to:message-id:cc:to:from
 :date:from:to:cc:subject:date:message-id:reply-to;
 bh=G4VmeETC/o3M6N8TH3ixQOvMoT3JbL8BFZEmDLEpigs=;
 b=NDa4ad4LxxbE/Tcp4oscF64XfgDG9/0SOv0YoHgKRtazKJ1iztj0EIBZB2A0IDV4zr
 sM44M3D6K/eg0zmuWXD3oajoxf9fwzqv6LSjk53HaFvuRpNaSlKkeMuwRlq9IKuxpOTZ
 moAHTPT4iG4mfSlbIbvB4mlRQ3dcrRVScej9mRlhwmz9eMlRluKzzyEvZlRwYbMuYopE
 KOXge4mMrNxrjut8zXf0gcJG3ZvL3n7upe4Smo+ZsMpo4uI/SShuSdSOV1Utcb7wUXYl
 GdRms4518zQ0V0F5Ypzuv+WrdKcgaQeSdI0rfXGoLhppfIBtM1ULYy5HJ0G0oAnF/yO0
 k21A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1731314957; x=1731919757;
 h=mime-version:subject:references:in-reply-to:message-id:cc:to:from
 :date:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=G4VmeETC/o3M6N8TH3ixQOvMoT3JbL8BFZEmDLEpigs=;
 b=eHqWDHjADQR3RJHt2EYHxYW8Vz0jUAHNkZ9tskf27Q7XQU11wdcQIA8WGho0ejwib1
 4V/ny/KDxseec+JseshtQHtaardfUF6AaO8dDaBBiAISVYykDYfffINKNKPuUDSne2zo
 fj6C1Qe5n5s8o/GR0+pyvU5iPdllniPlaRwAToqtHbFGJcM0xtPz95zQPntOeLzZMmOZ
 PDUQbVUmKWqfri5mrX7kvpHL1iC1dF1R5ZWu9dQ+S4pRUvyxfSh6hmdomoTY0i51siEL
 UWWYalTXrU8YBZjxxVq0y/BfHev3ailVLE4IbYv1+VxrSnRYV3K68ZKw/oP/FTbelyZp
 BtAg==
X-Gm-Message-State: AOJu0YwVd5PdsDxONZwQLuel6HHAVNkz3P50GKT3W86KXhrq1ax1RKsE
 GTgK5muaezpTMOxnID65mhWhHoASz9gyYnmw8ClJ1gil13tnCSlG+2DsMg==
X-Google-Smtp-Source: AGHT+IFqy0pltfwoSo583AXb8snMFlmsqjUsxHvQHMX+5kImesRbFXMI0b9uqWMjeYRvI5wbKY2iCQ==
X-Received: by 2002:a17:907:3f13:b0:a9a:b9d:bd93 with SMTP id
 a640c23a62f3a-a9eefebd119mr1113844766b.4.1731314957002; 
 Mon, 11 Nov 2024 00:49:17 -0800 (PST)
Received: from [127.0.0.1] (ip-109-40-242-13.web.vodafone.de. [109.40.242.13])
 by smtp.gmail.com with ESMTPSA id
 a640c23a62f3a-a9ee0a4b82csm577341566b.67.2024.11.11.00.49.14
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Mon, 11 Nov 2024 00:49:16 -0800 (PST)
Date: Mon, 11 Nov 2024 09:49:10 +0100 (GMT+01:00)
From: Detlev Conrad Mielczarek <detlevcm@googlemail.com>
To: Else Someone <else@someonex.net>
Cc: lustre-devel@lists.lustre.org
Message-ID: <8d912ebc-ea84-4745-b347-21c8d6912590@googlemail.com>
In-Reply-To: <435e4ec8-35b7-4a23-8924-70607d90d654@someonex.net>
References: <435e4ec8-35b7-4a23-8924-70607d90d654@someonex.net>
MIME-Version: 1.0
X-Correlation-ID: <8d912ebc-ea84-4745-b347-21c8d6912590@googlemail.com>
Subject: Re: [lustre-devel] mke2fs supported features: dirdata
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
Content-Type: multipart/mixed; boundary="===============3009261318032903227=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3009261318032903227==
Content-Type: multipart/alternative; 
	boundary="----=_Part_6_263400091.1731314950801"

------=_Part_6_263400091.1731314950801
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Dear user,

Yes, you also need to build a patched e2fsprogs.
This is outlined in the Whamcloud hosted instructions and I recently wrote =
instructions for Rocky 8.10 & 9.4 (hosted on Github), though kernel release=
 numbers changed since...

The Whamcloud Wiki is here: https://wiki.whamcloud.com/display/PUB/Building=
+Lustre+from+Source
My own instructions are here: https://github.com/DetlevCM/lustre-build-inst=
ructions

Kind regards
Detlev

-----=E2=80=90--------------------------------------
Detlev Conrad Mielczarek
+49 1520 4712 446
+33 6 48 15 19 95
detlevcm@googlemail.com

10 Nov 2024 02:08:45 Else Someone <else@someonex.net>:

> Hello again! I posted here earlier about my attempts at building Lustre w=
ith Nix. There was another issue I was struggling with, related to e2fsprog=
s, that I thought I should ask here if I was supposed to patch it too?
>=20
>=20
> My mkfs.lustre (ldiskfs) is failing with mke2fs complaining about an "inc=
ompatible option set". Specifically it's complaining about the option `dird=
ata`. Looking at e2fsprogs' sources, `EXT4_FEATURE_INCOMPAT_DIRDATA` isn't =
listed in `ok_features` in `misc/mke2fs.c`. Even if I add it there, mke2fs =
fails later at `ext2fs_initialize`. I was surprised not to find any error r=
eports in jira concerning dirdata specifically (there were similar errors r=
eported for e.g. large_dir), surely I must be doing something wrong.
>=20
>=20
> Do I have to patch e2fsprogs?
>=20
>=20
> Do tell me if I'm being too noisy or if there's a better channel for this=
 sort of questions. I actually have a few more, should I ask each in a sepa=
rate thread or should I aggregate all under one SUBJECT?
>=20
>=20
> Thanks
>=20
> _______________________________________________
> lustre-devel mailing list
> lustre-devel@lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

------=_Part_6_263400091.1731314950801
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<html>
 <head>
  <meta name=3D"viewport" content=3D"width=3Ddevice-width, initial-scale=3D=
1.0">
 </head>
 <body>
  <span dir=3D"ltr" style=3D"margin-top:0; margin-bottom:0;">Dear user,</sp=
an>
  <br>
  <br><span dir=3D"ltr" style=3D"margin-top:0; margin-bottom:0;">Yes, you a=
lso need to build a patched e2fsprogs.</span>
  <br><span dir=3D"ltr" style=3D"margin-top:0; margin-bottom:0;">This is ou=
tlined in the Whamcloud hosted instructions and I recently wrote instructio=
ns for Rocky 8.10 &amp; 9.4 (hosted on Github), though kernel release numbe=
rs changed since...</span>
  <br>
  <br><span dir=3D"ltr" style=3D"margin-top:0; margin-bottom:0;">The Whamcl=
oud Wiki is here: https://wiki.whamcloud.com/display/PUB/Building+Lustre+fr=
om+Source</span>
  <br><span dir=3D"ltr" style=3D"margin-top:0; margin-bottom:0;">My own ins=
tructions are here: https://github.com/DetlevCM/lustre-build-instructions</=
span>
  <br>
  <br><span dir=3D"ltr" style=3D"margin-top:0; margin-bottom:0;">Kind regar=
ds</span>
  <br><span dir=3D"ltr" style=3D"margin-top:0; margin-bottom:0;">Detlev </s=
pan>
  <br>
  <div class=3D"fairemail_signature">
   <br><span dir=3D"ltr" style=3D"margin-top:0; margin-bottom:0;">-----=E2=
=80=90--------------------------------------</span>
   <br><span dir=3D"ltr" style=3D"margin-top:0; margin-bottom:0;">Detlev Co=
nrad Mielczarek</span>
   <br><span dir=3D"ltr" style=3D"margin-top:0; margin-bottom:0;">+49 1520 =
4712 446</span>
   <br><span dir=3D"ltr" style=3D"margin-top:0; margin-bottom:0;">+33 6 48 =
15 19 95</span>
   <br><span dir=3D"ltr" style=3D"margin-top:0; margin-bottom:0;">detlevcm@=
googlemail.com</span>
   <br>
  </div>
  <div class=3D"fairemail_quote">
   <div dir=3D"ltr">
    <p>10 Nov 2024 02:08:45 Else Someone &lt;else@someonex.net&gt;:</p>
   </div>
   <blockquote style=3D"margin:0;border-left:3px solid #ccc; padding-left:1=
0px;">
    <div>
     Hello again! I posted here earlier about my attempts at building Lustr=
e with Nix. There was another issue I was struggling with, related to e2fsp=
rogs, that I thought I should ask here if I was supposed to patch it too?=
=20
     <br>
     <br>
     <br>
      My mkfs.lustre (ldiskfs) is failing with mke2fs complaining about an =
"incompatible option set". Specifically it's complaining about the option `=
dirdata`. Looking at e2fsprogs' sources, `EXT4_FEATURE_INCOMPAT_DIRDATA` is=
n't listed in `ok_features` in `misc/mke2fs.c`. Even if I add it there, mke=
2fs fails later at `ext2fs_initialize`. I was surprised not to find any err=
or reports in jira concerning dirdata specifically (there were similar erro=
rs reported for e.g. large_dir), surely I must be doing something wrong.=20
     <br>
     <br>
     <br>
      Do I have to patch e2fsprogs?=20
     <br>
     <br>
     <br>
      Do tell me if I'm being too noisy or if there's a better channel for =
this sort of questions. I actually have a few more, should I ask each in a =
separate thread or should I aggregate all under one SUBJECT?=20
     <br>
     <br>
     <br>
      Thanks=20
     <br>
     <br>
      _______________________________________________=20
     <br>
      lustre-devel mailing list=20
     <br>
      lustre-devel@lists.lustre.org=20
     <br>
      http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org=20
     <br>
    </div>
   </blockquote>
  </div>
 </body>
</html>
------=_Part_6_263400091.1731314950801--

--===============3009261318032903227==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3009261318032903227==--
