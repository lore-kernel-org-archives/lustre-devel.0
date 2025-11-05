Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 10CC0CCFA04
	for <lustre-devel@archiver.kernel.org>; Wed,  5 Nov 2025 00:57:16 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1RXM5zZ2z20dn;
	Tue, 04 Nov 2025 16:48:51 -0800 (PST)
Received: from mail-pj1-f51.google.com (mail-pj1-f51.google.com
 [209.85.216.51])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1RVf4Cp9z1y4F
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:47:22 -0800 (PST)
Received: by mail-pj1-f51.google.com with SMTP id
 98e67ed59e1d1-33b5a3e8ae2so308008a91.1
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:47:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=dilger-ca.20230601.gappssmtp.com; s=20230601; t=1762303607; x=1762908407;
 darn=lists.lustre.org; 
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:from:to:cc:subject:date:message-id:reply-to;
 bh=SdZHrtwcvZRo/aPse//iPe23dVYdPlHC6ylqpNjeu1I=;
 b=oP58yhCkY0NbIJ1Y0Mu38W0dF9Eh2szeiiN6dEPbi76TSfej3hB7J+0oRW+0ob7GjC
 dcpaMD0m8n4R0fZJeQoqv+oXCYfwH6+GGzwlOrEjzWDRCpP9JHdjilgy2k5j+/SC7jpV
 xqsBy/ze5TOS0AAA5qPD1uCcFbGBi1nB9lzKIzEx9igeznuKI4zdH/mzDbc/IFlSDLTN
 8FaKWr0Vca0x7ttzZr9RPscDd+fvNT6kCzc0dPNbeAAUJENT+mVsvjq++Cdi2Ftj2WHd
 v/ZpPX5HimhpsL+kx991ds7iq0Utmngzy2HIVJOc49zI6Vn83PEVz9jhXtyvpFcuABA/
 ZZhA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762303607; x=1762908407;
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=SdZHrtwcvZRo/aPse//iPe23dVYdPlHC6ylqpNjeu1I=;
 b=lLdmEkU1WhNwzJNbjayzy6OBh5jUuhsyktTq8Pjon4NpciuO50H/bThDKYz9JjuT5i
 wXPrA7w07NptxrBSytfEBq1IwBT8LgVCHPXDvtvr8scv3Yl0ISdTcIyxX1q3dMxGDsfN
 nsWq/3nE8hSMU6KIaVEmHhhj/6fY/Rm43vZJm7GttokvhuQus3uhvsHYC/rfpW/+hCNh
 5Xy99CUsVzxs5BNSqMd3WiRhLiW9sOSrCKTWv7i5+TuLV6ok1/Jvf26M9AO+qRSSHoSL
 VcI2YiClFzRiKy4kRoj1KPOGDwie2VcOi5CEM49tcJ5w8fHExrnIwPr73gFrgjqN0y7p
 Ie0w==
X-Forwarded-Encrypted: i=1;
 AJvYcCVCyh5QVhw0y0U+dyvSdlHZsXm5Rj1QhXZ68+GGI3t/By5mn2ub/1kEtIdNaAn097PWe5Bd3EVdGC9nbVI=@lists.lustre.org
X-Gm-Message-State: AOJu0YxFmI8M+henMJQbbH7uanI1y58CvI8wtgmDFE2EelDA4pHNJMKT
 vYOzU2kVhxmfkie7kd+JNqYRVdjV4CC1I+45lbRGvF1J3nOidiajWVA+we6tXNyvA9E=
X-Gm-Gg: ASbGncufMPWK17EfuIqBsvn/o91YZJQw1CkV+6nK3N/jqI6oicfXr4eiExIcUcsfN8e
 UT8+Bvyb8J9KWnjgr6HysiN0CR3bYjUACfySgUcgNdvU5WQkRAg/lkYf6Ntt/GDEGcGkaZ05pv9
 9751cjPdb1sFrm3G/OFxNi6qUUOgMfUXkpPV9h/Zwamn07GZ3haFR1ymKNXUnDjLpoz0RLj1FSh
 fw9rYs10JbZIecs4s0nTfLqPQMH0fxw/889+MVQa59yaboedFlv/YvMFAvRwej0SW3IS55BRboY
 dPqT0GfqqjLOfioIZGo8zZ5Tlj9dj1DreJXVElAJHAAX8v6iM0uzkyx+dbWBPkc3yZodv2dQYLZ
 LoaOWzsaaX7xTS78Bzvz0MXOgTb2U0mH83fUEpBKhxbHaf2WIYgY4P/fl260W0viBD0HqFREqrN
 NMquODfHkm8bEGbmQM/OvcNYdWV5uR1Ma/Rhw+JrIqvHJrGf4HCmXZoA1sKqg=
X-Google-Smtp-Source: AGHT+IEPQAm3lSfimsbeeyzinYSwaed+6jndG/nVCestFBJoGObEiU8VgVUDYhsS+ZxtqRX7wrF5fQ==
X-Received: by 2002:a17:903:1a67:b0:295:28a4:f0ba with SMTP id
 d9443c01a7336-295f94359a1mr65011045ad.14.1762303606944; 
 Tue, 04 Nov 2025 16:46:46 -0800 (PST)
