Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id F3EBBCCF9E3
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 17:48:31 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1GBj3xKgz1yWJ;
	Tue, 04 Nov 2025 09:47:57 -0800 (PST)
Received: from mail-oo1-f44.google.com (mail-oo1-f44.google.com
 [209.85.161.44])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1GBY2R3Sz1y4F
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 09:47:49 -0800 (PST)
Received: by mail-oo1-f44.google.com with SMTP id
 006d021491bc7-65366485678so2915420eaf.2
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 09:47:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=google.com; s=20230601; t=1762278468; x=1762883268; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=tqK/pp9JMzS2HD5+SXs7Ua2XjCBGwurl+fmtYJy+nb4=;
 b=Kjw6mA4iyef0k3+nKp81XQCyUEvIq10YIrv4ajrfgTZeGmHBZr6V9iJOElAFEXvAlo
 v1dT+GUL3957R7FrAQCT3VT/JKi+fkQ0yWjHB1QyLPwYNIuKjiSWwoJx4TRa1WqOLz6G
 jkbijqwsmk9eSs+8rxvmFKYyuP3bUvxFGO79n+yoHxwmLwmYHaMzVMPf51P2xq929VFu
 MmHYbIla8hmUXQV4H7tcWMACsBBPC/KyzZ+NFD9FxWXP7noKW+F3ukcuQMXd+s2WGRZ2
 8ykfehpGzH6FSxwi/eEJb9pk+GVTvX7d9pVL664FUDHHHNET6d7qYqLsm9ihPfnfIl2P
 E5BQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762278468; x=1762883268;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=tqK/pp9JMzS2HD5+SXs7Ua2XjCBGwurl+fmtYJy+nb4=;
 b=DVHLcSOlkLegLwcdExBTZykhroql4Gu0zkc93RtmWsWnqt0Az8eOWS03RxDbKVSvTt
 N0ADQNJxm7mZf3jpIScWa3C3M6sXLankNREfPMbEYQPFHyoFH99gEJH5phc/a6DJEzsz
 0vfyjWnrHAvUEprlr+b4t6Pi9xlyiTDOwPFxjDMUV6AjfBy0cOKMsRlM0+nQ2xSb2q3S
 HPUiZYW5RNMepTb5LzRaRdKyCEPgioA2RbkjO3WxQZeAbUMgW8gJrmvx2ziZMq3N9UIg
 LB7wai08TWS/3YwrjxeouU9y3/zjmzqWtzaqkpmQnIRhn9MICg8gQzTimZCaPk2GxqtL
 ZfyQ==
X-Gm-Message-State: AOJu0YzBuYs5dGKBI7w4dezRXwKWsO7B64r27mDw5X09ZW6ZlUY//rKy
 HRX5ARxQYkahxVLo3QCrcRNsBHV7ecr28Vt7azQ0gNTVgzeFx0BuG9YlX2Ou3WF2Cmq7SX524Q5
 5cZA+ymOUPGQT+K45esVgGgt1DI3GHO/x+5xluVbB
X-Gm-Gg: ASbGncuqEffOW97Qy4fB6xl7tM3gtoxd8SQKlrXCagmrNCByfXJ/cbC34vPmMjK+awW
 gXN792eFMiZanwHhZXrPHJTgHr1fmJUjL2aY8Fho7b1ADUmnOG2NmdbNrpHQ/Ln70JVLBMBRRgT
 UCgnmgbVc69MSL2ydlu/n49mT5v2XHh6/Bbxw4sIvEUNdZRhw9uxSUuzzTmT+SUm7s2iVkwmbpG
 01LXERI0H8bVtHz+zyjrg2zlG7uxFRQqm5WjqI/Oy/hSJGJF8TUFAwBClz+d2M2LeigEDyFOVa/
 2u/9JZHZhNK1E3LS+h6B2tg1LhQSk011SG7HC24=
X-Google-Smtp-Source: AGHT+IEAEqTLyOXRUwEVJ3HADOYCNVDnm0HuuHIeKV3UTRNSf70lnXT6YgosMEwvFVhw/V7GByrtgYjKtL0SOSS1Ky8=
X-Received: by 2002:a05:687c:2057:b0:3e0:df48:d5df with SMTP id
 586e51a60fabf-3e19c15b067mr108923fac.34.1762278467500; Tue, 04 Nov 2025
 09:47:47 -0800 (PST)
