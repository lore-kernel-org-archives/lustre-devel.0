Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 19C46D5CC91
	for <lustre-devel@archiver.kernel.org>; Thu, 31 Oct 2024 00:36:52 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Xf4nJ1R9Xz1xPX;
	Wed, 30 Oct 2024 17:36:52 -0700 (PDT)
Received: from mail-il1-f169.google.com (mail-il1-f169.google.com
 [209.85.166.169])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Xf4nC3HYKz1xFd; Wed, 30 Oct 2024 17:36:47 -0700 (PDT)
Received: by mail-il1-f169.google.com with SMTP id
 e9e14a558f8ab-3a4e5401636so1582645ab.3; 
 Wed, 30 Oct 2024 17:36:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1730335006; x=1730939806; darn=lists.lustre.org;
 h=mime-version:subject:references:in-reply-to:message-id:cc:to:from
 :date:from:to:cc:subject:date:message-id:reply-to;
 bh=0WWYuHAPCxTiRqEft7qtuCijPQTtBk7tcsireFSQwrE=;
 b=LpGWg1QMBocw3RcuEwVLMtb0dD2f0ymFgrTh4SuYWzvlH9lvZuRXKARqQ3b/zhwOK+
 KXXleW11AF3GTMLqgx/Obl82DFLuivSJt+hu8EW/SlmOPU1d9Hgeg+9lvCJIUV5qPonN
 4sXHZVdkEMUE6XXIK7IuBxn10k90Ui0FskZ0kEEsAbW3uBcgnPqoeoaub8I7eAhFl9Cf
 gsO33BIgCfUzrd6MVh7tkvmJk9uBjEtrb2ziRLWDVOYz7/B9EC2OhW5pdyx7g92W9lFG
 9WohK6SOPRwrgKdNsaYp7ToOFEu9D9Ffl0lmvDk/lqkMgq+xXWI4RAFxViEfPLtZaBD6
 8YQw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1730335006; x=1730939806;
 h=mime-version:subject:references:in-reply-to:message-id:cc:to:from
 :date:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=0WWYuHAPCxTiRqEft7qtuCijPQTtBk7tcsireFSQwrE=;
 b=WMYDhPELKL5OWms8dbGKWCvKB7CXniefgeb9c6Qicj7UA8PGioWcufmSUGSTlE55cb
 vzVlRnB6EKqgkSZchMVrGihZ6oPVdviGnvrZI/V1HongGfs+jV0RdD+LkDA6QWNK6awQ
 LrS3TfnAEot1Ew1+MUrfAF3kZ0AnNP+BlsjVh0G7V2eqwK15KNCXkoaeCAtdGja6l7JK
 B4xs/R8cIMxMdH7RMst6UWALudI1K8FBdRRU/BQYz+15UlHEzzMy2gCs9ouZ44Wq/NY2
 I9wNITvY9JhbmGiaQPYodLuy1RNK7TQYchsy+jPmCDKWrv4HOKvMZdkUwM8Ax0u06PbM
 UPqw==
X-Forwarded-Encrypted: i=1;
 AJvYcCWeHh+4oWiauG+hCi5JQrxurqZmoSPF4rtur1U2VQc33a/hp98O3e73AqMV6H61j2DzuaCtzADhVInqad9WnQ==@lists.lustre.org
X-Gm-Message-State: AOJu0YwvxBasNWFN71RLD+Gy/5sPCBYt1bnLSQgA2sQlBCKi8e3W7qfT
 ccrEP/+UvkpYdMYb9MkMZKgk8Ltc2Nv35x4XyvG/beaY1sYgzeCe
X-Google-Smtp-Source: AGHT+IHIS1/khScKgP+I5QfEATarAtVicCGBjCyak2Ss1fD+iNMWpcrBqEhTqelF4q/UjhqguwmUYg==
X-Received: by 2002:a05:6e02:1a22:b0:3a0:bd91:3842 with SMTP id
 e9e14a558f8ab-3a4ed3628d7mr162361335ab.24.1730335006344; 
 Wed, 30 Oct 2024 17:36:46 -0700 (PDT)
