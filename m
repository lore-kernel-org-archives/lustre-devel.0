Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4589CC77B7C
	for <lustre-devel@archiver.kernel.org>; Wed, 25 Jun 2025 21:55:17 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4bSFwZ4hP6z1y1k;
	Wed, 25 Jun 2025 14:54:54 -0700 (PDT)
Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com
 [209.85.221.48])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4bSFwV56Jqz1xq8
 for <lustre-devel@lists.lustre.org>; Wed, 25 Jun 2025 14:54:50 -0700 (PDT)
Received: by mail-wr1-f48.google.com with SMTP id
 ffacd0b85a97d-3a52878d37aso39718f8f.2
 for <lustre-devel@lists.lustre.org>; Wed, 25 Jun 2025 14:54:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1750888489; x=1751493289; darn=lists.lustre.org;
 h=content-transfer-encoding:in-reply-to:from:content-language
 :references:cc:to:subject:mime-version:date:message-id:from:to:cc
 :subject:date:message-id:reply-to;
 bh=nd22F8RPO8KPBO7ibf/tnHznQNN1Kye28U/H+UDwEwk=;
 b=hTI2Bdszto5k0UlQn9A9WDF7F/A0DDNXRyJDaY5qsggKIFbcS5IyO41u2rrsQ3NgSf
 6oiZnB+oPFIQWzEf2tG6njxCGPTQ2z1EcEMWYC/ZeyJnz0DYE6SXhm2zC1pyKk98L5kl
 lIvwvPV35ZwYIijv/68XhJu1MDKcV0S5TEbV2DP8o8YJcM0VlZawQUa+WrW2ReDwD9IX
 C8x5Cbsd9LjMDePKUJe2bnjeOL7bpJ+SRlSgZmch7sbCse8ghEKVKfIjLjngedJzqjUX
 zo+465Kh4hi03NX3IbMVFgQXqb6auHN5ju/dXFrVGMMPeMweNW0Q96gxLEF6xESG71ja
 RxYw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1750888489; x=1751493289;
 h=content-transfer-encoding:in-reply-to:from:content-language
 :references:cc:to:subject:mime-version:date:message-id
 :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=nd22F8RPO8KPBO7ibf/tnHznQNN1Kye28U/H+UDwEwk=;
 b=oHq0C5FEB0zD5PK17Jhm8tykt9czjuqJbI1BaLQVqjEF0OzlMUlkWtdNsiwmg17yUi
 LWw5d3rdBLMCE6n3NhTBMyVPNmfx5zRsTrBkYhmL+ykCQNBSEtJZvlmk33gRzbNHpU4E
 uUWznR9bHjpZ8dMrCJ9GjCx6iBgcmPB12GVmcOaUM1eKUU+8PvNRKGKvICgNpDcBkz15
 ZDS7tJUo4X3Fsr9hwwHBwouaR7f0oVJPubNkNc/P/ropfHZNavPdPFiZFlcPel+N5KTA
 6BWuuePiCJmQQoP64TfmobppTvUkvS2x8PjTZVwHqfRujyWk+CA7ukSpdPGXIYMIv8M2
 ES7w==
X-Forwarded-Encrypted: i=1;
 AJvYcCViVRdD6RDpZASPONsGPH1+3sZsV3cj+lxoTYGf+m62mm+absrDZchdlQ7Q1vEEZnwA+seQGnp8L1tjleA=@lists.lustre.org
X-Gm-Message-State: AOJu0YzKtihRQjoaNUpkk5/Wm06CjNgfBbvrINnw3wwqusGykPl7Ip6g
 703vXKF0rhIMiDGnfaBbLEL75jUfV+IfhGuV8gj8nOKSHkX447Nh6x4=
X-Gm-Gg: ASbGncsUhWGx2oLtAD+TBjAEe3GP+coeYi4122dVm+E8wb52CCWv8hxZtGlWzfD1ydE
 k5uWthfD5HqVef0CU/alK4uAY7yRzhsUW9AG0Muxq8Cj4OFPZLEDQDiaH3IBT2WHS3mB8RLdUXi
 a8iYugJssHGDKCy8x7MYFsPjZlMAiOeKvsKIhjQ023yvqkGBmltv1rZJ52SxMFhARrQlkPXpwOl
 9LkY4Q1uinFV9ESb4xtKhoUOkSGLqhzEm0Ez+16pComzgUtpEvLRPei96LN2CUsIx27CHoQ7jYk
 KU7dI4xBTCL8UKsNjP8kK33ouIrB2QoM98oRc5Uxzr4XFtWHJQaca5NqLyicpW+Bh91j84L6Z/t
 LfAwXJtRqAvGX23Bb9Bm8ZP+k+RSuYw==
