Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0A50FCCFA04
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 17:38:59 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1G0L0wgnz1y6Q;
	Tue, 04 Nov 2025 09:38:58 -0800 (PST)
Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com
 [209.85.210.50])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1G0H6QB8z1y25
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 09:38:55 -0800 (PST)
Received: by mail-ot1-f50.google.com with SMTP id
 46e09a7af769-7c2816c0495so3793058a34.3
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 09:38:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=google.com; s=20230601; t=1762277935; x=1762882735; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=sDB07DO43S3R6agv3Z6rJQS8DgpTTYsiMNu67YrEDgM=;
 b=wP4QaqGOn7oFARJpJlHMhzNIKgUbKMlDe+qWceqEjI29tQlJsjL8v+VOWybKTY858w
 KDMwIPqPYy9ho2njhghly/4Xl73Y83j1XVMIUC37bW3qlt7zsqjvaupysf3x/125P14O
 jSazG8tGBdVOryg6PBkUbVIfxXocJ1Uz0wniqPSa0GLSX3f2hztULsPn7AG0+kGXbvdN
 cvk+4mLsPFwTGpLiecO6Ldeby0HPLQWTJ2KwjvYUB3wxd9k4/nHNKx5Tdi34PtE4bHOI
 LM6dZJ1KyN+Uo1nz+O2aisqPPuZk+N5sPz3sb6OGW+pRb1AycVRz9iecoBNY0ebiUmqo
 Ch1w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762277935; x=1762882735;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=sDB07DO43S3R6agv3Z6rJQS8DgpTTYsiMNu67YrEDgM=;
 b=gXxTASH5k4lv/1Ik3WsRC78OfLleZ+jRuOJDDyIrVUukENNlkpkwhjaecXMfq+I/go
 VWrxTmouTVc24+TSso7ZEQavfKor461fDpKbfbg6KOKFIbyW/8m8yjBmMcZ96QvaUldx
 L0jC94vw/TVh8nqm08IrYPoiABIfxHRQHre94u4XWDRKKEh+8NACxk/rJM1ZY4f3qx87
 t7iNU8fOBzzeKd6sudSMtGIBvMdgsPvcC2VgHtOfRmzeVujvcjgsD8d1DY3ZEQ1MJKP1
 2ozOmP83//HpiF5wdOu1POAANAo6THdTA9oxID6bxbFQ+gZrxD64IZ2XiSO97pHmBnk2
 t7HQ==
X-Gm-Message-State: AOJu0Yxs+wDb1usjmxYpkFlO8nkjug7LRaZyq0FpEXBcuzoevE/dk2j9
 mJ9ZXGPEYLKFqjDJQVLmUjB02Z3loEnLkVv/27gx8DYa686YV2baoVkGzhyNdQ2UXlHZm67a0ex
 3H806BQhlHqv44SheInGu5fFICTomhcJefOXwDXnE2NuzqesP6geyx7xw
X-Gm-Gg: ASbGncuHD67INTrGNNlXEsIfAnnmAlRHvgj5wGrOgttnT9hYDBRJkxF1jvTgYZOEBAF
 IaXz0RgXYtnopwHAs83ZEp/4uwwihDKtmBJLJIvYnS+K9vnoMlhEM4L5u3e7k407fcAeIgSdZq1
 Gb+eYQnY3AnVlR33VVUgr9O3ZLH3XrvuRjxE2KK5I6qulPTj3lPIdPMp0CGCU3vkmT0GmdkrLSd
 1i8VKpkJuzB8KiRUsOQt9GN5r0k0nLS9FZw2DO0UVFxTUnRgBiUyzXq6WrOOTOZJn+0c8LSpnco
 ZCVhkhdmGsJ87BoQ0TfSb3gXoi0Ba66WPY7Y569+Ml5S8cv7lA==
