Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id AA532CCFA03
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 00:34:08 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d0qFd3MjTz1y25;
	Mon, 03 Nov 2025 16:33:57 -0800 (PST)
Received: from mail-oa1-f41.google.com (mail-oa1-f41.google.com
 [209.85.160.41])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d0qFb6xhsz1xrs
 for <lustre-devel@lists.lustre.org>; Mon, 03 Nov 2025 16:33:55 -0800 (PST)
Received: by mail-oa1-f41.google.com with SMTP id
 586e51a60fabf-3d1e68f7a6cso3022873fac.3
 for <lustre-devel@lists.lustre.org>; Mon, 03 Nov 2025 16:33:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=google.com; s=20230601; t=1762216435; x=1762821235; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=RTm2bFNsaBGAfWMG6leEIqcjFgU4WRGqC4VeTT7mu0s=;
 b=arhZUgpRHu4+uFBkkkdhBRsPG6eH+h86lyBWiH6y0wYLqartqY4uGZGlQqDAKeBXml
 OQ9KFG7FvFu1jiWc6c8tcD3VGx0ncrWjTS2DjJU9QmH7zKzMt1BBe4tZ8tHR7fy8NfQd
 jbEeruqosOC3Qzta7yRif6kLdQ2op80Tyzgkj3XVQ+3SMZmATa6fRUqn4DmrkKVHJu/g
 UuI9R8MHlvs0i+ny7R3UEJBmWPFTqCv4iM32eGEpL65Mwsqp65CO6cjARY0rKwQS3XZs
 HU185rNKg20A3Jj4Qwrf5HbCOu215oZMxIX6PMLUm0afp1Mf19hqscFkxgDNL3X2Owu2
 rxIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762216435; x=1762821235;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=RTm2bFNsaBGAfWMG6leEIqcjFgU4WRGqC4VeTT7mu0s=;
 b=G05p5BdJ5XoMS9DFjf+IK3GqIQqEoM44QJUwxmYYnDhmVvANKDbvEMhLDDjsspGYeD
 5DpJvnss5p3Ste7xPtTOTst26t7yZQTqPeSUoE0UCXLdkGS/DCoNI8Bl/a8IjNbTrSeY
 uL0YHzVRh2KL5JBocuJuSvDAAnmvmbjIXcK+ieLx0vXXGaop5xTlnjolGgq9zKwyOrD2
 ATm7Jq+zXK+1eF/7Uw3dG+ZCR+HiFenCxs7Rj7Z8ndzYDEhFc69XeuhI3iuHr2qKJ5Yr
 usnyMp8AYLTRY80UHXnhO9h3FycLaYYcxL77DIiHc2kNaOWmlu7jcFCrGs8pBtuQUmfw
 l7sQ==
X-Forwarded-Encrypted: i=1;
 AJvYcCUMQDg5Wuw9L52vtZkrTgtiNTrzs79OxKdJq8vZ1zIWMrKKyfY4AI4dWghFpRAWRoQaUZbHF0XyWAO3nYo=@lists.lustre.org
X-Gm-Message-State: AOJu0YwBErpalwgo9qIPXrx1sZisA7iPbKTubJzbcpaYO42UYnaDsRen
 EWMLtUmrLLu6zNd6DOvfKmtKvS5ydCT9tYpzc2ulz5lgBCXDmS8CrUSjQGX7Dd2vz1YRJfKncA2
 LyLu1ctGmRxr/TsMZh4V3w6itfANaX4KiE7xvzbIv
X-Gm-Gg: ASbGnctK0+h9Dg6BO6yNKIAMxs8b5CcpukAUTLyrBXb9Q1pmTVQZ4+L6oJp4C5+o8Kd
 QMGi9Xc/4pwFs6TSGl5dgd9tSMZxIaFbqx0GeQYFyB029ZG50u4nbuttbiMxXdofhO/F7FKjLmm
 WVt2i4HvSWtr7DhJZ1R2TYdNgBE9gYYnUpDfZLM8m965JTs6c3Osxoz/o9TZOa12Xa3TAW+0h59
 TUpA1EOiBkZIOBdVycdRaXdwEntfZa+54lVYMEbO7JGjx3Y4yY1D01gMRK7uyaOHMIXoTojVoIq
 mePzp5OUxQT3PVkT89YT1omahA==
