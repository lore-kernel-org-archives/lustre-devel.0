Return-Path: <SRS0=DIbX=HB=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 198E7C433E0
	for <lustre-devel@archiver.kernel.org>; Sat, 30 Jan 2021 17:08:01 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C05B664E13
	for <lustre-devel@archiver.kernel.org>; Sat, 30 Jan 2021 17:08:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C05B664E13
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 45EAF21F81B;
	Sat, 30 Jan 2021 09:08:00 -0800 (PST)
Received: from mail-wr1-f42.google.com (mail-wr1-f42.google.com
 [209.85.221.42])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2540C21C9EA
 for <lustre-devel@lists.lustre.org>; Sat, 30 Jan 2021 09:07:59 -0800 (PST)
Received: by mail-wr1-f42.google.com with SMTP id a1so12066645wrq.6
 for <lustre-devel@lists.lustre.org>; Sat, 30 Jan 2021 09:07:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=FsJvj8mqeNkzSsJ1/lNbbSFlpfO+N845+J/44Xj6cG0=;
 b=f5HtPrdKqgUnVrEnoTXo76RqXaO4ftyuuvO5r6r8XlChohDrH3iGdl8nCl5Pp8iwZ3
 BXjCTIG4+WA948Y3Hum+R6hx+q0JsErR96A/Yo7h0djg/LzrFfH/3k28WM3UqYENs3xg
 0nEg2xCh9jaLIBpUKOZNbTot2b6ZsXGsx6HQbw1sLoFzJKBoUT33A8rovu7ukaHutr5S
 0OE9QnCvb8se9u1nsApLAcxHrGz/2GDh6tZW0beKlx7B0xnmWb5LRtRu3l4SFEpMxAh9
 PyvMoIR4ao60SgaP1Aau9nzLn00la+JxM060UhdJdaCBWC0mi2Nx69/GONltfFJFvIio
 BSzg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=FsJvj8mqeNkzSsJ1/lNbbSFlpfO+N845+J/44Xj6cG0=;
 b=Qb+jkICbmdXfmLA7rYqwtrbcQGaFltN0Bdi/9qYHtU3PqXHmnF7ITo21GlYggw/vHq
 VP83Whe1MciVNl37+2KlJUnVrYu+lMOazeHqLr9I5lrvjO4eIwuF4X6MoVR+Df288aWS
 K75oL11+KFT/SrrIvlw1XPVC+BWybfSdGvNKw5GuLCTFknNhzrbnDgKXW2yQ7TTeD0yB
 YxNFFut52xNhFBDRAVQnAYFHE2P64858MBA4SpcHdIb3hdKeAf4YLLPj39ASj8xTqNkG
 O6fP45vqAQHL55phvwk2LQddTS+LDJoyk/KvljLfIMFHDpd6Z90ubM61IoZvmT89DtW7
 XsnA==
X-Gm-Message-State: AOAM531dhvQGVK40LH4k3IAG4jVPwaImOw4RcGyX46CDwVaz1sqkC8o0
 CRmqVqfnSh6OI+FH1j20pH1qNoIZ933kpnxK4+E=
X-Google-Smtp-Source: ABdhPJwIywyNGojrrWN3KjgegZq6zCGmfqmGGdL8GO6MYBdAmO+MMJ8Y0D8l3/Cn9KLCp65H8Z2oJrNfjp+mIlC9DLE=
X-Received: by 2002:a5d:5051:: with SMTP id h17mr10683124wrt.164.1612026477989; 
 Sat, 30 Jan 2021 09:07:57 -0800 (PST)
MIME-Version: 1.0
References: <CABnqofzHf0GdzqiXebSzbkDHHoGwxoAyCnja7_=YqWGVOnn7jA@mail.gmail.com>
 <2BA3D230-5DA3-4323-A7F0-2CAA21E7782F@amazon.com>
In-Reply-To: <2BA3D230-5DA3-4323-A7F0-2CAA21E7782F@amazon.com>
From: Sudheendra Sampath <sudheendra.sampath@gmail.com>
Date: Sat, 30 Jan 2021 09:07:21 -0800
Message-ID: <CABnqofyAXbb1nwkerUDAB8cdpY+ieQDoQ6MOH77mJk_0cKbbiw@mail.gmail.com>
To: "Degremont, Aurelien" <degremoa@amazon.com>
Subject: Re: [lustre-devel] Lustre log question(s)
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============0153483710920954298=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0153483710920954298==
Content-Type: multipart/alternative; boundary="00000000000096d30605ba212920"