X-Google-Smtp-Source: AGHT+IFEK4f7NsWr6mbfIlovYTSWH46onOrJTf74EBHbYgLjZ/ZN/p9oRtNCDhlh/fsyW9wF/Q8FzJWNz+ohmU+jwfk=
X-Received: by 2002:a05:6808:2386:b0:44f:6a32:537a with SMTP id
 5614622812f47-44fed4f857amr111211b6e.46.1762277934774; Tue, 04 Nov 2025
 09:38:54 -0800 (PST)
MIME-Version: 1.0
References: <e2c69a503e80f3ba59d69f093bc8df519cdd7f66.camel@whamcloud.com>
 <BFDDAAED-BA9A-44DB-BCD0-B3B84E652FE7@gmail.com>
 <c6c016567a02f857303eedb9a4af6b5831c2c818.camel@whamcloud.com>
 <CAEp8vpiZ8iKRbjy8GYKdXFjsycW=a48baOXxUnSP7uE+Xf5cYw@mail.gmail.com>
 <e31f82d56f034cb325ae29a08280122711078a97.camel@whamcloud.com>
 <DM6PR19MB263631D5057975AB09DB7F60C9C4A@DM6PR19MB2636.namprd19.prod.outlook.com>
In-Reply-To: <DM6PR19MB263631D5057975AB09DB7F60C9C4A@DM6PR19MB2636.namprd19.prod.outlook.com>
Date: Tue, 4 Nov 2025 09:38:43 -0800
X-Gm-Features: AWmQ_bn65H4tKWgW0PrZDJq5AJr0wyCH9r1-gMrT2DD2f6YJJdZJOV3Meti-5k8
Message-ID: <CAEp8vpi_VWA9EXJjED73MmJCMwp-zzi_h+7taB8uohExJY0tdQ@mail.gmail.com>
To: Patrick Farrell <pfarrell@ddn.com>
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
Cc: Oleg Drokin via lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============3025467022378385101=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3025467022378385101==
Content-Type: multipart/alternative; boundary="0000000000004cea750642c84e66"

--0000000000004cea750642c84e66
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 3, 2025 at 6:47=E2=80=AFPM Patrick Farrell <pfarrell@ddn.com> w=
rote:

> I haven=E2=80=99t seen any mention of failover yet in this conversation (=
may have
> missed it), but if the device is truly local, then in failed over
> configurations the data is inaccessible.  If it=E2=80=99s *not* local, wh=
y not just
> make the device part of the OST or an independent OST?
>

It won't be local. Actually, this is designed for the cloud.

We already have tiered storage based on mirroring; however, that still
requires clients to move data and a file system level scanner to decide
which files move to the cold tier. It's cumbersome to maintain those
clients.



>
>

