Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=1.0 required=3.0 tests=BAYES_05,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_KAM_HTML_FONT_INVALID autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91CE3C433ED
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 15:07:48 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F2093610E9
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 15:07:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2093610E9
Authentication-Results: mail.kernel.org; dmarc=pass (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 80CF921F6B2;
	Tue,  4 May 2021 08:07:47 -0700 (PDT)
Received: from mail-io1-f45.google.com (mail-io1-f45.google.com
 [209.85.166.45])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6CDA721F1FA
 for <lustre-devel@lists.lustre.org>; Sat,  1 May 2021 15:25:31 -0700 (PDT)
Received: by mail-io1-f45.google.com with SMTP id z14so1188064ioc.12
 for <lustre-devel@lists.lustre.org>; Sat, 01 May 2021 15:25:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=uncc.edu; s=google;
 h=mime-version:from:date:message-id:subject:to;
 bh=fJPnVOLOmDw+jGBGh7S0fyY+XMHX0aKtowju/vnSHMk=;
 b=eDOqGI66h9iYKxtcSpK0dvlcUSiMCAYVyk5zjVkv2xs6EVjDWJssopgSODAz5S/DcA
 SyJyXzNdTjSYYn6StCf9zoj2GSfemv2cOwguVMidJNynYwLFRVNUZ21YKyRcJP7yws9r
 qK3U3pZEF0XEi0prijsl0TXtS/7NvxqVX1eVI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
 bh=fJPnVOLOmDw+jGBGh7S0fyY+XMHX0aKtowju/vnSHMk=;
 b=mr4yLCcUQjCOt7APB6dGxI7Um/xj+vYr8HajAtliDlp5b3o+UrWHL9Y95vE8KrRZBQ
 1vyKm7SaKNUDTSpmqaGi8Q16a3q5YwxLs6fh6RV01Du3vwtrGEKfXl4Raon3E8hKqTIv
 lUwartcthS/ib7kteaa8a4/rdYV+9pzvmrSs3Wi1I3l8uUFwGRqELw6wi6JmtipPguPc
 5POSLqZZzq4pyICy5Nl/u+NvBASiigeFPYpruc7SEBDyTsF8kY0H3WTPRYdlGra55HAa
 VSm74spwMS8fGFPe0BFHp04wI7fX5l1cMtEffBfEWQp9OnsdDDuMVhmfSLDAn9kJHZck
 YxYg==
X-Gm-Message-State: AOAM532lMVG35NBr2waEd7qZu0mhCIDtPQAWt4r03Xy359NXa5ar77Fm
 RcNysIEIE3q+QU91EwHqaqBw3bFLHPknIigcio9vCIklUYMz/A==
X-Google-Smtp-Source: ABdhPJxHlgyCorqmp19/5j9wNT54CRzE8LfIAibXJnSroVX0zTg6ssWbhErDX2hf7peRJklTZ1+UQSgqfZckGRfQU7Y=
X-Received: by 2002:a05:6638:4a:: with SMTP id
 a10mr11340883jap.142.1619907930357; 
 Sat, 01 May 2021 15:25:30 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 1 May 2021 18:25:19 -0400
Message-ID: <CACyzrcQCUg7RDj9nwa8c8njt9M-wUBB-RgNkTtNkx_zoXsEz5g@mail.gmail.com>
To: lustre-devel@lists.lustre.org
X-Mailman-Approved-At: Tue, 04 May 2021 08:07:45 -0700
Subject: [lustre-devel] Reading extended attributes from a Lustre filesystem
 image.
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
From: Saisha Kamat via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Saisha Kamat <skamat1@uncc.edu>
Content-Type: multipart/mixed; boundary="===============7627152796473210394=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7627152796473210394==
Content-Type: multipart/alternative; boundary="000000000000c2274305c14c34b1"

--000000000000c2274305c14c34b1
Content-Type: text/plain; charset="UTF-8"

Hello,


I am a Ph.D student at UNCC and our team is working on the Lustre
filesystem. I am reading extended attributes of the ldiskfs for every
inode. I have used this source
https://wiki.lustre.org/PFL2_High_Level_Design to interpret the layout in
which the extended attributes are stored.


For the Lustre image we are using, there are 605 inodes out of which 253
have extended attributes. The count of lma is also 253, which is correct.
However the only 22 inodes seem to have linkEA attributes and 2 inodes have
lovEA attributes. The count for linkEA and lovEA is seems to be really
small compared to the count for lma.

I am wondering if there is an updated document on the layout of extended
attributes for the ldiskfs inodes.


Thanks and regards

- Saisha Kamat

--000000000000c2274305c14c34b1
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span id=3D"gmail-docs-internal-guid-f49b40a4-7fff-1bb1-77=
c1-e72fb3e8dcc7"><p dir=3D"ltr" style=3D"line-height:1.656;margin-top:0pt;m=
argin-bottom:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:rgb=
(0,0,0);background-color:transparent;font-variant-numeric:normal;font-varia=
nt-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">Hello,</=
span></p><p dir=3D"ltr" style=3D"line-height:1.656;margin-top:0pt;margin-bo=
ttom:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);=
background-color:transparent;font-variant-numeric:normal;font-variant-east-=
asian:normal;vertical-align:baseline;white-space:pre-wrap"><br></span></p><=
p dir=3D"ltr" style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt">=
<span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background=
-color:transparent;font-variant-numeric:normal;font-variant-east-asian:norm=
al;vertical-align:baseline;white-space:pre-wrap">I am a Ph.D student at UNC=
C and our team is working on the Lustre filesystem. I am reading extended a=
ttributes of the ldiskfs for every inode. I have used this source </span><a=
 href=3D"https://wiki.lustre.org/PFL2_High_Level_Design" style=3D"text-deco=