Received: from cabot.adilger.int (S01068c763f81ca4b.cg.shawcable.net.
 [70.77.200.158]) by smtp.gmail.com with ESMTPSA id
 d9443c01a7336-29601a381edsm41197545ad.71.2025.11.04.16.46.45
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Tue, 04 Nov 2025 16:46:45 -0800 (PST)
Message-Id: <E296EEC2-800E-4C85-9764-2854D5ED26DD@dilger.ca>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Date: Tue, 4 Nov 2025 17:46:43 -0700
In-Reply-To: <CAEp8vphfZW4CjgQpCQi6yDBACoTP_3n-5EAFckrOi802_Ajmjw@mail.gmail.com>
To: Jinshan Xiong <jinshanx@google.com>
References: <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
 <0092A54A-6EEF-4CD3-8AFD-7B0066A08810@gmail.com>
 <D8E0F0C0-1A5F-413A-82EA-F3CFA473D2E1@amazon.com>
 <28B74585-1877-4A33-9218-FD50AE72D33D@ddn.com>
 <74326E79-3FCD-41F5-B5DA-95EA2CC48435@gmail.com>
 <A0DE1BFF-A1D4-4104-8333-E6D771F46713@dilger.ca>
 <CAEp8vphfZW4CjgQpCQi6yDBACoTP_3n-5EAFckrOi802_Ajmjw@mail.gmail.com>
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
Content-Type: multipart/mixed; boundary="===============5975551429210522294=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


--===============5975551429210522294==
Content-Type: multipart/signed;
 boundary="Apple-Mail=_15B6F48A-53CC-4BDC-8EFD-7DF39AEA8412";
 protocol="application/pgp-signature"; micalg=pgp-sha256


--Apple-Mail=_15B6F48A-53CC-4BDC-8EFD-7DF39AEA8412
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

On Nov 4, 2025, at 5:28 PM, Jinshan Xiong <jinshanx@google.com> wrote:
> On Tue, Nov 4, 2025 at 4:20=E2=80=AFPM Andreas Dilger wrote:
>> I don't see how the layout xattr format is related to =
filesystem-level
>> scanning?  This is "just" the xattr format *STORED ON THE OST =
OBJECT*,
>> and it could be handled by direct device-level (OST) scan tools as =
well.
>=20
> I see. I initially thought you proposed the spill device would =
function as a mirror and that the existing software stack would handle =
it.
>=20
> Are we going to store the spilled object's status in the layout? It =
sounds difficult because you will have to initiate a layout change from =
the OSTs. I think we still need to store such an xattr locally in the =
OST object.

I'm exactly proposing that the layout xattr be stored on the OST object.
It would have the same format as the existing Lustre layout stored on
the MDT, but *maybe* a different name (e.g. "trusted.spl", =
"trusted.osd",
or whatever).

I'm not sure if using "trusted.lov" will confuse filesystem scanning
tools or help them...  It probably makes sense to have a different
xattr name, just in case we want MDT spilling (e.g. NVRAM->QLC) in
the future.

>> This would allow mirrors (FLR), multiple spill devices (multiple FLR
>> mirrors), concatenated devices (PFL), etc.  It just avoids adding new
>> formats that need to be parsed, printed, etc.

Cheers, Andreas






--Apple-Mail=_15B6F48A-53CC-4BDC-8EFD-7DF39AEA8412
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAmkKnnQACgkQcqXauRfM
H+DAmA//XcaDBRhzNmwwozpOOIZh1F0BLJHdLnapYos71PiJolKEbmedU2DwNxF0
Es5ORpWJOyLuZ1QMk5THHsZwPr28Glgg19Dm3Q3MuY9x9v8nUZ38lCl83aoOdX45
kTcEMZadqaLlsyrts+zCOzRpB4gs8/omGTkEw0Pw/MHWrCM/JnuuwhGXE1uk1KHU
/KRlZReV6fzMuhoVAXEUULJFdpNtVVbaO1jUlG5Y00+NiNPGYrd9WVO2RAr1vUnZ
TBX9RjZ4GGSlsYDng3lKKR0mqizGQWzbjSq9m6O7Fzl14TH+Lkwi06BitOS213lx
eBvyRmAWQUp4zrr8ZqwwTNDTLDcnQdl3WZEc25THLWcT9983sZuQVYnKFn5cZkjz
gJdKUzoj1zZ7SYj2p0IxEgMKqzwfvR/VUDvX31VjdDScnzFB8lIgo4rQzhonCa0w
ZC/y5CpzlOPOa1yzd8aK8pPSXh6+L35HzE0I02BJo2eNSQQB2YQyhJj0yFJFgFe9
JYGXMkpOvpeVsotFKLH7cGtB/LOuJSNaXLovV4cuQ9MssWQDIkYiQMKMjdfo+EQ4
pvAR8ISCpZNxtk5ahq/iCxCK9NMebdWdO/xIP3wC++OV/IRN0uxudGJ8BVwkbCmx
kujKcsH0bnOrw4FDqrZZe80VPnSPH8CSxL2JUYOtL5RCdEGLQ8w=
=qjvQ
-----END PGP SIGNATURE-----

--Apple-Mail=_15B6F48A-53CC-4BDC-8EFD-7DF39AEA8412--

--===============5975551429210522294==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5975551429210522294==--