>
> Or even if it is local only - it could be made an OST
> ------------------------------
> *From:* lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of
> Oleg Drokin via lustre-devel <lustre-devel@lists.lustre.org>
> *Sent:* Monday, November 3, 2025 7:58 PM
> *To:* jinshanx@google.com <jinshanx@google.com>
> *Cc:* lustre-devel@lists.lustre.org <lustre-devel@lists.lustre.org>
> *Subject:* Re: [lustre-devel] RFC: Spill device for Lustre OSD
>
> On Mon, 2025-11-03 at 16:33 -0800, Jinshan Xiong wrote:
> > > > >
> > > > > I am not sure it's a much better idea than the already existing
> > > > > HSM
> > > > > capabilities we have that would allow you to have "offline"
> > > > > objects
> > > > > that would be pulled back in when used, but are otherwise just
> > > > > visible
> > > > > in the metadata only.
> > > > > The underlying capabilities are pretty rich esp. if we also
> > > > > take
> > > > > into
> > > > > account the eventual WBC stuff.
> > > >
> > > > The major problem of current HSM is that it has to have dedicated
> > > > clients to move data. Also, scanning the entire Lustre file
> > > > system
> > >
> > > This (dedicated client) is an implementation detail. It could be
> > > improved in many ways and the effort spent on this would bring
> > > great
> > > benefit to everyone?
> >
> >
> > Almost all designs assume some upfront implementation. We (as the
> > Lustre team) considered running clients on OST nodes, but cloud users
> > are sensitive about their data being exposed elsewhere.
> >
> > Can you list a few improvements that come to mind?
>
> Clients between server nodes is probably one of the most obvious
> choices indeed. Considering the data already resides on those nodes, I
> am not sure I understand the concerns about "exposing" data that's
> already on those nodes. If customers are so sensitive, we support data
> encryption.
> We could also do some direct server-server migration of some sort where
> OSTs exchange data without bringing up real clients and doing copies
> from userspace. That might be desirable for other reasons for future
> functionality (e.g. various caching things people have been long
> envisioning)
>
> > >
> > > > takes very long time so it resorts to databases in order to make
> > > > correct decisions about which file should be released. By the
> > > > time,
> > > > the two system will be out of sync. That makes it practically
> > > > unusable.
> > >
> > > This again is an implementation detail, not even hardcoded
> > > anywhere.
> > > How do you plan for the OST to to know what stuff is not used
> > > without
> > > resorting to some database or scan? Now take this method and make
> > > it
> > > report "upstream" where currently HSM implementations resort to
> > > databases or scans.
> > >
> >
> > The assumption is that OST sizes are relatively small, up to 100TB.
> > Also, scanning local devices in kernel spaces is much faster. So yeah
> > there is no database in the way.
>
> I am not sure why? In general small OSTs are a relatively rare thing
> because to reach large FS sizes you would need to many of them, space
> balancing becomes a chore and so on. So relatively few do it for some
> fringe reasons (e.g. Google) . Majority of people prefer large OSTs.
>
> Also nothing stops you from doing a per-OST scan (when you do have
> small OSTs) and then kicking the results up to the acting agent to do
> something about it (or the other way around, the hsm engine can ask
> OSTs one by one (picking less busy ones or ones that have the least
> free space, or some other factor). And there's absolutely no need to
> wait out to query all OSTs, you can get results from one and work on
> the data from it while the other OSTs are still thinking (or not,
> there's absolutely no requirement to get full filesystem data before
> making any decisions).
>
> > I guess users won't have 1PB OSTs, will they?
>
> There probably are already? NASA has a known 0.5P OST configuration:
>
> https://www.nas.nasa.gov/hecc/support/kb/lustre-progressive-file-layout-(=
pfl)-with-ssd-and-hdd-pools_680.html#:~:text=3DThe%20available%20SSD%20spac=
e%20in%20each%20filesystem,decimal%20(far%20right)%20labels%20of%20each%20O=
ST
> .
>
> > > Rereading your proposal, I see that this particular detail is not
> > > covered and it's just assumed that "infrequently accessed data"
> > > would
> > > be somehow known.
> >
> > I should have mentioned that in the migration section. Also, we need
> > to slightly update the OST read to use a local transaction to update
> > an object's access time (atime) if it's older than a predefined
> > threshold, for example, 10 minutes.
>
> This is going to be fragile in the face of varying clock times on
> different clients potentially not synced with the servers.
> Also in the face of -o noatime.
>
> But yes, I guess it's one way to get this "on the cheap", and the other
> trouble I foresee is you are going to have a biased set. Only recently
> touched objects (so with fresh atime), unless you plan to retain a
> database and update it from such transaction flow, which certainly is
> possible, but I am not sure how practical vs some sort of a scan.
>
> > > > > If the argument is "but OSTs know best what stuff is used"
> > > > > (which I
> > > > > am
> > > > > not sure I buy, after all before you could use something off
> > > > > OSTs
> > > > > you
> > > > > need to open a file I would hope) even then OSTs could just
> > > > > signal
> > > > > a
> > > > > list of "inactive objects" that then a higher level system
> > > > > would
> > > > > take
> > > > > care of by relocatiing somewhere more sensical and changing the
> > > > > layout
> > > > > to indicate those objects now live elsewhere.
> > > > >
> > > > > The plus here is you don't need to attach this "Wart" to every
> > > > > OST
> > > > > and
> > > > > configure it everywhere and such, but rather have a central
> > > > > location
> > > > > that is centrally managed.
> > > > >
> > >
> > > _______________________________________________
> > > lustre-devel mailing list
> > > lustre-devel@lists.lustre.org
> > > http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> > >
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel@lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>