ration-line:none"><span style=3D"font-size:11pt;font-family:Arial;backgroun=
d-color:transparent;font-variant-numeric:normal;font-variant-east-asian:nor=
mal;text-decoration-line:underline;vertical-align:baseline;white-space:pre-=
wrap">https://wiki.lustre.org/PFL2_High_Level_Design</span></a><span style=
=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:tran=
sparent;font-variant-numeric:normal;font-variant-east-asian:normal;vertical=
-align:baseline;white-space:pre-wrap"> to interpret the layout in which the=
 extended attributes are stored.=C2=A0</span></p><p dir=3D"ltr" style=3D"li=
ne-height:1.656;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:=
11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;font-v=
ariant-numeric:normal;font-variant-east-asian:normal;vertical-align:baselin=
e;white-space:pre-wrap"><br></span></p><p dir=3D"ltr" style=3D"line-height:=
1.656;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;font-=
family:Arial;color:rgb(0,0,0);background-color:transparent;font-variant-num=
eric:normal;font-variant-east-asian:normal;vertical-align:baseline;white-sp=
ace:pre-wrap">For the Lustre image we are using, there are 605 inodes out o=
f which 253 have extended attributes. The count of lma is also 253, which i=
s correct. However the only 22 inodes seem to have linkEA attributes and 2 =
inodes have lovEA attributes. The count for linkEA and lovEA is seems to be=
 really small compared to the count for lma.</span></p><p dir=3D"ltr" style=
=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span style=3D"font=
-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;=
font-variant-numeric:normal;font-variant-east-asian:normal;vertical-align:b=
aseline;white-space:pre-wrap">I am wondering if there is an updated documen=
t on the layout of extended attributes for the ldiskfs inodes.</span></p><p=
 dir=3D"ltr" style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><=
span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-=
color:transparent;font-variant-numeric:normal;font-variant-east-asian:norma=
l;vertical-align:baseline;white-space:pre-wrap"><br></span></p><p style=3D"=
line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-siz=
e:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;font=
-variant-numeric:normal;font-variant-east-asian:normal;vertical-align:basel=
ine;white-space:pre-wrap">Thanks and regards</span></p><p style=3D"line-hei=
ght:1.656;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;f=
ont-family:Arial;color:rgb(0,0,0);background-color:transparent;font-variant=
-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;whit=
e-space:pre-wrap">- Saisha Kamat</span></p><br></span></div>

--000000000000c2274305c14c34b1--

--===============7627152796473210394==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7627152796473210394==--
