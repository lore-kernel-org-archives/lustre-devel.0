Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BF95ECCFA04
	for <lustre-devel@archiver.kernel.org>; Wed,  5 Nov 2025 00:03:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1Q616qjlz20fc;
	Tue, 04 Nov 2025 15:44:25 -0800 (PST)
Received: from mail-pg1-f182.google.com (mail-pg1-f182.google.com
 [209.85.215.182])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1Q5L10G4z20df
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 15:43:50 -0800 (PST)
Received: by mail-pg1-f182.google.com with SMTP id
 41be03b00d2f7-b556284db11so5093439a12.0
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 15:43:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1762299772; x=1762904572; darn=lists.lustre.org;
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:from:to:cc:subject:date:message-id:reply-to;
 bh=nmA2LhO0aT5mZ/wolRIIdqcImawx8vxBE3saCJQv6/8=;
 b=f8e9YX3NldN0JYqO+U9IEh+t++vVOWPGeCufQi832Jr0YaZPbvD7LgKSNLaM7+l9eP
 fRuGzngY4GW3tAK6FomVc9+DBQj5gk5QDsyrq6sCkhaVgfbgBqg+ZJDKhrhwqv2h9a48
 hQA+ajam8oaQDv61XO8efbPiy7fhRm6SZ3/aMGQ+LACMmnB6HcNZtZWSU6ycUD4u0+ck
 BtWNtaTNJuXxs3BKKTZ4gvbc+fj/0QLaUBmaUzt/JBlk2x+RKlCXzZ7MlmfcflEoMX/Y
 1sV678A0gKtHnK5cCfYsqDMChACaxHuTLGAhUWdBm5mgKQF/vQwgaPdq8vBDxk9Rh1Ap
 FXvw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762299772; x=1762904572;
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=nmA2LhO0aT5mZ/wolRIIdqcImawx8vxBE3saCJQv6/8=;
 b=KksAJDWzrnOxGd7xemzHDsJXwz3uRBx317mkfvF58YzTuFJlPc3CF7BGgvoKsUHG8E
 Cs3GUOAN5R4FWjh4pe0Df4iOB+sgpkZFgBemHBd0PuoPgNwpAJOH86Tx+pnszBP+v+MO
 mIHzwja+QXlp3CHMyvKpSoF7TeoBTNLV+jJqssSu3rYLVtak3VIHI0zKVugAkDvxsTNl
 ZDbmmirK4UpHBt5Z3KBhHSBS7itHP7eR8DrcLpZfq68UYTvlJ/cBZ3S0EI6aZnt8Zdyz
 spe320EwpMles3QG98R/9JRaQVKhZwjVVDxapS3bXJbWE82RzaPe3KTq51NYhMiXPWxl
 7F0g==
X-Forwarded-Encrypted: i=1;
 AJvYcCW3xkbYE2Wbe2ALpkuktWg0aY/ruYpWlthEacinoOLRyxm4d3HQ+EiUow2Xn+IK0ADwvzixheO2QGluOSQ=@lists.lustre.org
X-Gm-Message-State: AOJu0Yy5Zn8/8d9ex/fuHPV+QLM5+1cr41hMPIGGQYWpIPZEcby4Zd7R
 XGNeINj3Ppv/hfMoEnxzEy1/s8VNXo6EVkZH44XKAOrP4zEuvTW5Xu0L
