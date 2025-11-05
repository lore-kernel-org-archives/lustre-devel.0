Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9DF04CCFA04
	for <lustre-devel@archiver.kernel.org>; Wed,  5 Nov 2025 00:36:50 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1R400j9Hz1xM5;
	Tue, 04 Nov 2025 16:27:44 -0800 (PST)
Received: from mail-pf1-f172.google.com (mail-pf1-f172.google.com
 [209.85.210.172])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1R2R3CsTz1wmd
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:26:23 -0800 (PST)
Received: by mail-pf1-f172.google.com with SMTP id
 d2e1a72fcca58-781206cce18so341212b3a.0
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:26:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=dilger-ca.20230601.gappssmtp.com; s=20230601; t=1762302305; x=1762907105;
 darn=lists.lustre.org; 
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:from:to:cc:subject:date:message-id:reply-to;
 bh=EZblfMJhNTQEuXHbO352xtzsxWCTtTQ741FiQ+LpRCY=;
 b=ONZmEqEfiQ9GdEt+J5nQwzjhMA1ShZTid9oGSdg6z0joGuRgyIW4t6x8DrfeMyAjPr
 hcsRvrMenXzF/Vo1QD44LookBF2Bau8AJ4IaFhxryesWMmu4yh6thyfKUeSLkLXPqkrz
 sPur3TOfP+NmpYhl6kckh1kFdNvXT9dpFsXxklhiP/ZuAQ1CJyMZwd3VMP/c/D1KwgFo
 tfFVDwRpb63Fl10UBdT39uQLGlV3D5ZPohqt/ayS8EyK3+PzTRgiJgyRbODNNPL+YRz+
 QDyz7wJiZ7+x+IOFPETg3lpR00bHn1911tRRa76xoCO5wPDiSsXXPmRDlJSFef8wMXRi
 HKYQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762302305; x=1762907105;
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=EZblfMJhNTQEuXHbO352xtzsxWCTtTQ741FiQ+LpRCY=;
 b=GY74uQOfJtZj3P3wpnmWdL5o8cp20TLoLf87uP42Aw0XHogjh0qlvOD5NEwrS5uAMo
 /7/kpad0jdstNUj4QcZbPAOrYrm0JMLS/om10312cURe48QJRL1AITCtwQy44vDRtWdq
 AbyhJtVEWp68JsKzE5FC/xzjiHvzZ3pehycNtmOe6yBT636HxNbNcyxkY6KBpzINr0ke
 g1jKEW42M5N2Byyp9RQ1I7hN8pd78PbmkM1UDZvJQ4S+r0ugJfVU5DrHoEN4zXOnLJy2
 H8DuyqDGgNJRwKPnKiIF4QGNoMD4nfTuCVQhb7DlELIHR8IY07TYEA0UO1cD+LEoGuMw
 wiAg==
X-Forwarded-Encrypted: i=1;
 AJvYcCUh9cEvWuZHgu1ulWDQWuI4TqWOxAP4Nw+Sa9miBVThs6uTzYwWXTvnGZ+JGLOqqzt0W+1ycysKJYPD8tQ=@lists.lustre.org
X-Gm-Message-State: AOJu0YxhFdw/lXc3fotbIL1qpPBdAufSjd1Lzb2Us/v4Fbgh4xE3Pth3
 cIKk8rr2canUmSmWn6aSZch2Zg7x0JxlkOBmgopmJZ+VtF/0EliDM/LpF5+vC7ATDwM=
X-Gm-Gg: ASbGncvqsIf1R+vWWAdtf0Vx0smbWpGSdVR+qnH13tJUx5qiD+J6hLDrhFSnwRFL+hw
 XsIMjVEWo/ZMaIqzoA93Ng50fWj/sl26Y3A/qPL9Ra4mKQfc2TYaKK38bZbANCuOgontkFDLReS
 lYsWv4Yws7NebcgZW7Jl8qdjvXUMuv73sYBl6k+ia0++NEK31cIj4uaz5qzEY+sJf0nrMolRHca
 m3dQ3cQkpcIXHDBmc6kqemOnnG0lmfVQ9OPkhGQma/fRwzGadE0kvWQh+SdOWr3l6TzfXDuS4jk
 9iDO1La4mziPhC4cH3U+zx+BDUVK27xejcvll0r+kPOfTeQiom1JuoIcx3R2J3uGTnUuF9KRwS1
 rUngIzRSdbTzm8xrPqwyhqlBJZx8KSEIIUs0fBvw0zoW8UgzCO6veHk9eMOuN4EB7sVCv13azD5
 dGO2cfhdDC4Sm1Pe/SX2VETmnrD9gaJQmik6F+qrTHLHYbjQyHPfTRraAwqHI=
X-Google-Smtp-Source: AGHT+IGk8W0MFpsvQRfSmYi4COjEifoLRjjwlcsofzUbkJnEUTRWPQDrefmC0dTngj6YdVbcQVZvYw==
X-Received: by 2002:a05:6a00:4188:b0:7ad:8299:6155 with SMTP id
 d2e1a72fcca58-7ad82997336mr3021335b3a.2.1762302305243; 
 Tue, 04 Nov 2025 16:25:05 -0800 (PST)