--00000000000096d30605ba212920
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Thank you for the explanation on LLOG and changelog.  With respect to the
following statement :

*>> Lustre has its own mechanisms to guarantee transaction are committed to
disk and handle crash. Basicly, I/O are not acknowledge to Lustre clients
before the data is actually on disk. In case of server crash, the Lustre
client will replay all non-acknowledge I/Os to ensure none of them are
lost.*

For example:

Let us say that I have 4 clients (cli1, cli2, cli3 and cli4) and all are
writing and reading data.  I have 1 host with 4 disks (2 OSTs, 1 MDT, 1
MGT).

   1. cli1 issues a directory remove (rm -rf /mnt/lustre/dir1)
   2. cli1 loses connection with Lustre targets.
   3. cli2 wants to now create a file under /mnt/lustre/dir1/file100 and
   write some data to file100

All of these are happening in parallel.

   - Does cli2 get an error that /mnt/lustre/dir1 has been removed and it
   has to first issue additional I/O to create /mnt/lustre/dir1 before
   reissuing the I/O to write file100 ?
   - If a transaction from cli2 happens before cli1, then this would lead
   to data lost situation for cli2, if cli2 tries to read/write data from/t=
o
   file100 after sometime.
   - What is the role of last_rcvd file in this entire picture ?

I am trying to get a 30,000 ft overview of how lustre replay/recovery works=
.

Thanks again and appreciate your timely response.

On Fri, Jan 29, 2021 at 1:22 AM Degremont, Aurelien <degremoa@amazon.com>
wrote:

> Hi,
>
>
>
> This is not totally correct.
>
>
>
> First, LLOG is the underlying technology used to store and handle Lustre
> Changelogs. But LLOG is used for other Lustre mechanisms, like lustre
> configuration.
>
> Second, Changelog is similar to an audit feature. Changelog only logs
> different filesystem change, mostly metadata change, but definitely not t=
he
> file content change. They don't play a role at all in transaction or
> failure recovery. This is only an admin feature.
>
>
>
> At the end, indeed ZIL cannot be used and Lustre has its own mechanisms t=
o
> guarantee transaction are committed to disk and handle crash. Basicly, I/=
O
> are not acknowledge to Lustre clients before the data is actually on disk=
.
> In case of server crash, the Lustre client will replay all non-acknowledg=
e
> I/Os to ensure none of them are lost.
>
>
>
> Changelog is not needed in your case.
>
>
>
> Aur=C3=A9lien
>
>
>
> *De : *lustre-devel <lustre-devel-bounces@lists.lustre.org> au nom de
> Sudheendra Sampath <sudheendra.sampath@gmail.com>
> *Date : *jeudi 28 janvier 2021 =C3=A0 21:43
> *=C3=80 : *"lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org=
>
> *Objet : *[EXTERNAL] [lustre-devel] Lustre log question(s)
>
>
>
> *CAUTION*: This email originated from outside of the organization. Do not
> click links or open attachments unless you can confirm the sender and kno=
w
> the content is safe.
>
>
>
> Hi,
>
>
>
> I am trying to evaluate osd-zfs based MDS and OST deployment on a 2 node
> setup.
>
>
>
> I have the following questions about Lustre log:
>
> 1.       *Is changelog and llog both the same, in the sense are they
> synonymous with each other?*
>
> 2.       I understand that ZIL is currently not supported in Lustre
> version 2.12.2.  My question is :
>
> 1.       My understanding is that transactions (in general) need some
> logging mechanism for it to work in 'all or none' scenarios.  Please
> correct me if my understanding is incorrect.   I understand that changelo=
g
> has to be enabled so that filesystem changes are recorded to be replayed
> after a crash.  *How does Lustre transactions work if there is no intent
> log/changelog ?*
>
> 2.       Does it mean that if changelog is NOT enabled and there is a
> crash, we risk losing all changes/updates to the filesystem ?
>
> Appreciate your timely response and Thank you for your help.
>
>
>
> --
>
> Regards
>
> Sudheendra Sampath
>


--=20
Regards

Sudheendra Sampath