X-Gm-Gg: ASbGncuZKMZVyTUAg+Ak6hhCEDpKlGUgG/gHVN+jmoXiYLQN5aGrCDFzkFU2YV+F+eA
 7dyinTZnP7olxVZWOldqR/748UzN3WPgZyEO1N3K7q0oDG4Qmd6qgZfWJyawKf4cQkKqr4JC/J5
 elMdeQ5X/R7NOS5zrfr71dXCOrZK+GyDfCjmQQ5rsYzQHQjHpyESg5tttMyfXTzB3QowJ4nOdS1
 PTswA3hNbCj4BPLnEas725hiI+kXEy/G2XOdWiKkgxd4sFXrnsoqaY3EiQWLE9ex6mXmTrW8Dd9
 dfCL6/IHf5xQV+IcLAA/WCz8dJlArkEUDmXvkDnWbCR3QoGMu2l9NOV4dEnk+RyKoOEvbRnQQz2
 D0VfMGTPT4SviLT4ivw+8qQWKeG1ukayzgdddtMWSfWtebNwaJEPMNNwcfdDKLzocLmmgH91Y6Z
 K95LiWdYzg2eKuhHdZ3tt/8BxZ4cJ6quOLbjEv
X-Google-Smtp-Source: AGHT+IEosnUNTTfZUh7edK6WfbjOBaMOaRBz26/8mRD8U+05dpLbUZTO+kBKPe1Lfl/7ou9kg4QIQQ==
X-Received: by 2002:a05:6300:7105:b0:34f:b480:7bcc with SMTP id
 adf61e73a8af0-34fb48fc47dmr457072637.9.1762299772441; 
 Tue, 04 Nov 2025 15:42:52 -0800 (PST)
Received: from smtpclient.apple ([2601:644:8f00:2cb5:9c05:559a:3d91:3967])
 by smtp.gmail.com with ESMTPSA id
 41be03b00d2f7-ba1f7568b81sm3664085a12.20.2025.11.04.15.42.51
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Tue, 04 Nov 2025 15:42:51 -0800 (PST)
Message-Id: <74326E79-3FCD-41F5-B5DA-95EA2CC48435@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3864.200.81.1.6\))
Date: Tue, 4 Nov 2025 15:42:40 -0800
In-Reply-To: <28B74585-1877-4A33-9218-FD50AE72D33D@ddn.com>
To: Andreas Dilger <adilger@ddn.com>
References: <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
 <0092A54A-6EEF-4CD3-8AFD-7B0066A08810@gmail.com>
 <D8E0F0C0-1A5F-413A-82EA-F3CFA473D2E1@amazon.com>
 <28B74585-1877-4A33-9218-FD50AE72D33D@ddn.com>
X-Mailer: Apple Mail (2.3864.200.81.1.6)
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
Reply-To: Jinshan Xiong <jinshan.xiong@gmail.com>
Cc: Andreas Dilger <adilger@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============7808215221663793929=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


--===============7808215221663793929==
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_44A77994-14E6-4B71-8FCB-73DDA2890107"


--Apple-Mail=_44A77994-14E6-4B71-8FCB-73DDA2890107
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8



> On Nov 4, 2025, at 15:07, Andreas Dilger <adilger@ddn.com> wrote:
>=20
> On Nov 4, 2025, at 14:11, Day, Timothy <timday@amazon.com> wrote:
>>=20
>>> VFS OSD won=E2=80=99t give us everything to make it an OSD. =
Transaction is one of the issue as Oleg mentioned.
>>=20
>> We'll have to implement a lot of complexity in kernel space for
>> the design you're suggesting. At some point, implementing
>> a transaction log and delegating the rest to user space might
>> be the more maintainable option? Doing that via VFS/Fuse is
>> one option. Something similar to ublk for OSD could be another
>> option.
>=20
> If the writes to the spill device are well managed, it may be possible
> to do it without transaction support, so long as they are not exposed
> directly for writing to the clients.  Otherwise they essentially need
> to be OSDs that expose transactions and recovery semantics.
>=20
>> I'm not saying this is preferrable, but is this something you've
>> considered?
>>=20
>>> Extended attributes would be another thing since not all file =
systems would support it.
>>=20
>> I think it's fine not accept filesystems that don't support EA.
>> Or have the OSD advertise that it doesn't support EA.
>=20
> I don't think any storage system we care about today does not support
> EAs or tags or similar metadata that can be used for this.
>=20
>>>>> deliver better performance than block-level cache with dmcache, =
where
>>>>> recovery time is lengthy if the cache size is huge.
>>>>=20
>>>> This seems speculative. Could you elaborate more on why you think
>>>> this is the case?
>>>=20
>>> DMcache doesn=E2=80=99t persist the bitmap used to indicate which =
blocks are holding dirty data, so an ungraceful shutdown will lead to a =
scanning of the entire cache in order to determine which blocks are > =
dirty.
>>=20
>> This is a failing of DMcache rather than an indication that this
>> problem can't be solved on the block layer.
>=20
> That was my original discussion with Jinshan as well.  There was a
> similar issue with mdraid, and they ended up with persistent bitmaps
> in a flash device.  It should be possible to manage this with logs
> or bitmaps stored in the fast OSD device instead of the spill device.
>=20
>> Overall, I think the concept is interesting. It reminds me of how
>> Bcachefs handle multi-device support. Each device can be
>> designated as holding metadata or data replicas. And you
>> can control the promotion and migration between different
>> targets (all managed by a migration daemon). But this design is
>> too limited, IMHO. If we're going to accept the additional complexity
>> in the OSD, the solution has to be extensible. What if I want to
>> replicate to multiple targets? What if I want more than two tiers?
>> What if I want to transparently migrate data from one spill device to
>> another? We don't need this for the initial implementation, sure.
>> But these seem like natural extensions.

