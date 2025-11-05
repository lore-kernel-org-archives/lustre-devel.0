Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 760C6CCFA04
	for <lustre-devel@archiver.kernel.org>; Wed,  5 Nov 2025 00:19:24 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1QsH3CRCz1yDJ;
	Tue, 04 Nov 2025 16:18:27 -0800 (PST)
Received: from mail-pl1-f178.google.com (mail-pl1-f178.google.com
 [209.85.214.178])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1Qrx4yT2z1wmd
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:18:09 -0800 (PST)
Received: by mail-pl1-f178.google.com with SMTP id
 d9443c01a7336-2947d345949so54860305ad.3
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:18:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=dilger-ca.20230601.gappssmtp.com; s=20230601; t=1762301886; x=1762906686;
 darn=lists.lustre.org; 
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:from:to:cc:subject:date:message-id:reply-to;
 bh=9z9Ho/etU1joOBgTn/Zocd87kWFHEY7L8VzZVA7vKhs=;
 b=OmzCMUTR+F68YBgiaUTmdUQWKEYGVsG/mKQt3iV18QopLx8B7FcPVQEurzq1JE5PWF
 SEKSX3kz2YynX5PJ5gNzQfxNfcf3Xe4hF5++2Et4x//6evnPlgRKWMl5rMQP6Oh0RSAN
 LnDtZ74rKfDjxsxIbUZ+fEiZ684++6MBpvEkwZIg4SCg9hY+X3eITGdxVldRRObMshps
 PRE2kGHfv5ZMmeiXC/WjumVvuSOC9YUZYvwQZMTy1jdSceOa18HtyH8YR+zWGuFoQcW0
 WL+wptXj+qUb61B1lUwprudtmlNivSQjq6K1+Q/K4WPMncr1AFWOCVLJHGu/jjYh+Jca
 l4zw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762301886; x=1762906686;
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=9z9Ho/etU1joOBgTn/Zocd87kWFHEY7L8VzZVA7vKhs=;
 b=C2Vo8brhWvRBbzq6sNxqrLIbfy+YYdYFuZly1zEP1Gm1+QZdcEWH3kZ8iyQWqDtTk2
 oMhsQLDn9RQsRPhSbkVqhimS4jc7/lJpSoGW8kWDH2AaEBYnaAatRn4j80eGO3ILM6sO
 6Vth2ADC6aLX0kPuQjtKbVYZdORl/eATgB19WWXT6jjlBXof62zk4UsuM+JtmegRKxMe
 WFYPy3Slx6vpvpKky6ZXWKlWY/AFMbO6MIySGmGhLbrKQnDqAaIdzzCziORJ7Hdc++18
 fHJRMi34TjrGhNkNVzcQ3h/sTYZ/3Jov6xPN5majndGhNB8wLM/aGEIg88Rc1hJ802H+
 BP6A==
X-Gm-Message-State: AOJu0YxPSERarEXBrwJBxspsapZ1lZjxsKctb1k3Acx+dta5SKaFwVMJ
 PYL/2b+j5mzLIY64bjmcdxT4A/+8rTQcGE1wLXLCUGxFN0ReLrCK9uaX6Cls/3aSPg2UnX5+OAs
 ru7tY
X-Gm-Gg: ASbGnct5OvFj9AiG5eOs9ya/d50jZ6mxnqOtVJ0etph16ICuWSeZ7mVuhuf1Aru2AJ2
 EecrnyLeOc4DD107xrLYckNny5sv6L+41UB1c1H8Jo5naOtO57/KxuxJ1cHQw0fkNmvYn6vMXeD
 w5t5NdlR4INcLZL1oUyclbo7WZ42YQeqKf8z590xbPbfkThYm4aSpLGRCjY+2yVBsj9W/wOUsQr
 LdGK65koNUL123Yhw8dX1sEEbICQEDjQICggwWK/qUmnHf1QpyqAGcKTMaC4FL7O8xEB/5scG8M
 ZhMHb6gScj/bMf3yq+2VIhDpJx8oMOd5KwEZwVFPZ9iO/El9hxQDF2G7F8N/MmK0uVclzGBO57/
 PUQ2ucGZqoOpFZBQ/Rt8E4/ItiMuzShhgLfhHXzhFvxvkiefUjXyMouCjUY26x/GbA9LzM6W7kM
 bnKN4KfdM/mHBYm7gvf101tA+x4/HXDDCS+0mIzCW9lYHqBsmzFGSf1b+W7Dg=
X-Google-Smtp-Source: AGHT+IFTwqku6I7PpYAEvSny+EhX5H+NfYqgBF8s6osOYV15vH+H0bnq5KAb1LpGKs0yuwZikXNZ5g==
X-Received: by 2002:a17:902:db05:b0:295:70cc:8ec4 with SMTP id
 d9443c01a7336-2962ae99122mr16618895ad.51.1762301885523; 
 Tue, 04 Nov 2025 16:18:05 -0800 (PST)