X-Google-Smtp-Source: AGHT+IEJ9I5Hq+a/KqUGcw8EsEhi1q4plIX7PyHXc/Z28BjtorwF1PH1/fMLZrN6VP9U93d5oDvWF6+eXnDwNLZ0v3E=
X-Received: by 2002:a05:6870:bcc5:b0:3e0:96ba:b294 with SMTP id
 586e51a60fabf-3e096baf6dfmr74475fac.30.1762216434829; Mon, 03 Nov 2025
 16:33:54 -0800 (PST)
MIME-Version: 1.0
References: <e2c69a503e80f3ba59d69f093bc8df519cdd7f66.camel@whamcloud.com>
 <BFDDAAED-BA9A-44DB-BCD0-B3B84E652FE7@gmail.com>
 <c6c016567a02f857303eedb9a4af6b5831c2c818.camel@whamcloud.com>
In-Reply-To: <c6c016567a02f857303eedb9a4af6b5831c2c818.camel@whamcloud.com>
Date: Mon, 3 Nov 2025 16:33:43 -0800
X-Gm-Features: AWmQ_bmxSQf7C8n-N6A80NnENbCNyzZceIqBelNIAli1LqSK0eblAsfR33XdtZc
Message-ID: <CAEp8vpiZ8iKRbjy8GYKdXFjsycW=a48baOXxUnSP7uE+Xf5cYw@mail.gmail.com>
To: Oleg Drokin <green@whamcloud.com>
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============6131070229279096674=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6131070229279096674==
Content-Type: multipart/alternative; boundary="0000000000009df0910642b9fc58"

--0000000000009df0910642b9fc58
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 3, 2025 at 4:22=E2=80=AFPM Oleg Drokin via lustre-devel <
lustre-devel@lists.lustre.org> wrote:

> On Mon, 2025-11-03 at 16:04 -0800, Jinshan Xiong wrote:
> >
> >
> > > On Nov 3, 2025, at 15:14, Oleg Drokin <green@whamcloud.com> wrote:
> > >
> > > =EF=BB=BFOn Mon, 2025-11-03 at 21:59 +0000, Day, Timothy via lustre-d=
evel
> > > wrote:
> > > >
> > > >
> > > > This begs the question: if we're already doing this work to
> > > > support
> > > > writing Lustre objects to any arbitrary filesystem via VFS and
> > > > we're
> > > > only
> > > > intending to support OSTs with this proposal, why not implement
> > > > an OST-only VFS OSD and handle tiering in the filesystem layer?
> > >
> > > The problem with pure VFS is it does not actually provide us what
> > > we
> > > want.
> > > So OSD talks to the underlying FS via VFS + some more stuff (we do
> > > have
> > > the hidden mount for ldiskfs after all).
> > > The "more stuff" is things like expanded transaction boundaries
> > > beyond
> > > what posix requires so we can update more than one thing.
> > > If Linux VFS provided all these abilities we would not need to
> > > really
> > > know much about the underlying disk fs I suspect.
> > >
> > > But currently it's just a way to add OSTs, not move objects
> > > laterally
> > > from one OST to another and hence this proposal I imagine - where
> > > OSTs
> > > would grow "warts" for less wanted data.
> > >
> > > I am not sure it's a much better idea than the already existing HSM
> > > capabilities we have that would allow you to have "offline" objects
> > > that would be pulled back in when used, but are otherwise just
> > > visible
> > > in the metadata only.
> > > The underlying capabilities are pretty rich esp. if we also take
> > > into
> > > account the eventual WBC stuff.
> >
> > The major problem of current HSM is that it has to have dedicated
> > clients to move data. Also, scanning the entire Lustre file system
>
> This (dedicated client) is an implementation detail. It could be
> improved in many ways and the effort spent on this would bring great
> benefit to everyone?
>

Almost all designs assume some upfront implementation. We (as the Lustre
team) considered running clients on OST nodes, but cloud users are
sensitive about their data being exposed elsewhere.

Can you list a few improvements that come to mind?