X-Google-Smtp-Source: AGHT+IG66VQxmrB1Ku8mQ95/NPYs+qmMCH/90EzzpnbpOZ6KFrjAZOTMUgKUnJ6O9eRsoxspOfzT/g==
X-Received: by 2002:a05:6000:4412:b0:3a4:e740:cd6e with SMTP id
 ffacd0b85a97d-3a6ed64ccf0mr901571f8f.8.1750888488649; 
 Wed, 25 Jun 2025 14:54:48 -0700 (PDT)
Received: from localhost (238.red-80-39-144.dynamicip.rima-tde.net.
 [80.39.144.238]) by smtp.gmail.com with ESMTPSA id
 ffacd0b85a97d-3a6e8068d3fsm5601219f8f.37.2025.06.25.14.54.47
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Wed, 25 Jun 2025 14:54:47 -0700 (PDT)
Message-ID: <cf9555b4-53e2-440b-bffb-19a877783e64@gmail.com>
Date: Wed, 25 Jun 2025 23:54:47 +0200
MIME-Version: 1.0
To: "Day, Timothy" <timday@amazon.com>
References: <20250620195720.59870-1-xose.vazquez@gmail.com>
 <2698F449-3C9E-4934-980D-619A013EE51D@amazon.com>
 <3e7322b2-fa65-4850-a662-0d82c597b23f@gmail.com>
 <95604993-0061-4C2F-B362-B2394BE0656B@amazon.com>
 <DCC1FB79-F62B-4499-914E-9311E3E26221@amazon.com>
 <d9280a2c-1bd5-4c16-96d3-123068bdee6a@gmail.com>
 <9E6B7353-F81E-4003-89C1-7D89932694B7@amazon.com>
Content-Language: en-US, en-GB, es-ES
From: Xose Vazquez Perez <xose.vazquez@gmail.com>
In-Reply-To: <9E6B7353-F81E-4003-89C1-7D89932694B7@amazon.com>
Subject: Re: [lustre-devel] [PATCH 1/2] lustre: refresh FSF licences
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
Cc: LUSTRE DEVEL ML <lustre-devel@lists.lustre.org>
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