--0000000000004cea750642c84e66
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote g=
mail_quote_container"><div dir=3D"ltr" class=3D"gmail_attr">On Mon, Nov 3, =
2025 at 6:47=E2=80=AFPM Patrick Farrell &lt;<a href=3D"mailto:pfarrell@ddn.=
com">pfarrell@ddn.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,20=
4);padding-left:1ex">



<div>
<div><span>I haven=E2=80=99t seen any mention of failover yet in this conve=
rsation (may have missed it), but if the device is truly local, then in fai=
led over configurations the data is inaccessible.=C2=A0 If it=E2=80=99s *no=
t* local, why
 not just make the device part of the OST or an independent OST?</span></di=
v></div></blockquote><div><br></div><div>It won&#39;t be local. Actually, t=
his is designed for the cloud.</div><div><br></div><div>We already have tie=
red storage based on mirroring; however, that still requires clients to mov=
e data and a file system level scanner to decide which files move to the co=
ld tier. It&#39;s cumbersome=C2=A0to maintain those clients.</div><div><br>=
</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0p=
x 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><d=
iv><div>=C2=A0</div></div></blockquote><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padd=
ing-left:1ex"><div><div><br>
</div>
<div><br>
</div>
<div>Or even if it is local only - it could be made an OST</div>
<div></div>
<hr style=3D"display:inline-block;width:98%">
<div id=3D"m_-3839173029790542839divRplyFwdMsg" dir=3D"ltr"><font face=3D"C=
alibri, sans-serif" style=3D"font-size:11pt" color=3D"#000000"><b>From:</b>=
 lustre-devel &lt;<a href=3D"mailto:lustre-devel-bounces@lists.lustre.org" =