MIME-Version: 1.0
References: <e2c69a503e80f3ba59d69f093bc8df519cdd7f66.camel@whamcloud.com>
 <BFDDAAED-BA9A-44DB-BCD0-B3B84E652FE7@gmail.com>
 <c6c016567a02f857303eedb9a4af6b5831c2c818.camel@whamcloud.com>
 <CAEp8vpiZ8iKRbjy8GYKdXFjsycW=a48baOXxUnSP7uE+Xf5cYw@mail.gmail.com>
 <e31f82d56f034cb325ae29a08280122711078a97.camel@whamcloud.com>
In-Reply-To: <e31f82d56f034cb325ae29a08280122711078a97.camel@whamcloud.com>
Date: Tue, 4 Nov 2025 09:47:36 -0800
X-Gm-Features: AWmQ_bndKUDbYyIysemXynxEr0tF9ErzfSN0YTCxTgwQCRHXFF3rns90DfiAvBI
Message-ID: <CAEp8vpj35nY7atGPwXvjsPKdnKYfyE+w7uJ7gihXrC3_W7G15Q@mail.gmail.com>
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
Content-Type: multipart/mixed; boundary="===============6784438486419368419=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6784438486419368419==
Content-Type: multipart/alternative; boundary="0000000000000d76ba0642c86e5e"

--0000000000000d76ba0642c86e5e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 3, 2025 at 5:58=E2=80=AFPM Oleg Drokin <green@whamcloud.com> wr=
ote:

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


This is going too far ;-)


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

It doesn't use client timestamps. Also, it won't be part of read because
read doesn't initiate a transaction.

It can simply use the OSS local time and start a local transaction to
update the atime.


>
> But yes, I guess it's one way to get this "on the cheap", and the other
> trouble I foresee is you are going to have a biased set. Only recently
> touched objects (so with fresh atime), unless you plan to retain a
> database and update it from such transaction flow, which certainly is
> possible, but I am not sure how practical vs some sort of a scan.
>

I don't see that as an issue. It's going to update the atime in memory. And
yeah if the OSS is crashed and the scanner may choose a wrong file to
migrate, this should be rare and I don't think this would become a severe
issue.


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
>

--0000000000000d76ba0642c86e5e
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote g=
mail_quote_container"><div dir=3D"ltr" class=3D"gmail_attr">On Mon, Nov 3, =
2025 at 5:58=E2=80=AFPM Oleg Drokin &lt;<a href=3D"mailto:green@whamcloud.c=
om">green@whamcloud.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_=
quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,=
204);padding-left:1ex">On Mon, 2025-11-03 at 16:33 -0800, Jinshan Xiong wro=
te:<br>
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
envisioning)</blockquote><div><br></div><div>This is going too far ;-)</div=
><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px=
 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">=C2=A0<=
/blockquote><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0=
.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
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
0each%20OST" rel=3D"noreferrer" target=3D"_blank">https://www.nas.nasa.gov/=
hecc/support/kb/lustre-progressive-file-layout-(pfl)-with-ssd-and-hdd-pools=
_680.html#:~:text=3DThe%20available%20SSD%20space%20in%20each%20filesystem,=
decimal%20(far%20right)%20labels%20of%20each%20OST</a><br>
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
Also in the face of -o noatime.<br></blockquote><div><br></div><div>It does=
n&#39;t use client timestamps. Also, it won&#39;t be part of read because r=
ead doesn&#39;t initiate a transaction.</div><div><br></div><div>It=C2=A0ca=
n simply use the OSS local time and start a local transaction to update the=
 atime.=C2=A0</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding=
-left:1ex">
<br>
But yes, I guess it&#39;s one way to get this &quot;on the cheap&quot;, and=
 the other<br>
trouble I foresee is you are going to have a biased set. Only recently<br>
touched objects (so with fresh atime), unless you plan to retain a<br>
database and update it from such transaction flow, which certainly is<br>
possible, but I am not sure how practical vs some sort of a scan.<br></bloc=
kquote><div><br></div><div>I don&#39;t see that as an issue. It&#39;s going=
 to update the atime in memory. And yeah if the OSS is crashed and the scan=
ner may choose a wrong file to migrate, this should be rare and I don&#39;t=
 think this would become a severe issue.</div><div>=C2=A0</div><blockquote =
class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px sol=
id rgb(204,204,204);padding-left:1ex">
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
re.org" rel=3D"noreferrer" target=3D"_blank">http://lists.lustre.org/listin=
fo.cgi/lustre-devel-lustre.org</a><br>
&gt; &gt; <br>
<br>
</blockquote></div></div>

--0000000000000d76ba0642c86e5e--

--===============6784438486419368419==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6784438486419368419==--