Received: from cabot.adilger.int (S01068c763f81ca4b.cg.shawcable.net.
 [70.77.200.158]) by smtp.gmail.com with ESMTPSA id
 d2e1a72fcca58-7acd382ab30sm4285519b3a.24.2025.11.04.16.25.03
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Tue, 04 Nov 2025 16:25:04 -0800 (PST)
Message-Id: <706AC712-F619-41CF-BD57-E12E3733F458@dilger.ca>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Date: Tue, 4 Nov 2025 17:25:02 -0700
In-Reply-To: <CAEp8vpi9nRVkBUes8-0RE9YFr7AUPUM+L4AU73UcVU_e6t3ehg@mail.gmail.com>
To: Jinshan Xiong <jinshanx@google.com>
References: <85EBE389-4753-454B-9735-B57039CB003A@amazon.com>
 <2AAB29BD-39BB-42E7-B142-45EA006571BD@ddn.com>
 <2820AB7F-9276-40E2-8C51-C62C9304B4B8@dilger.ca>
 <CAEp8vpi9nRVkBUes8-0RE9YFr7AUPUM+L4AU73UcVU_e6t3ehg@mail.gmail.com>
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
Content-Type: multipart/mixed; boundary="===============3660117411898333425=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


--===============3660117411898333425==
Content-Type: multipart/signed;
 boundary="Apple-Mail=_CD2AE2A5-2704-4FA0-BAA2-08E5FB79F8E5";
 protocol="application/pgp-signature"; micalg=pgp-sha256


--Apple-Mail=_CD2AE2A5-2704-4FA0-BAA2-08E5FB79F8E5
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8


On Nov 4, 2025, at 4:54 PM, Jinshan Xiong <jinshanx@google.com> wrote:
> On Tue, Nov 4, 2025 at 3:48=E2=80=AFPM Andreas Dilger =
<adilger@dilger.ca> wrote:
>>=20
>> If the overhead of a local Lustre mount on the OSS is problematic, =
that
>> seems like something which could/should be fixed?  The local mounts =
are
>> already "non-recoverable" so that they do not get an entry in =
last_rcvd
>> and their absence does not cause any recovery issues.
>>=20
>> The main issue we've seen with local mountpoints is that this can =
confuse
>> HA and prevent Lustre module unloading if they are not taken into =
account
>> during cleanup.
>=20
> You're right. That's actually why we didn't do it in the first place. =
If an OSS crashes, it will definitely lead to recovery timeout and =
client eviction.

If an OSS crash with a local mountpoint is causing recovery timeouts,
then that seems like a bug to be fixed.  This was changed by Alex Z.
in patch "LU-12722 target: disable recovery for local clients" back in
commit v2_13_52-45-g8bd04b4e57.

Cheers, Andreas






--Apple-Mail=_CD2AE2A5-2704-4FA0-BAA2-08E5FB79F8E5
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAmkKmV4ACgkQcqXauRfM
H+DL9A//SVZEAF5L+hSl1CgmC26UM9mvyuBQ8DFFaIhlgXDkSEvW+788IQNRvkte
sEoX8PCtEbPrdNcRPTdK07Y+hSk23+lplyRnu00Gk+loiNfuYToTGdmke626OZof
oX5FA04TrDTahOPsJyVmi5GtUuWgyeemcNnCKd+fnhyV62v2eTYZq2OHYlhoEtKO
YtVEKokjiRjlnoGQS6NroGGoS89BFI4e1fzyju3qpTOzv0sc1J6YRHsApOb1jFdU
8W+m8UH2PSnU4036en5qvCkKbf5660VTinBybWoYWNFf/ZhpLmJu+Lon/GuNwAGV
RwFfPcuKN+jMuYrsZiMdKB7x757IcNg2TNr942iYzrQU4BYVHHWkclhYZX3eWhFR
LnXhJneO9wH1l2IeIF40SEWcpFBIlorCF+tE2KPmdH2Xis4DURguR/sI/slgSFTk
xsXxXRbVPdZPYUeK7ou19TgVrLKdYUEmSvpUFVOm75Exy/KkWT1KqhdDZ6JUj1d9
+Ugcm9G5Gg8iDynaSe2pU6hY+y475BprzwxcxYVPIwNUc1xJA/wzD9AqwCsy7JHG
2Kn/qOUjbE5PM/CTmGxtdn9i4AjFctBKTb3tX6o8Hz5QWxo48KfCZhBzBcM1/0Av
lyBuKaXBx7e+L+TFEhb+R5qEj50Hgq4O328TFoxNoOEVQ/Re3f0=
=vpi5
-----END PGP SIGNATURE-----

--Apple-Mail=_CD2AE2A5-2704-4FA0-BAA2-08E5FB79F8E5--

--===============3660117411898333425==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3660117411898333425==--