T24gNi8yNS8yNSA3OjQzIFBNLCBEYXksIFRpbW90aHkgd3JvdGU6CgpbQ0MgbHVzdHJlLWRldmVs
IG1sXQoKPiBUaGUgY2hlY2twYXRjaC5wbCBpbiB0aGUgTHVzdHJlIHRyZWUgaXMgZmFpcmx5IHVw
LXRvLWRhdGUgKDYuMTMtcmMzKS4gQnV0Cj4gdGhlcmUncyBhbiBleGNlcHRpb24gc3BlY2lmaWNh
bGx5IGZvciBTUERYIGNvbW1lbnRzIGluIGhlYWRlcnMgWzFdLiBUaGV5Cj4gbXVzdCB1c2UgLyog
Ki8uIFRoZSAvLyBjb21tZW50cyBhcmUgZmluZSBldmVyeXdoZXJlIGVsc2UuCj4gCj4gWzFdIGh0
dHBzOi8vd3d3Lmtlcm5lbC5vcmcvZG9jL2h0bWwvbmV4dC9wcm9jZXNzL2xpY2Vuc2UtcnVsZXMu
aHRtbCA8aHR0cHM6Ly93d3cua2VybmVsLm9yZy9kb2MvaHRtbC9uZXh0L3Byb2Nlc3MvbGljZW5z
ZS1ydWxlcy5odG1sPgoKWW91IGFyZSByaWdodC4gQW5kIGl0J3Mgd2VpcmQsIGJlY2F1c2UgLy8g
aXMgdXNlZCBieSBzb21lIGtlcm5lbCBoZWFkZXJzICg1ODEpLgpCdXQgYW55d2F5LCByZWNoZWNr
aW5nIGl0LCAvKiAqLyBpcyB1c2VkIGJ5IG1vc3Qgb2YgdGhlbSAoMjE1NzMpLgoKCkFub3RoZXIg
dG9waWMuClRoZXNlIGNvcHlyaWdodCBub3RpY2VzIGFyZSBvdXRkYXRlZCwgYW5kIHRoZXkgYXJl
IGN1cnJlbnRseSBubyBsb25nZXIgdmFsaWQ6CmdpdCBncmVwIC1FICJDb3B5cmlnaHQuKihDbHVz
dGVyfE9yYWNsZXxTdW4pIgoKQW5kIG1heWJlIGFsc286IGdpdCBncmVwICJDb3B5cmlnaHQuKlh5
cmF0ZXgiClRoZXkgc2hvdWxkIGJlIHJlcGxhY2VkIGJ5IHRoZSBjdXJyZW50IGhvbGRlciwgIlNl
YWdhdGUgVGVjaG5vbG9neSBMTEMuIgoKVGhlIHNhbWUgZm9yOgpnaXQgZ3JlcCAiQ29weXJpZ2h0
LioyMDEuKkludGVsIiAjLT4gIkRhdGFEaXJlY3QgTmV0d29ya3MsIEluYy4iCgpTb3VyY2VzOgot
ICJYeXJhdGV4IEFkdmFuY2VzIEx1c3RyZcKuIEluaXRpYXRpdmUsIEFzc3VtZXMgT3duZXJzaGlw
IG9mIFJlbGF0ZWQgQXNzZXRzIgpodHRwczovL3dlYi5hcmNoaXZlLm9yZy93ZWIvMjAxMzAyMjQw
NjMxMzcvaHR0cDovL3d3dy54eXJhdGV4LmNvbS9uZXdzL3ByZXNzLXJlbGVhc2VzL3h5cmF0ZXgt
YWR2YW5jZXMtbHVzdHJlJUMyJUFFLWluaXRpYXRpdmUtYXNzdW1lcy1vd25lcnNoaXAtcmVsYXRl
ZC1hc3NldHMKaHR0cHM6Ly93aWtpLmx1c3RyZS5vcmcvaW1hZ2VzLzIvMjUvTFVHMjAxMy1YeXJh
dGV4X1VwZGF0ZS1LZXZpbl9DYW5hZHkucGRmCgotICJTZWFnYXRlIENvbXBsZXRlcyBBY3F1aXNp
dGlvbiBvZiBYeXJhdGV4IjoKaHR0cHM6Ly93ZWIuYXJjaGl2ZS5vcmcvd2ViLzIwMTQwNDA0MTAz
NDE1L2h0dHA6Ly93d3cuc2VhZ2F0ZS5jb20vYWJvdXQvbmV3c3Jvb20vcHJlc3MtcmVsZWFzZXMv
c2VhZ2F0ZS1jb21wbGV0ZXMtYWNxdWlzaXRpb24tb2YteHlyYXRleC1wci1tYXN0ZXIKCi0gIklu
dGVsIENvcnBvcmF0aW9uIGhhcyBhY3F1aXJlZCBXaGFtY2xvdWQiOgpodHRwczovL3dlYi5hcmNo
aXZlLm9yZy93ZWIvMjAxMjA3MjQxMDUzMjIvaHR0cDovL3d3dy53aGFtY2xvdWQuY29tL25ld3Mv
aW50ZWwtY29ycG9yYXRpb24taGFzLWFjcXVpcmVkLXdoYW1jbG91ZC8KCi0gIlN0b3JhZ2UgTGVh
ZGVyIERETiBBY3F1aXJlcyBMdXN0cmUgRmlsZSBTeXN0ZW0gQ2FwYWJpbGl0eSBGcm9tIEludGVs
IjoKaHR0cHM6Ly93ZWIuYXJjaGl2ZS5vcmcvd2ViLzIwMjAwODEyMTIzMDMwL2h0dHBzOi8vd3d3
LmRkbi5jb20vcHJlc3MtcmVsZWFzZXMvc3RvcmFnZS1sZWFkZXItZGRuLWFjcXVpcmVzLWx1c3Ry
ZS1maWxlLXN5c3RlbS1jYXBhYmlsaXR5LWludGVsLwoKCkJUVywgdGhlcmUgYXJlIHNvbWUgb2Rk
IGNvcHlyaWdodCBkYXRlcyAoMjAyNiEhISk6CmdpdCBncmVwIC1pICJDb3B5cmlnaHQuKjIwMjYu
KiIKCgpUaGFua3MuCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fCmx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5v
cmcKaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3RyZS1kZXZlbC1sdXN0
cmUub3JnCg==
