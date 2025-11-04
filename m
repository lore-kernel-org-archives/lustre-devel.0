Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 83F07CCFA04
	for <lustre-devel@archiver.kernel.org>; Wed,  5 Nov 2025 00:05:37 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1QG23sthz20fk;
	Tue, 04 Nov 2025 15:51:22 -0800 (PST)
Received: from mail-pl1-f180.google.com (mail-pl1-f180.google.com
 [209.85.214.180])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1QFs2yd7z20dm
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 15:51:13 -0800 (PST)
Received: by mail-pl1-f180.google.com with SMTP id
 d9443c01a7336-294fc62d7f4so58778995ad.2
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 15:51:13 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=dilger-ca.20230601.gappssmtp.com; s=20230601; t=1762300133; x=1762904933;
 darn=lists.lustre.org; 
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:from:to:cc:subject:date:message-id:reply-to;
 bh=GqNZdBa+pp56L1TiBR6JlGSpcBAXLB8KOqgERWeGdg4=;
 b=fUuCdIBqAQ0FY/ZebmO6itfukiCXlSTXaPg1O0Z+p0KLMnkHdOgP4P0jlGdKv35shG
 CLXO0G+HDzbCnK8pPRAmP/cJcky+b20qRme6E7K+iYe9GTwLEqyr1NvfZFcNq/ZhfEOs
 Pf9t7/FwkfXWOHMHGEK+BD1nH027j8+n2qFSZeKT0lx/wf1UEEusmIcKkQrG49Abs9vs
 BHIJJGT/4o7WbYeQoBXh1RMS0ExkEuD4R9+P4i6J2vVxyy8pT6HRttg7a3NTEQivvCb2
 dV2CFqa5prl691C8jbf7yYHqB9THjGrTtkLLxVoKjtqD5CH/iQDkGj+OTxcfymsenv6z
 rSPQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762300133; x=1762904933;
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=GqNZdBa+pp56L1TiBR6JlGSpcBAXLB8KOqgERWeGdg4=;
 b=p/kpFzMJbOQAnV1TFkrJpX+TDqvLuzEYAb3Q/8VtDoVL/xyxokNvi1ACZYbnq/UxH6
 bJ35IL+YLJpNlWkElrFAZNm6QgFARSflK9d9o8W4hwK2CA6j8reoc/qTy4FoQUnMLga0
 QfxqdptTnnx4JC+XL3VpZfjlKz385RmDBtA8nw7TPWbXGBXkjVkGlBQ5a7e5y4W8S/nx
 cbG7n+kVigLENrY0pWXOOrajinJI5qmYJmaHBuOcf5yyuQpSHpjQ7pxpLMGTUKrg1O1Y
 6cIsGH8yk8H9dv9kQfsgjlW3lkoI6/p9jLA1Mn+DuWOePkikAoK0cXXL2uDqexBFBQNd
 WVbg==
X-Forwarded-Encrypted: i=1;
 AJvYcCWz19t2e/xQPbDG+3aZngjmq3+6WXkc7CqQabMHaE4MRyd0Pue4jjHgJUJLe1B9lwKGYpt5SsgLFFYCpTY=@lists.lustre.org
X-Gm-Message-State: AOJu0Yws91tXP35DnBn/fsCkVIFODvq6j2sBsXParwxXwJRknMPUJ/lK
 yf+5ZA6VLl14yob3Q7+SVpuH51m0eRH0SCW644qxlbzK/GS3ic+36Q+m7oVa9KVimf8=
X-Gm-Gg: ASbGncvbbrF/OdVQSakMneOV8EZDEJGXJPxVQf8VCOxiKl/kXhysdEHk+P9w7eyPy48
 E+DfJlOMfgAgztPcQNZcvkh7qb+1+4RazNZOojWTVruGEn6DfPCCO8DmZ3gxXP4e41cHsfJRJt1
 +/vIFrVdPLuXpcAwpy6KdtKJ0RJxv+56qFE5ObdAmTWmhdO/n0b2p0OzTbLyiLmPq7ka99mzSPO
 55K0R3gl5WDU1jCEoDEUPwRvoEEGRkeaqt09qC6x7/HUvzFAq1HxDm5fCGD8c41lST23rzBacTI
 oD5aQigsF+0VDxar8l0AWwtMglvpmpDOjpq9Af/jDSpHE1JfKviP1RNnMO+PaKd5HTvLndyHd8L
 NLgcyL6GVyC0XNyx4uRfcYojMS8QwAlunVDOaqHLuuad3KbMnywkbOGCNqvR0xwfrGDSKoeRr6y
 rRR7HO7tdkrTRgAs0C/RvVnd6DTCvLLgitTl7HEnMOtQJuhf8Y
X-Google-Smtp-Source: AGHT+IEd8092wq9cGEEIKGebnoR9vr19CDt0vWJhobRCjg6RPlJQtKG+YKv3Ni6R0zo8AeIhxSjnrw==
X-Received: by 2002:a17:903:3d0f:b0:272:c95c:866 with SMTP id
 d9443c01a7336-2962add9ff7mr17518815ad.20.1762300132597; 
 Tue, 04 Nov 2025 15:48:52 -0800 (PST)