--00000000000096d30605ba212920
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Thank you for the explanation on LLOG and changelog.=C2=A0=
 With respect to the following statement :<div><br></div><div><b>&gt;&gt; L=
ustre has its own mechanisms to guarantee transaction are committed to disk=
 and handle crash. Basicly, I/O are not acknowledge to Lustre clients befor=
e the data is actually on disk. In case of server crash, the Lustre client =
will replay all non-acknowledge I/Os to ensure none of them are lost.</b></=
div><div><br></div><div>For example:</div><div><br></div><div>Let us say th=
at I have 4 clients (cli1, cli2, cli3 and cli4) and all are writing and rea=
ding data.=C2=A0 I have 1 host with 4 disks (2 OSTs, 1 MDT, 1 MGT).=C2=A0</=
div><div><ol><li>cli1 issues a directory remove (rm -rf /mnt/lustre/dir1)</=
li><li>cli1 loses connection with Lustre targets.</li><li>cli2 wants to now=
 create a file under /mnt/lustre/dir1/file100 and write some data to file10=
0</li></ol><div>All of these are happening in parallel.=C2=A0</div><div><ul=
><li>Does cli2 get an error that /mnt/lustre/dir1 has been removed and it h=
as to first issue additional I/O to create /mnt/lustre/dir1 before reissuin=
g the I/O to write file100 ?</li><li>If a transaction from cli2 happens bef=
ore cli1, then this would lead to data lost situation for cli2, if cli2 tri=
es to read/write data from/to file100 after sometime.</li><li>What is the r=
ole of last_rcvd file in this entire picture ?</li></ul></div></div><div><d=
iv><div>I am trying to get a 30,000 ft overview of how lustre replay/recove=
ry works.</div></div></div><div><br></div><div>Thanks again and appreciate =
your timely response.</div></div><br><div class=3D"gmail_quote"><div dir=3D=
"ltr" class=3D"gmail_attr">On Fri, Jan 29, 2021 at 1:22 AM Degremont, Aurel=
ien &lt;<a href=3D"mailto:degremoa@amazon.com">degremoa@amazon.com</a>&gt; =
wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0=
px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">





<div lang=3D"FR" style=3D"overflow-wrap: break-word;">
<div class=3D"gmail-m_-4964076887753855651WordSection1">
<p class=3D"MsoNormal"><span lang=3D"EN-US">Hi,<u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><u></u>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">This is not totally correct.<u>=
</u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><u></u>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">First, LLOG is the underlying t=
echnology used to store and handle Lustre Changelogs. But LLOG is used for =
other Lustre mechanisms, like lustre configuration.<u></u><u></u></span></p=
>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Second, Changelog is similar to=
 an audit feature. Changelog only logs different filesystem change, mostly =
metadata change, but definitely not the file content change. They don&#39;t=
 play
 a role at all in transaction or failure recovery. This is only an admin fe=
ature.<u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><u></u>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">At the end, indeed ZIL cannot b=
e used and Lustre has its own mechanisms to guarantee transaction are commi=
tted to disk and handle crash. Basicly, I/O are not acknowledge to Lustre c=
lients
 before the data is actually on disk. In case of server crash, the Lustre c=
lient will replay all non-acknowledge I/Os to ensure none of them are lost.=
<u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><u></u>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Changelog is not needed in your=
 case.<u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><u></u>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Aur=C3=A9lien<u></u><u></u></sp=
an></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><u></u>=C2=A0<u></u></span></p>
<div style=3D"border-right:none;border-bottom:none;border-left:none;border-=
top:1pt solid rgb(181,196,223);padding:3pt 0cm 0cm">
<p class=3D"MsoNormal" style=3D"margin-left:35.4pt"><b><span style=3D"font-=
size:12pt;color:black">De=C2=A0:
</span></b><span style=3D"font-size:12pt;color:black">lustre-devel &lt;<a h=
ref=3D"mailto:lustre-devel-bounces@lists.lustre.org" target=3D"_blank">lust=
re-devel-bounces@lists.lustre.org</a>&gt; au nom de Sudheendra Sampath &lt;=
<a href=3D"mailto:sudheendra.sampath@gmail.com" target=3D"_blank">sudheendr=
a.sampath@gmail.com</a>&gt;<br>
<b>Date=C2=A0: </b>jeudi 28 janvier 2021 =C3=A0 21:43<br>
<b>=C3=80=C2=A0: </b>&quot;<a href=3D"mailto:lustre-devel@lists.lustre.org"=
 target=3D"_blank">lustre-devel@lists.lustre.org</a>&quot; &lt;<a href=3D"m=
ailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-devel@lists.l=
ustre.org</a>&gt;<br>
<b>Objet=C2=A0: </b>[EXTERNAL] [lustre-devel] Lustre log question(s)<u></u>=
<u></u></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:35.4pt"><u></u>=C2=A0<u></u></p=
>
</div>
<div>
<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0" width=3D"625" style=
=3D"width:468.8pt;margin-left:35.4pt;border-collapse:collapse">
<tbody>
<tr style=3D"height:15.25pt">
<td width=3D"625" valign=3D"top" style=3D"width:468.8pt;border:1.5pt solid =
rgb(237,125,49);padding:0cm 5.4pt;height:15.25pt">
<p><strong><span style=3D"font-family:Calibri,sans-serif;color:black;backgr=
ound:rgb(255,255,153)">CAUTION</span></strong><span style=3D"color:black;ba=
ckground:rgb(255,255,153)">: This email originated from outside of the orga=
nization. Do not click links or open attachments unless
 you can confirm the sender and know the content is safe.</span><u></u><u><=
/u></p>
</td>
</tr>
</tbody>
</table>
</div>
<p class=3D"MsoNormal" style=3D"margin-left:35.4pt"><u></u>=C2=A0<u></u></p=
>
<div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:35.4pt">Hi, <u></u><u></u></p>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:35.4pt"><u></u>=C2=A0<u></u></p=
>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:35.4pt">I am trying to evaluate=
 osd-zfs based MDS and OST deployment on a 2 node setup.<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:35.4pt"><u></u>=C2=A0<u></u></p=
>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:35.4pt">I have the following qu=
estions about Lustre log:<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:71.4pt">
<u></u><span>1.<span style=3D"font:7pt &quot;Times New Roman&quot;">=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0
</span></span><u></u><b>Is changelog and llog both the same, in the sense a=
re they synonymous with each other?</b><u></u><u></u></p>
<p class=3D"MsoNormal" style=3D"margin-left:71.4pt">
<u></u><span>2.<span style=3D"font:7pt &quot;Times New Roman&quot;">=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0
</span></span><u></u>I understand that ZIL is currently not supported in Lu=
stre version 2.12.2.=C2=A0 My question is :=C2=A0=C2=A0
<u></u><u></u></p>
<p class=3D"MsoNormal" style=3D"margin-left:107.4pt">
<u></u><span>1.<span style=3D"font:7pt &quot;Times New Roman&quot;">=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0
</span></span><u></u>My understanding is that transactions (in general) nee=
d some logging mechanism for it to work in &#39;all or none&#39; scenarios.=
=C2=A0 Please correct me if my understanding is incorrect.=C2=A0 =C2=A0I un=
derstand that changelog has to be enabled so that filesystem
 changes are recorded to be replayed after a crash.=C2=A0 <b>How does Lustr=
e transactions work if there is no intent log/changelog ?</b><u></u><u></u>=
</p>
<p class=3D"MsoNormal" style=3D"margin-left:107.4pt">
<u></u><span>2.<span style=3D"font:7pt &quot;Times New Roman&quot;">=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0
</span></span><u></u>Does it mean that if changelog is NOT enabled and ther=
e is a crash, we risk losing all changes/updates to the filesystem ?<u></u>=
<u></u></p>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:35.4pt">Appreciate your timely =
response and Thank you for your help.<u></u><u></u></p>
</div>
</div>
<div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:35.4pt"><u></u>=C2=A0<u></u></p=
>
</div>
<p class=3D"MsoNormal" style=3D"margin-left:35.4pt">-- <u></u><u></u></p>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:35.4pt">Regards<br>
<br>
Sudheendra Sampath<u></u><u></u></p>
</div>
</div>
</div>
</div>
</div>
</div>

</blockquote></div><br clear=3D"all"><div><br></div>-- <br><div dir=3D"ltr"=
 class=3D"gmail_signature">Regards<br><br>Sudheendra Sampath</div>

--00000000000096d30605ba212920--

--===============0153483710920954298==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0153483710920954298==--