Received: from cabot.adilger.int (S01068c763f81ca4b.cg.shawcable.net.
 [70.77.200.158]) by smtp.gmail.com with ESMTPSA id
 d9443c01a7336-29601998878sm39742645ad.36.2025.11.04.16.18.04
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Tue, 04 Nov 2025 16:18:04 -0800 (PST)
Message-Id: <A0DE1BFF-A1D4-4104-8333-E6D771F46713@dilger.ca>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Date: Tue, 4 Nov 2025 17:18:02 -0700
In-Reply-To: <74326E79-3FCD-41F5-B5DA-95EA2CC48435@gmail.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
To: Jinshan Xiong <jinshan.xiong@gmail.com>
References: <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
 <0092A54A-6EEF-4CD3-8AFD-7B0066A08810@gmail.com>
 <D8E0F0C0-1A5F-413A-82EA-F3CFA473D2E1@amazon.com>
 <28B74585-1877-4A33-9218-FD50AE72D33D@ddn.com>
 <74326E79-3FCD-41F5-B5DA-95EA2CC48435@gmail.com>
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
Content-Type: multipart/mixed; boundary="===============0166530236277440844=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


--===============0166530236277440844==
Content-Type: multipart/signed;
 boundary="Apple-Mail=_4B4369F7-3D61-49D0-AFC0-D1012D65ED04";
 protocol="application/pgp-signature"; micalg=pgp-sha256


--Apple-Mail=_4B4369F7-3D61-49D0-AFC0-D1012D65ED04
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

On Nov 4, 2025, at 4:42 PM, Jinshan Xiong wrote:
> On Nov 4, 2025, at 15:07, Andreas Dilger <adilger@ddn.com> wrote:
>> Timothy Day <timday@amazon.com> wrote:
>>> Overall, I think the concept is interesting. It reminds me of how
>>> Bcachefs handle multi-device support. Each device can be
>>> designated as holding metadata or data replicas. And you
>>> can control the promotion and migration between different
>>> targets (all managed by a migration daemon). But this design is
>>> too limited, IMHO. If we're going to accept the additional =
complexity
>>> in the OSD, the solution has to be extensible. What if I want to
>>> replicate to multiple targets? What if I want more than two tiers?
>>> What if I want to transparently migrate data from one spill device =
to
>>> another? We don't need this for the initial implementation, sure.
>>> But these seem like natural extensions.
>=20
> It=E2=80=99s possible to extend the design to have multiple spill =
devices in the OSD; you could have two spill devices and mirror them, or =
raid0 to make a larger device. I don=E2=80=99t see the design would not =
allow you to do that.
>=20
>> This is essentially replicating Lustre file layouts in the end, which
>> was my original suggestion - to use FLR and/or PCC-RO foreign
>> mirror layouts for this, even if it is not directly accessible from
>> clients.  That avoids reimplementing tools/formats that already
>> exist in Lustre today for relatively little benefit.
>=20
> One of the goals is to not have a file system-level scanner, which is =
not good. Otherwise, we can just use FLR-based tiered storage.

I don't see how the layout xattr format is related to filesystem-level
scanning?  This is "just" the xattr format *STORED ON THE OST OBJECT*,
and it could be handled by direct device-level (OST) scan tools as well.

This would allow mirrors (FLR), multiple spill devices (multiple FLR
mirrors), concatenated devices (PFL), etc.  It just avoids adding new
formats that need to be parsed, printed, etc.

Cheers, Andreas






--Apple-Mail=_4B4369F7-3D61-49D0-AFC0-D1012D65ED04
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAmkKl7sACgkQcqXauRfM
H+B8yA/+IaycCKrzkPWcJp2mjTCuoCkvSe1y9dXnD4ujI4ot+8jCK5bOQQfVGzvL
xvUyOkifmUX4/eM3uZ61uzDeDEAEVUpXq0rSALIFWeldpP1bwLJlZo5kylL5g9mv
O0vpND7X1EhFaYgI+ePYFZOFN+MRtQyZj3g1YGCF7DjLjTufJlX0CUQFNNvWd6c+
f90zuLeOoHOju37cV6VlVCsQUMEVLUb3oDXhiFES/hU4Va5KIF3X57JAOwN7qr/H
dKNLq5mWoeGDnheMMKnJFhqUJ9Qbww6AOYN3qexWawNw3kYI2r3dh0rqAPJat2A9
weROmBfOgrpi4Ew/af/xgbtyJIIHKPx7iUHWtQtClJ0yhw7lGAxhC2g69Y15PvKg
TNXsr5iwXOVlv52s4wDNJOlcJjuMi0TQTM5WDtxjC2PpKYJnXtI5DgxKhImaAtAG
SdlCMle098FZga28v//AVaprWHLmHWyGhYdu/MTfWkJ5nISddNOyDhmz63pvq1dK
b8Vv2kUc6Dhi7AOws+Xfg+ibWLK2rkaRQ6ZuXUZpetmnvO1VzX43ySxgNQuQFtyi
/zZglU8yGmt3A6pIaOp+fbcw86u71NVtS6zYqAHCrqN+k4ywQ1OCCB4o4hw8wHh6
3AnkJnOfRPxbIsQoVt+WQViD7bjxO4bYSPIbFJpdTkYWCeyJnks=
=n50t
-----END PGP SIGNATURE-----

--Apple-Mail=_4B4369F7-3D61-49D0-AFC0-D1012D65ED04--

--===============0166530236277440844==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0166530236277440844==--