Received: from [192.168.86.58] (97-115-66-118.ptld.qwest.net. [97.115.66.118])
 by smtp.gmail.com with ESMTPSA id
 41be03b00d2f7-7ee455a74e1sm189843a12.48.2024.10.30.17.36.45
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Wed, 30 Oct 2024 17:36:45 -0700 (PDT)
Date: Wed, 30 Oct 2024 17:36:36 -0700
From: Nathan Rutman <nrutman@gmail.com>
To: Andreas Dilger <adilger@ddn.com>
Cc: "=?utf-8?Q?lustre-devel=40lists.lustre.org?="
 <lustre-devel@lists.lustre.org>, 
 "=?utf-8?Q?lustre-discuss=40lists.lustre.org?="
 <lustre-discuss@lists.lustre.org>
Message-ID: <8119cc42-97a0-4780-9235-ec73d6c01241@Spark>
In-Reply-To: <F5B513AE-FD55-40FF-A28A-0CC4BBE00F1B@ddn.com>
References: <8c491303-89e9-439e-a39b-0cab2dbd8e66@Spark>
 <250f2f80-76dc-4f59-92c7-fc5e4465b753@Spark>
 <F5B513AE-FD55-40FF-A28A-0CC4BBE00F1B@ddn.com>
X-Readdle-Message-ID: 8119cc42-97a0-4780-9235-ec73d6c01241@Spark
MIME-Version: 1.0
Subject: Re: [lustre-devel] Stripe visualization tool
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
Content-Type: multipart/mixed; boundary="===============8358769722761898015=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8358769722761898015==
Content-Type: multipart/alternative; boundary="6722d11a_31fede0a_2520"

--6722d11a_31fede0a_2520
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Sorry, added to the docs, hopefully this would do it for you:
pip install --upgrade numpy matplotlib seaborn yaml scipy
On Oct 29, 2024 at 8:16 PM -0700, Andreas Dilger <adilger=40ddn.com>, wro=
te:
> Nathan,
> I had a try at using this, but it seems to have a number of external de=
pendencies. =C2=A0 I installed the python3-pyyaml and python3-matplotlib,=
 but I couldn't figure out what package =22seaborn=22 is part of=3F =C2=A0=
=22yum search seaborn=22 doesn't find anything on my el8 system, nor does=
 =22rpmfind=22 return any packages for this.
>
> It would be good to include a description of the package requirements i=
nto the README.md file.
>
> It looks like =22sns=22 is only used for picking colors, so the utility=
 would be more easily used if a more standard mechanism was doing this=3F=
 =C2=A0While not as pretty, I expect just picking colors by a 3-byte hash=
 of the component ID and stripe index would get you something usable if =22=
seaborn=22 was not installed, or a hash of the object ID, or similar=3F
>
> Cheers, Andreas
>
> > On Oct 29, 2024, at 13:38, Nathan Rutman <nrutman=40gmail.com> wrote:=

> >
> > In the =46WIW category, I've got a tool to graphically display a file=
's striping pattern for arbitrary Lustre files. It takes in the yaml from=
 =22getstripe -y=22 and will generate a jpeg. Handles DoM, P=46L, overstr=
iping, mirroring, pools. Available at=C2=A0https://github.com/HewlettPack=
ard/lustre-stripe-plotter
> >
> >
> > Example of mirrored DoM P=46L file:
> > <Attachment.jpeg>
> > =5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F
> > lustre-devel mailing list
> > lustre-devel=40lists.lustre.org
> > http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
> Cheers, Andreas
> =E2=80=94
> Andreas Dilger
> Lustre Principal Architect
> Whamcloud/DDN
>
>
>
>

--6722d11a_31fede0a_2520
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<html xmlns=3D=22http://www.w3.org/1999/xhtml=22>
<head>
<title></title>
</head>
<body>
<div name=3D=22messageBodySection=22>
<div dir=3D=22auto=22><span style=3D=22font-family:S=46 Pro=22>Sorry, add=
ed to the docs, hopefully this would do it for you:</span><span style=3D=22=
font-size: 13.6px=22><br /></span><span style=3D=22color:=231f2328;backgr=
ound-color:rgba(129, 139, 152, 0.12);font-family:ui-monospace, S=46Mono-R=
egular, S=46 Mono, Menlo, Consolas, Liberation Mono, monospace;font-size:=
 13.6px=22>pip install --upgrade numpy matplotlib seaborn yaml scipy</spa=
n></div>
</div>
<div name=3D=22messageReplySection=22>On Oct 29, 2024 at 8:16 PM -0700, A=
ndreas Dilger &lt;adilger=40ddn.com&gt;, wrote:<br />
<blockquote type=3D=22cite=22 style=3D=22border-left-color: grey; border-=
left-width: thin; border-left-style: solid; margin: 5px 5px;padding-left:=
 10px;=22>Nathan,