>
> > takes very long time so it resorts to databases in order to make
> > correct decisions about which file should be released. By the time,
> > the two system will be out of sync. That makes it practically
> > unusable.
>
> This again is an implementation detail, not even hardcoded anywhere.
> How do you plan for the OST to to know what stuff is not used without
> resorting to some database or scan? Now take this method and make it
> report "upstream" where currently HSM implementations resort to
> databases or scans.
>

The assumption is that OST sizes are relatively small, up to 100TB. Also,
scanning local devices in kernel spaces is much faster. So yeah there is no
database in the way.

I guess users won't have 1PB OSTs, will they?


>
> Rereading your proposal, I see that this particular detail is not
> covered and it's just assumed that "infrequently accessed data" would
> be somehow known.
>

I should have mentioned that in the migration section. Also, we need to
slightly update the OST read to use a local transaction to update an
object's access time (atime) if it's older than a predefined threshold, for
example, 10 minutes.


>
> >
> > >
> > > If the argument is "but OSTs know best what stuff is used" (which I
> > > am
> > > not sure I buy, after all before you could use something off OSTs
> > > you
> > > need to open a file I would hope) even then OSTs could just signal
> > > a
> > > list of "inactive objects" that then a higher level system would
> > > take
> > > care of by relocatiing somewhere more sensical and changing the
> > > layout
> > > to indicate those objects now live elsewhere.
> > >
> > > The plus here is you don't need to attach this "Wart" to every OST
> > > and
> > > configure it everywhere and such, but rather have a central
> > > location
> > > that is centrally managed.
> > >
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel@lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>

--0000000000009df0910642b9fc58
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote g=
mail_quote_container"><div dir=3D"ltr" class=3D"gmail_attr">On Mon, Nov 3, =
2025 at 4:22=E2=80=AFPM Oleg Drokin via lustre-devel &lt;<a href=3D"mailto:=
lustre-devel@lists.lustre.org">lustre-devel@lists.lustre.org</a>&gt; wrote:=
<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8=
ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">On Mon, 2025-11=
-03 at 16:04 -0800, Jinshan Xiong wrote:<br>
&gt; <br>
&gt; <br>
&gt; &gt; On Nov 3, 2025, at 15:14, Oleg Drokin &lt;<a href=3D"mailto:green=
@whamcloud.com" target=3D"_blank">green@whamcloud.com</a>&gt; wrote:<br>
&gt; &gt; <br>
&gt; &gt; =EF=BB=BFOn Mon, 2025-11-03 at 21:59 +0000, Day, Timothy via lust=
re-devel<br>
&gt; &gt; wrote:<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; This begs the question: if we&#39;re already doing this work=
 to<br>
&gt; &gt; &gt; support<br>
&gt; &gt; &gt; writing Lustre objects to any arbitrary filesystem via VFS a=
nd<br>
&gt; &gt; &gt; we&#39;re<br>
&gt; &gt; &gt; only<br>
&gt; &gt; &gt; intending to support OSTs with this proposal, why not implem=
ent<br>
&gt; &gt; &gt; an OST-only VFS OSD and handle tiering in the filesystem lay=
er?<br>
&gt; &gt; <br>
&gt; &gt; The problem with pure VFS is it does not actually provide us what=
<br>
&gt; &gt; we<br>
&gt; &gt; want.<br>
&gt; &gt; So OSD talks to the underlying FS via VFS + some more stuff (we d=
o<br>
&gt; &gt; have<br>
&gt; &gt; the hidden mount for ldiskfs after all).<br>
&gt; &gt; The &quot;more stuff&quot; is things like expanded transaction bo=
undaries<br>
&gt; &gt; beyond<br>
&gt; &gt; what posix requires so we can update more than one thing.<br>
&gt; &gt; If Linux VFS provided all these abilities we would not need to<br=
>
&gt; &gt; really<br>
&gt; &gt; know much about the underlying disk fs I suspect.<br>
&gt; &gt; <br>
&gt; &gt; But currently it&#39;s just a way to add OSTs, not move objects<b=
r>
&gt; &gt; laterally<br>
&gt; &gt; from one OST to another and hence this proposal I imagine - where=
<br>
&gt; &gt; OSTs<br>
&gt; &gt; would grow &quot;warts&quot; for less wanted data.<br>
&gt; &gt; <br>
&gt; &gt; I am not sure it&#39;s a much better idea than the already existi=
ng HSM<br>
&gt; &gt; capabilities we have that would allow you to have &quot;offline&q=
uot; objects<br>
&gt; &gt; that would be pulled back in when used, but are otherwise just<br=
>
&gt; &gt; visible<br>
&gt; &gt; in the metadata only.<br>
&gt; &gt; The underlying capabilities are pretty rich esp. if we also take<=
br>
&gt; &gt; into<br>
&gt; &gt; account the eventual WBC stuff.<br>
&gt; <br>
&gt; The major problem of current HSM is that it has to have dedicated<br>
&gt; clients to move data. Also, scanning the entire Lustre file system<br>
<br>
This (dedicated client) is an implementation detail. It could be<br>
improved in many ways and the effort spent on this would bring great<br>
benefit to everyone?<br></blockquote><div><br></div><div>Almost all designs=
 assume some upfront implementation. We (as the Lustre team) considered run=