target=3D"_blank">lustre-devel-bounces@lists.lustre.org</a>&gt; on behalf o=
f Oleg Drokin via lustre-devel &lt;<a href=3D"mailto:lustre-devel@lists.lus=
tre.org" target=3D"_blank">lustre-devel@lists.lustre.org</a>&gt;<br>
<b>Sent:</b> Monday, November 3, 2025 7:58 PM<br>
<b>To:</b> <a href=3D"mailto:jinshanx@google.com" target=3D"_blank">jinshan=
x@google.com</a> &lt;<a href=3D"mailto:jinshanx@google.com" target=3D"_blan=
k">jinshanx@google.com</a>&gt;<br>
<b>Cc:</b> <a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blan=
k">lustre-devel@lists.lustre.org</a> &lt;<a href=3D"mailto:lustre-devel@lis=
ts.lustre.org" target=3D"_blank">lustre-devel@lists.lustre.org</a>&gt;<br>
<b>Subject:</b> Re: [lustre-devel] RFC: Spill device for Lustre OSD</font>
<div>=C2=A0</div>
</div>
<div><font size=3D"2"><span style=3D"font-size:11pt">
<div>On Mon, 2025-11-03 at 16:33 -0800, Jinshan Xiong wrote:<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; I am not sure it&#39;s a much better idea than the alre=
ady existing<br>
&gt; &gt; &gt; &gt; HSM<br>
&gt; &gt; &gt; &gt; capabilities we have that would allow you to have &quot=
;offline&quot;<br>
&gt; &gt; &gt; &gt; objects<br>
&gt; &gt; &gt; &gt; that would be pulled back in when used, but are otherwi=
se just<br>
&gt; &gt; &gt; &gt; visible<br>
&gt; &gt; &gt; &gt; in the metadata only.<br>
&gt; &gt; &gt; &gt; The underlying capabilities are pretty rich esp. if we =
also<br>
&gt; &gt; &gt; &gt; take<br>
&gt; &gt; &gt; &gt; into<br>
&gt; &gt; &gt; &gt; account the eventual WBC stuff.<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; The major problem of current HSM is that it has to have dedi=
cated<br>
&gt; &gt; &gt; clients to move data. Also, scanning the entire Lustre file<=
br>
&gt; &gt; &gt; system<br>
&gt; &gt; <br>
&gt; &gt; This (dedicated client) is an implementation detail. It could be<=
br>
&gt; &gt; improved in many ways and the effort spent on this would bring<br=
>
&gt; &gt; great<br>
&gt; &gt; benefit to everyone?<br>
&gt; <br>
&gt; <br>
&gt; Almost all designs assume some upfront implementation. We (as the<br>
&gt; Lustre team) considered running clients on OST nodes, but cloud users<=
br>
&gt; are sensitive about their data being exposed elsewhere.<br>
&gt; <br>
&gt; Can you list a few improvements that come to mind?<br>
<br>
Clients between server nodes is probably one of the most obvious<br>
choices indeed. Considering the data already resides on those nodes, I<br>
am not sure I understand the concerns about &quot;exposing&quot; data that&=
#39;s<br>
already on those nodes. If customers are so sensitive, we support data<br>
encryption.<br>
We could also do some direct server-server migration of some sort where<br>
OSTs exchange data without bringing up real clients and doing copies<br>
from userspace. That might be desirable for other reasons for future<br>
functionality (e.g. various caching things people have been long<br>
envisioning)<br>
=C2=A0<br>
&gt; &gt; <br>
&gt; &gt; &gt; takes very long time so it resorts to databases in order to =
make<br>
&gt; &gt; &gt; correct decisions about which file should be released. By th=
e<br>
&gt; &gt; &gt; time,<br>
&gt; &gt; &gt; the two system will be out of sync. That makes it practicall=
y<br>
&gt; &gt; &gt; unusable.<br>
&gt; &gt; <br>
&gt; &gt; This again is an implementation detail, not even hardcoded<br>
&gt; &gt; anywhere.<br>
&gt; &gt; How do you plan for the OST to to know what stuff is not used<br>
&gt; &gt; without<br>
&gt; &gt; resorting to some database or scan? Now take this method and make=
<br>
&gt; &gt; it<br>
&gt; &gt; report &quot;upstream&quot; where currently HSM implementations r=
esort to<br>
&gt; &gt; databases or scans.<br>
&gt; &gt; <br>
&gt; <br>
&gt; The assumption is that OST sizes are relatively small, up to 100TB.<br=
>
&gt; Also, scanning local devices in kernel spaces is much faster. So yeah<=
br>
&gt; there is no database in the way.<br>
<br>
I am not sure why? In general small OSTs are a relatively rare thing<br>
because to reach large FS sizes you would need to many of them, space<br>
balancing becomes a chore and so on. So relatively few do it for some<br>
fringe reasons (e.g. Google) . Majority of people prefer large OSTs.<br>
<br>
Also nothing stops you from doing a per-OST scan (when you do have<br>
small OSTs) and then kicking the results up to the acting agent to do<br>
something about it (or the other way around, the hsm engine can ask<br>
OSTs one by one (picking less busy ones or ones that have the least<br>
free space, or some other factor). And there&#39;s absolutely no need to<br=
>
wait out to query all OSTs, you can get results from one and work on<br>
the data from it while the other OSTs are still thinking (or not,<br>
there&#39;s absolutely no requirement to get full filesystem data before<br=
>
making any decisions).<br>
<br>
&gt; I guess users won&#39;t have 1PB OSTs, will they?<br>
<br>
There probably are already? NASA has a known 0.5P OST configuration:<br>
<a href=3D"https://www.nas.nasa.gov/hecc/support/kb/lustre-progressive-file=
-layout-(pfl)-with-ssd-and-hdd-pools_680.html#:~:text=3DThe%20available%20S=
SD%20space%20in%20each%20filesystem,decimal%20(far%20right)%20labels%20of%2=
0each%20OST" target=3D"_blank">https://www.nas.nasa.gov/hecc/support/kb/lus=
tre-progressive-file-layout-(pfl)-with-ssd-and-hdd-pools_680.html#:~:text=
=3DThe%20available%20SSD%20space%20in%20each%20filesystem,decimal%20(far%20=
right)%20labels%20of%20each%20OST</a><br>
.<br>
<br>
&gt; &gt; Rereading your proposal, I see that this particular detail is not=
<br>
&gt; &gt; covered and it&#39;s just assumed that &quot;infrequently accesse=
d data&quot;<br>
&gt; &gt; would<br>
&gt; &gt; be somehow known.<br>
&gt; <br>
&gt; I should have mentioned that in the migration section. Also, we need<b=
r>
&gt; to slightly update the OST read to use a local transaction to update<b=
r>
&gt; an object&#39;s access time (atime) if it&#39;s older than a predefine=
d<br>
&gt; threshold, for example, 10 minutes.=C2=A0<br>
<br>
This is going to be fragile in the face of varying clock times on<br>
different clients potentially not synced with the servers.<br>
Also in the face of -o noatime.<br>
<br>
But yes, I guess it&#39;s one way to get this &quot;on the cheap&quot;, and=
 the other<br>
trouble I foresee is you are going to have a biased set. Only recently<br>
touched objects (so with fresh atime), unless you plan to retain a<br>
database and update it from such transaction flow, which certainly is<br>
possible, but I am not sure how practical vs some sort of a scan.<br>
<br>
&gt; &gt; &gt; &gt; If the argument is &quot;but OSTs know best what stuff =
is used&quot;<br>
&gt; &gt; &gt; &gt; (which I<br>
&gt; &gt; &gt; &gt; am<br>
&gt; &gt; &gt; &gt; not sure I buy, after all before you could use somethin=
g off<br>
&gt; &gt; &gt; &gt; OSTs<br>
&gt; &gt; &gt; &gt; you<br>
&gt; &gt; &gt; &gt; need to open a file I would hope) even then OSTs could =
just<br>
&gt; &gt; &gt; &gt; signal<br>
&gt; &gt; &gt; &gt; a<br>
&gt; &gt; &gt; &gt; list of &quot;inactive objects&quot; that then a higher=
 level system<br>
&gt; &gt; &gt; &gt; would<br>
&gt; &gt; &gt; &gt; take<br>
&gt; &gt; &gt; &gt; care of by relocatiing somewhere more sensical and chan=
ging the<br>
&gt; &gt; &gt; &gt; layout<br>
&gt; &gt; &gt; &gt; to indicate those objects now live elsewhere.<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; The plus here is you don&#39;t need to attach this &quo=
t;Wart&quot; to every<br>
&gt; &gt; &gt; &gt; OST<br>
&gt; &gt; &gt; &gt; and<br>
&gt; &gt; &gt; &gt; configure it everywhere and such, but rather have a cen=
tral<br>
&gt; &gt; &gt; &gt; location<br>
&gt; &gt; &gt; &gt; that is centrally managed.<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; <br>
&gt; &gt; _______________________________________________<br>
&gt; &gt; lustre-devel mailing list<br>
&gt; &gt; <a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank=
">lustre-devel@lists.lustre.org</a><br>
&gt; &gt; <a href=3D"http://lists.lustre.org/listinfo.cgi/lustre-devel-lust=
re.org" target=3D"_blank">http://lists.lustre.org/listinfo.cgi/lustre-devel=
-lustre.org</a><br>
&gt; &gt; <br>
<br>
_______________________________________________<br>
lustre-devel mailing list<br>
<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-d=
evel@lists.lustre.org</a><br>
<a href=3D"http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org" ta=
rget=3D"_blank">http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.or=
g</a><br>
</div>
</span></font></div>
</div>

</blockquote></div></div>

--0000000000004cea750642c84e66--

--===============3025467022378385101==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3025467022378385101==--