<div>I had a try at using this, but it seems to have a number of external=
 dependencies. &=23160; I installed the python3-pyyaml and python3-matplo=
tlib, but I couldn't figure out what package =22seaborn=22 is part of=3F =
&=23160;=22yum search seaborn=22 doesn't find anything on my el8 system, =
nor does =22rpmfind=22 return any packages for this.&=23160;</div>
<div><br /></div>
<div>It would be good to include a description of the package requirement=
s into the README.md file.&=23160;</div>
<div><br /></div>
<div><span style=3D=22caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0);=22>=
It looks like =22sns=22 is only used for picking colors, so the utility w=
ould be more easily used if a more standard mechanism was doing this=3F &=
=23160;While not as pretty, I expect just picking colors by a 3-byte hash=
 of the component ID and stripe index would get you something usable if =22=
seaborn=22 was not installed, or a hash of the object ID, or similar=3F</=
span></div>
<div><font color=3D=22=23000000=22><span style=3D=22caret-color: rgb(0, 0=
, 0);=22><br /></span></font></div>
<div><font color=3D=22=23000000=22><span style=3D=22caret-color: rgb(0, 0=
, 0);=22>Cheers, Andreas<br id=3D=22lineBreakAtBeginningOfMessage=22 /></=
span></font>
<div><br />
<blockquote type=3D=22cite=22>
<div>On Oct 29, 2024, at 13:38, Nathan Rutman &lt;nrutman=40gmail.com&gt;=
 wrote:</div>
<br class=3D=22Apple-interchange-newline=22 />
<div>
<div>
<div name=3D=22messageBodySection=22>
<div dir=3D=22auto=22>In the =46WIW category, I've got a tool to graphica=
lly display a file's striping pattern for arbitrary Lustre files. It take=
s in the yaml from =22getstripe -y=22 and will generate a jpeg. Handles D=
oM, P=46L, overstriping, mirroring, pools. Available at&=23160;<a href=3D=
=22https://github.com/HewlettPackard/lustre-stripe-plotter=22 target=3D=22=
=5Fblank=22>https://github.com/HewlettPackard/lustre-stripe-plotter</a><s=
pan style=3D=22font-size: 16px=22><br /></span> <span style=3D=22font-siz=
e: 16px=22><br /></span> <span style=3D=22font-size: 16px=22><br /></span=
> <span style=3D=22color:=231f2328;font-family:-apple-system, system-ui, =
Segoe UI, Noto Sans, Helvetica, Arial, sans-serif, Apple Color Emoji, Seg=
oe UI Emoji;font-size: 16px=22>Example of mirrored DoM P=46L file:</span>=
<span style=3D=22font-size: 16px=22><br /></span> <span id=3D=22cid:D8E0A=
A=4621B7746BEA216C2150A875126=22>&lt;Attachment.jpeg&gt;</span></div>
</div>
</div>
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F<br />
lustre-devel mailing list<br />
lustre-devel=40lists.lustre.org<br />
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org<br /></div>
</blockquote>
</div>
<br />
<div>
<div dir=3D=22auto=22 style=3D=22caret-color: rgb(0, 0, 0); color: rgb(0,=
 0, 0); letter-spacing: normal; text-align: start; text-indent: 0px; text=
-transform: none; white-space: normal; word-spacing: 0px; -webkit-text-st=
roke-width: 0px; text-decoration: none; overflow-wrap: break-word; -webki=
t-nbsp-mode: space; line-break: after-white-space;=22>
<div dir=3D=22auto=22 style=3D=22caret-color: rgb(0, 0, 0); color: rgb(0,=
 0, 0); letter-spacing: normal; text-align: start; text-indent: 0px; text=
-transform: none; white-space: normal; word-spacing: 0px; -webkit-text-st=
roke-width: 0px; text-decoration: none; overflow-wrap: break-word; -webki=
t-nbsp-mode: space; line-break: after-white-space;=22>
<div>Cheers, Andreas</div>
<div>=E2=80=94</div>
<div>Andreas Dilger</div>
<div>Lustre Principal Architect</div>
<div>Whamcloud/DDN</div>
</div>
<br class=3D=22Apple-interchange-newline=22 /></div>
<br class=3D=22Apple-interchange-newline=22 />
<br class=3D=22Apple-interchange-newline=22 /></div>
<br /></div>
</blockquote>
</div>
</body>
</html>

--6722d11a_31fede0a_2520--


--===============8358769722761898015==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8358769722761898015==--