Received: from cabot.adilger.int (S01068c763f81ca4b.cg.shawcable.net.
 [70.77.200.158]) by smtp.gmail.com with ESMTPSA id
 d9443c01a7336-29601a5d202sm40432045ad.78.2025.11.04.15.48.51
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Tue, 04 Nov 2025 15:48:51 -0800 (PST)
Message-Id: <2820AB7F-9276-40E2-8C51-C62C9304B4B8@dilger.ca>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Date: Tue, 4 Nov 2025 16:48:49 -0700
In-Reply-To: <2AAB29BD-39BB-42E7-B142-45EA006571BD@ddn.com>
To: Timothy Day <timday@amazon.com>
References: <85EBE389-4753-454B-9735-B57039CB003A@amazon.com>
 <2AAB29BD-39BB-42E7-B142-45EA006571BD@ddn.com>
X-Mailer: Apple Mail (2.3273)
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
From: Andreas Dilger via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Andreas Dilger <adilger@dilger.ca>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============4765799903348919190=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


--===============4765799903348919190==
Content-Type: multipart/signed;
 boundary="Apple-Mail=_CFD9DCE0-39DB-4B7C-83B6-1A80F1DA3B31";
 protocol="application/pgp-signature"; micalg=pgp-sha256


--Apple-Mail=_CFD9DCE0-39DB-4B7C-83B6-1A80F1DA3B31
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8


Timothy Day <timday@amazon.com> wrote:
>>>> I haven=E2=80=99t seen any mention of failover yet in this =
conversation (may have missed it), but if the device is truly local, =
then in failed over configurations the data is inaccessible.  If it=E2=80=99=
s *not* local, why not just make the device part of the OST or an =
independent OST?
>>>=20
>>> It won't be local. Actually, this is designed for the cloud.
>>=20
>> I don't understand how 'local' is being used. Cloud or not, all of =
the
>> Lustre client, servers, and backend storage service will be =
co-located
>> in the same data center. I think Patrick is asking whether the spill
>> device will be physically connected to OSS server, or be provided =
over
>> something like SAN? Either way, presenting this device as an =
independent
>> OST brings back the pain of manually managing data placement from the
>> client - which this design is trying to avoid.
>>=20
>>> We already have tiered storage based on mirroring; however, that =
still requires clients to move data and a file system level scanner to =
decide which files move to the cold tier. It's cumbersome to maintain =
those clients.
>>=20
>> Agree, it's not ideal.

Regardless of how the spill device is implemented, there will need to be
some scanning of the front OSD device to find/manage objects to mirror
and release.  This could be done directly on the OST with something like
DDN's lipe_find3 utility, or older scanners like lester, zester, e2scan,
etc. that scan the local ldiskfs block device directly.

If the overhead of a local Lustre mount on the OSS is problematic, that
seems like something which could/should be fixed?  The local mounts are
already "non-recoverable" so that they do not get an entry in last_rcvd
and their absence does not cause any recovery issues.

The main issue we've seen with local mountpoints is that this can =
confuse
HA and prevent Lustre module unloading if they are not taken into =
account
during cleanup.

Cheers, Andreas






--Apple-Mail=_CFD9DCE0-39DB-4B7C-83B6-1A80F1DA3B31
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAmkKkOEACgkQcqXauRfM
H+B1WA/9GOZTaF+O/tDNieheQUXL/60uKzKtzruU4tL1fkDsmggal1+mfpR16+6u
5zq5DRcDlzPYw3xsdD/39iAOr6JocLabUZ2mVWT0ILRXsXY8scyOKYCOigvYxXi0
I2CBnZBMZhfnuX1BnYkBkUznwWVrg6b9amhJb8zfpuDfbgLY9m4ZZOO+66SZP/s5
EYDa6AKn6mA2iNF4yBDhXJxVmJiNYfplule8V3vFtLCdcsxso1gp8tc6FGXWj+CF
hb9h6yoZyxAjpn+LjuxBUYmTgXiL3qOE1gixHBzMt3gyZwlGcKVWSeI3eDmCZ+K3
Ez7Oqn27YPK1j/ZGDldwUpvQcHztrfabtKjqKTdbIViKOT37458/z6K1yLTio/fP
YoXhpR7ShuX/zCQmqvfOCXxilmmPF1kBj4CNb0pdoMEwMPXtV7zfPR9ZXfhw1pPS
8DfpPq6iaNLlFGXmSH0j2ORkDFc002lHxBAMIksPGcUP3L+bFpoOtB/QQJuHjJXo
qoEuYOWLwksuXofAibH+oLY52cp7cCjwWmsjNIA0F9f/KdZUaWrNHbjeu7ijdawH
70GuqPjI2KKhjguwMkr8eKtF0bQAnUqZmKVeVZESDCBTQqEjcbW6THlNEtTKax10
Xinm8Qysd5PWR/8UPq+bTrVubceOu/hLqnZVGmN8kv9VHGOPOuI=
=Iruv
-----END PGP SIGNATURE-----

--Apple-Mail=_CFD9DCE0-39DB-4B7C-83B6-1A80F1DA3B31--

--===============4765799903348919190==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============4765799903348919190==--