ning clients on OST nodes, but cloud users are sensitive about their data b=
eing exposed elsewhere.</div><div><br></div><div>Can you list a few improve=
ments that come to mind?</div><div>=C2=A0</div><blockquote class=3D"gmail_q=
uote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,2=
04);padding-left:1ex">
<br>
&gt; takes very long time so it resorts to databases in order to make<br>
&gt; correct decisions about which file should be released. By the time,<br=
>
&gt; the two system will be out of sync. That makes it practically<br>
&gt; unusable.<br>
<br>
This again is an implementation detail, not even hardcoded anywhere.<br>
How do you plan for the OST to to know what stuff is not used without<br>
resorting to some database or scan? Now take this method and make it<br>
report &quot;upstream&quot; where currently HSM implementations resort to<b=
r>
databases or scans.<br></blockquote><div><br></div><div>The assumption is t=
hat OST sizes are relatively small, up to 100TB. Also, scanning local devic=
es in kernel spaces is much faster. So yeah there is no database in the way=
.</div><div><br></div><div>I guess users won&#39;t have 1PB OSTs, will they=
?</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0=
px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
<br>
Rereading your proposal, I see that this particular detail is not<br>
covered and it&#39;s just assumed that &quot;infrequently accessed data&quo=
t; would<br>
be somehow known.<br></blockquote><div><br></div><div>I should have mention=
ed that in the migration section. Also, we need to slightly update the OST =
read to use a local transaction to update an object&#39;s access time (atim=
e) if it&#39;s older than a predefined threshold, for example, 10 minutes.=
=C2=A0</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1=
ex">
<br>
&gt; <br>
&gt; &gt; <br>
&gt; &gt; If the argument is &quot;but OSTs know best what stuff is used&qu=
ot; (which I<br>
&gt; &gt; am<br>
&gt; &gt; not sure I buy, after all before you could use something off OSTs=
<br>
&gt; &gt; you<br>
&gt; &gt; need to open a file I would hope) even then OSTs could just signa=
l<br>
&gt; &gt; a<br>
&gt; &gt; list of &quot;inactive objects&quot; that then a higher level sys=
tem would<br>
&gt; &gt; take<br>
&gt; &gt; care of by relocatiing somewhere more sensical and changing the<b=
r>
&gt; &gt; layout<br>
&gt; &gt; to indicate those objects now live elsewhere.<br>
&gt; &gt; <br>
&gt; &gt; The plus here is you don&#39;t need to attach this &quot;Wart&quo=
t; to every OST<br>
&gt; &gt; and<br>
&gt; &gt; configure it everywhere and such, but rather have a central<br>
&gt; &gt; location<br>
&gt; &gt; that is centrally managed.<br>
&gt; &gt; <br>
<br>
_______________________________________________<br>
lustre-devel mailing list<br>
<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-d=
evel@lists.lustre.org</a><br>
<a href=3D"http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org" re=
l=3D"noreferrer" target=3D"_blank">http://lists.lustre.org/listinfo.cgi/lus=
tre-devel-lustre.org</a><br>
</blockquote></div></div>

--0000000000009df0910642b9fc58--

--===============6131070229279096674==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6131070229279096674==--