It=E2=80=99s possible to extend the design to have multiple spill =
devices in the OSD; you could have two spill devices and mirror them, or =
raid0 to make a larger device. I don=E2=80=99t see the design would not =
allow you to do that.=20

>=20
> This is essentially replicating Lustre file layouts in the end, which
> was my original suggestion - to use FLR and/or PCC-RO foreign
> mirror layouts for this, even if it is not directly accessible from
> clients.  That avoids reimplementing tools/formats that already
> exist in Lustre today for relatively little benefit.


One of the goals is to not have a file system-level scanner, which is =
not good. Otherwise, we can just use FLR-based tiered storage.

>=20
>> I think we need to use some kind of common API for the
>> different devices. Even if the spill device doesn't support atomic
>> transactions, I don't see why we couldn't still use the common OSD
>> API and implement the migration daemon as a stacking driver on-top
>> of that. The spill device OSD driver could be made to advertise that =
it
>> doesn't support atomic transactions and may not support EA. But we
>> get the added benefit of being able to use existing OSDs with this
>> feature, pretty much for free.
>=20
> Also my argument.  Using the VFS directly is constraining (lack of
> transactions), but of backends that _can_ be a full OSD (or already
> have an OSD like ldiskfs, ZFS, memfs) it is a drop-in replacement.
>=20
> There is already an OSD API to query the functionality of the backing
> storage, so it should be straight forward to add "transaction", =
"xattr",
> and other supported features to that.
>=20
> If we can implement a no-transaction osd-vfs, that would expose a
> lot of flexibility for other reasons as well.  Possibly the osd-vfs =
could
> implement a journal or other logging layer internally to make up for
> lack of transactions, whether initially or at a later stage?

What would be the benefit of having a limited OSD in the stack? I =
don=E2=80=99t have a strong opinion of not doing it, but I just didn=E2=80=
=99t see any benefits of doing it.

>=20
> Cheers, Andreas
> =E2=80=94
> Andreas Dilger
> Lustre Principal Architect
> Whamcloud/DDN
>=20
>=20
>=20
>=20


--Apple-Mail=_44A77994-14E6-4B71-8FCB-73DDA2890107
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html aria-label=3D"message body"><head><meta http-equiv=3D"content-type" =
content=3D"text/html; charset=3Dutf-8"></head><body =
style=3D"overflow-wrap: break-word; -webkit-nbsp-mode: space; =
line-break: after-white-space;"><br =
id=3D"lineBreakAtBeginningOfMessage"><div><br><blockquote =
type=3D"cite"><div>On Nov 4, 2025, at 15:07, Andreas Dilger =
&lt;adilger@ddn.com&gt; wrote:</div><br =
class=3D"Apple-interchange-newline"><div>

<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dutf-8">

<div style=3D"overflow-wrap: break-word; -webkit-nbsp-mode: space; =
line-break: after-white-space;">
On Nov 4, 2025, at 14:11, Day, Timothy &lt;timday@amazon.com&gt; =
wrote:<br>
<div>
<blockquote type=3D"cite"><br class=3D"Apple-interchange-newline">
<div>
<div>
<blockquote type=3D"cite">VFS OSD won=E2=80=99t give us everything to =
make it an OSD. Transaction is one of the issue as Oleg mentioned.<br>
</blockquote>
<br>
We'll have to implement a lot of complexity in kernel space for<br>
the design you're suggesting. At some point, implementing<br>
a transaction log and delegating the rest to user space might<br>
be the more maintainable option? Doing that via VFS/Fuse is<br>
one option. Something similar to ublk for OSD could be another<br>
option.<br>
</div>
</div>
</blockquote>
<div><br>
</div>
If the writes to the spill device are well managed, it may be =
possible</div>
<div>to do it without transaction support, so long as they are not =
exposed</div>
<div>directly for writing to the clients. &nbsp;Otherwise they =
essentially need</div>
<div>to be OSDs that expose transactions and recovery semantics.</div>
<div><br>
<blockquote type=3D"cite">
<div>
<div>I'm not saying this is preferrable, but is this something =
you've<br>
considered?<br>
<br>
<blockquote type=3D"cite">Extended attributes would be another thing =
since not all file systems would support it.<br>
</blockquote>
<br>
I think it's fine not accept filesystems that don't support EA.</div>
</div>
</blockquote>
<blockquote type=3D"cite">
<div>
<div>Or have the&nbsp;OSD advertise that it doesn't support EA.<br>
</div>
</div>
</blockquote>
<div><br>
</div>
I don't think any storage system we care about today does not =
support</div>
<div>EAs or tags or similar metadata that can be used for this.</div>
<div><br>
<blockquote type=3D"cite">
<div>
<div>
<blockquote type=3D"cite">
<blockquote type=3D"cite">
<blockquote type=3D"cite">deliver better performance than block-level =
cache with dmcache, where<br>
recovery time is lengthy if the cache size is huge.<br>
</blockquote>
<br>
This seems speculative. Could you elaborate more on why you think<br>
this is the case?<br>
</blockquote>
<br>
DMcache doesn=E2=80=99t persist the bitmap used to indicate which blocks =
are holding dirty data, so an ungraceful shutdown will lead to a =
scanning of the entire cache in order to determine which blocks are &gt; =
dirty.<br>
</blockquote>
<br>
This is a failing of DMcache rather than an indication that this<br>
problem can't be solved on the block layer.<br>
</div>
</div>
</blockquote>
<div><br>
</div>
That was my original discussion with Jinshan as well. &nbsp;There was =
a</div>
<div>similar issue with mdraid, and they ended up with persistent =
bitmaps</div>
<div>in a flash device. &nbsp;It should be possible to manage this with =
logs</div>
<div>or bitmaps stored in the fast OSD device instead of the spill =
device.</div>
<div><br>
<blockquote type=3D"cite">
<div>
<div>Overall, I think the concept is interesting. It reminds me of =
how<br>
Bcachefs handle multi-device support. Each device can be<br>
designated as holding metadata or data replicas. And you<br>
can control the promotion and migration between different<br>
targets (all managed by a migration daemon). But this design is<br>
too limited, IMHO. If we're going to accept the additional =
complexity<br>
in the OSD, the solution has to be extensible. What if I want to<br>
replicate to multiple targets? What if I want more than two tiers?<br>
What if I want to transparently migrate data from one spill device =
to<br>
another? We don't need this for the initial implementation, sure.<br>
But these seem like natural =
extensions.<br></div></div></blockquote></div></div></div></blockquote><di=
v><br></div><div>It=E2=80=99s possible to extend the design to have =
multiple spill devices in the OSD; you could have two spill devices and =
mirror them, or raid0 to make a larger device. I don=E2=80=99t see the =
design would not allow you to do that.&nbsp;</div><br><blockquote =
type=3D"cite"><div><div style=3D"overflow-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: =
after-white-space;"><div><blockquote type=3D"cite"><div><div>
</div>
</div>
</blockquote>
<div><br>
</div>
This is essentially replicating Lustre file layouts in the end, =
which</div>
<div>was my original suggestion - to use FLR and/or PCC-RO foreign</div>
<div>mirror layouts for this, even if it is not directly accessible =
from</div>
<div>clients. &nbsp;That avoids reimplementing tools/formats that =
already</div>
<div>exist in Lustre today for relatively little =
benefit.</div></div></div></blockquote><div><br></div><div><br></div><div>=
One of the goals is to not have a file system-level scanner, which is =
not good. Otherwise, we can just use FLR-based tiered =
storage.</div><br><blockquote type=3D"cite"><div><div =
style=3D"overflow-wrap: break-word; -webkit-nbsp-mode: space; =
line-break: after-white-space;">
<div><br>
<blockquote type=3D"cite">
<div>
<div>I think we need to use some kind of common API for the<br>
different devices. Even if the spill device doesn't support atomic<br>
transactions, I don't see why we couldn't still use the common OSD<br>
API and implement the migration daemon as a stacking driver on-top<br>
of that. The spill device OSD driver could be made to advertise that =
it<br>
doesn't support atomic transactions and may not support EA. But we<br>
get the added benefit of being able to use existing OSDs with this<br>
feature, pretty much for free.<br>
</div>
</div>
</blockquote>
<br>
</div>
<div>Also my argument. &nbsp;Using the VFS directly is constraining =
(lack of</div>
<div>transactions), but of backends that _can_ be a full OSD (or =
already</div>
<div>have an OSD like ldiskfs, ZFS, memfs) it is a drop-in =
replacement.</div>
<div><br>
</div>
<div>There is already an OSD API to query the functionality of the =
backing</div>
<div>storage, so it should be straight forward to add "transaction", =
"xattr",</div>
<div>and other supported features to =
that.</div></div></div></blockquote><blockquote type=3D"cite"><div><div =
style=3D"overflow-wrap: break-word; -webkit-nbsp-mode: space; =
line-break: after-white-space;">
<div><br>
</div>
<div>If we can implement a no-transaction osd-vfs, that would expose =
a</div>
<div>lot of flexibility for other reasons as well. &nbsp;Possibly the =
osd-vfs could</div>
<div>implement a journal or other logging layer internally to make up =
for</div>
<div>lack of transactions, whether initially or at a later =
stage?</div></div></div></blockquote><div><br></div><div>What would be =
the benefit of having a limited OSD in the stack? I don=E2=80=99t have a =
strong opinion of not doing it, but I just didn=E2=80=99t see any =
benefits of doing it.</div><br><blockquote type=3D"cite"><div><div =
style=3D"overflow-wrap: break-word; -webkit-nbsp-mode: space; =
line-break: after-white-space;">
<br>
<div>
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; overflow-wrap: break-word; -webkit-nbsp-mode: =
space; line-break: after-white-space;">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; overflow-wrap: break-word; -webkit-nbsp-mode: =
space; line-break: after-white-space;">
<div>Cheers, Andreas</div>
<div>=E2=80=94</div>
<div>Andreas Dilger</div>
<div>Lustre Principal Architect</div>
<div>Whamcloud/DDN</div>
</div>
<br class=3D"Apple-interchange-newline">
</div>
<br class=3D"Apple-interchange-newline">
<br class=3D"Apple-interchange-newline">
</div>
<br>
</div>

</div></blockquote></div><br></body></html>=

--Apple-Mail=_44A77994-14E6-4B71-8FCB-73DDA2890107--

--===============7808215221663793929==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7808215221663793929==--
