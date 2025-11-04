Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A45A6CCF9F8
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 00:04:36 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d0pbl738Fz1y25;
	Mon, 03 Nov 2025 16:04:35 -0800 (PST)
Received: from mail-pf1-f174.google.com (mail-pf1-f174.google.com
 [209.85.210.174])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d0pbj2VWYz1xrs
 for <lustre-devel@lists.lustre.org>; Mon, 03 Nov 2025 16:04:33 -0800 (PST)
Received: by mail-pf1-f174.google.com with SMTP id
 d2e1a72fcca58-781010ff051so4012963b3a.0
 for <lustre-devel@lists.lustre.org>; Mon, 03 Nov 2025 16:04:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1762214672; x=1762819472; darn=lists.lustre.org;
 h=to:references:message-id:cc:date:in-reply-to:from:subject
 :mime-version:content-transfer-encoding:from:to:cc:subject:date
 :message-id:reply-to;
 bh=+CUsFvu8mfaOcIcnNs6xiV+SrPPmWjHrvlO3uJ18M3A=;
 b=Hlag+pCU+512TBKalFDsWgI0BjaRnzOWdSmgVzeCmM4xKeYO0CheaT6uwuCKx9NNDD
 ObLx1gqx+Qq8ULjLOmexI9YnD81aKAlZ65KjyvnxCIejxEHF4LMEYjYGGltxFAWzvmJo
 vJJD3hagHv0tUU8stVjUlNFbVrak8Soufdj/jSCQPKadwEpdzuUKCaGa4rRl7o9mc+fN
 aspPbFsuqjbrt0jnIRKhX7ssVo8TTIyknYrXTkhy4aWC5RCqQct7T326nEbwbxIErFV4
 6SCTPxF0YdZ4dY6m4jjBqjUPsWyoCy/uPgTNa7FhMFGfFNuoPiALx1zzMEuSqfnOPIXy
 Qc1Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762214672; x=1762819472;
 h=to:references:message-id:cc:date:in-reply-to:from:subject
 :mime-version:content-transfer-encoding:x-gm-message-state:from:to
 :cc:subject:date:message-id:reply-to;
 bh=+CUsFvu8mfaOcIcnNs6xiV+SrPPmWjHrvlO3uJ18M3A=;
 b=WKHy9vvPyJef3QT8hGFu4Z8/0ggTsLAEdE0w5knsHgaTzrtOuBo+zuCIYqm1QDIZxF
 T741Auwnbi2xy4TjSjmaMIdyO1oj0QA7REsDlVQN6huUFHm6PKZK4Gb5baaep9rxIEyn
 Vqb46RKi40P8nHWVmKaUqrrsR2QK0gLzvS7Yh2YC7aHPYh/XfvhsmmX47YzjEv4jR1KY
 o2xbXiPXxHez7YU1DgxMh09JOzT8y9IgUrGkh40eWPidg4iwshL7RpLje5C+GR7+Ud3l
 Ox+fHheNRS1TcqoRCd8627X0PFnho82JjqtEeDkxJ6py9X5o+PFHzI+opL4u7mhvWsvf
 gr+w==
X-Forwarded-Encrypted: i=1;
 AJvYcCVcI4w2gXgRxuQPkfhO+5NNpx+v0bpxqex47pR0qa166lLT0ldnQivQwD4eFvB5WcSFJGciHJadhPjiQYA=@lists.lustre.org
X-Gm-Message-State: AOJu0Ywe0mo/N+G8BDtKz4APAci+38PqMfXt2LDyDZD8CJR1h+Qv4Fyh
 rxmr/0DzC60StGM/fl+TQpsFxpLj7U18m3R5RwB2vw+8rvxqSvz5T/kw
X-Gm-Gg: ASbGnctBdSY4tTMQwI/5dx6ScnOZyvZCdU/KnCx7XUBBeftQTl1UpSV+ptb2bdFWT7Y
 Hqz3kZtYCzPFo2ZznLKHU5kPQ8IhScZUZx/RAZNOzq+DMRN7MNBlGSyyjrvR97PqO/KSXeU4Nv5
 bMdZbpZ1wF++yioZTwK6BQnFMpTOF5RhFvXjN+h6EuZcoNCnqcZz7UXZoArnateTj3odpeL37fA
 WY99N5DJyxkvUM0ba5W6ofxWBrvE/meM898pDCN7Eo1vO65Xq/7sCLzLP86XLP8zxqRYe8ifOBf
 CzYaylQ/sU6C1oXTW4zAVpS9GqO2h2rwXju1oVE72jkGYLdkIDNJSdafbFjChhzb20YDx3Rp9bE
 CnryP3dFKAtBc+JKdPWwXgHkNrRjeE6CZc8pXMM7N/gb9Edj2HC+X4m/Stkz+ENjynYWAZBX9+N
 7BhO8M1GAaVJyB7LaHyly3LuTZwKkQS7+lljO8uC7Gs7tCZ/VoXfS7M9nNI7lKsMAdvxiZlMw81
 vBRvl2jGR8=
X-Google-Smtp-Source: AGHT+IEQ67p4sHAermlBdeGJfEkMUKc17VYfnJ3OWcpZrhFWKqUmw1tfgY1U2auL31Mc6PVsoVO33A==
X-Received: by 2002:a17:902:d48d:b0:290:b928:cf3d with SMTP id
 d9443c01a7336-2951a53a791mr197524995ad.59.1762214672443; 
 Mon, 03 Nov 2025 16:04:32 -0800 (PST)
Received: from smtpclient.apple ([2a00:79e1:2e01:1:ad8f:b736:cce2:a3d1])
 by smtp.gmail.com with ESMTPSA id
 d9443c01a7336-29601a547bcsm3780055ad.81.2025.11.03.16.04.26
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Mon, 03 Nov 2025 16:04:26 -0800 (PST)
Mime-Version: 1.0 (1.0)
In-Reply-To: <e2c69a503e80f3ba59d69f093bc8df519cdd7f66.camel@whamcloud.com>
Date: Mon, 3 Nov 2025 16:04:15 -0800
Message-Id: <BFDDAAED-BA9A-44DB-BCD0-B3B84E652FE7@gmail.com>
References: <e2c69a503e80f3ba59d69f093bc8df519cdd7f66.camel@whamcloud.com>
To: Oleg Drokin <green@whamcloud.com>
X-Mailer: iPhone Mail (23A355)
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
Cc: lustre-devel@lists.lustre.org
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Cgo+IE9uIE5vdiAzLCAyMDI1LCBhdCAxNToxNCwgT2xlZyBEcm9raW4gPGdyZWVuQHdoYW1jbG91
ZC5jb20+IHdyb3RlOgo+IAo+IO+7v09uIE1vbiwgMjAyNS0xMS0wMyBhdCAyMTo1OSArMDAwMCwg
RGF5LCBUaW1vdGh5IHZpYSBsdXN0cmUtZGV2ZWwgd3JvdGU6Cj4+IAo+PiAKPj4gVGhpcyBiZWdz
IHRoZSBxdWVzdGlvbjogaWYgd2UncmUgYWxyZWFkeSBkb2luZyB0aGlzIHdvcmsgdG8gc3VwcG9y
dAo+PiB3cml0aW5nIEx1c3RyZSBvYmplY3RzIHRvIGFueSBhcmJpdHJhcnkgZmlsZXN5c3RlbSB2
aWEgVkZTIGFuZCB3ZSdyZQo+PiBvbmx5Cj4+IGludGVuZGluZyB0byBzdXBwb3J0IE9TVHMgd2l0
aCB0aGlzIHByb3Bvc2FsLCB3aHkgbm90IGltcGxlbWVudAo+PiBhbiBPU1Qtb25seSBWRlMgT1NE
IGFuZCBoYW5kbGUgdGllcmluZyBpbiB0aGUgZmlsZXN5c3RlbSBsYXllcj8KPiAKPiBUaGUgcHJv
YmxlbSB3aXRoIHB1cmUgVkZTIGlzIGl0IGRvZXMgbm90IGFjdHVhbGx5IHByb3ZpZGUgdXMgd2hh
dCB3ZQo+IHdhbnQuCj4gU28gT1NEIHRhbGtzIHRvIHRoZSB1bmRlcmx5aW5nIEZTIHZpYSBWRlMg
KyBzb21lIG1vcmUgc3R1ZmYgKHdlIGRvIGhhdmUKPiB0aGUgaGlkZGVuIG1vdW50IGZvciBsZGlz
a2ZzIGFmdGVyIGFsbCkuCj4gVGhlICJtb3JlIHN0dWZmIiBpcyB0aGluZ3MgbGlrZSBleHBhbmRl
ZCB0cmFuc2FjdGlvbiBib3VuZGFyaWVzIGJleW9uZAo+IHdoYXQgcG9zaXggcmVxdWlyZXMgc28g
d2UgY2FuIHVwZGF0ZSBtb3JlIHRoYW4gb25lIHRoaW5nLgo+IElmIExpbnV4IFZGUyBwcm92aWRl
ZCBhbGwgdGhlc2UgYWJpbGl0aWVzIHdlIHdvdWxkIG5vdCBuZWVkIHRvIHJlYWxseQo+IGtub3cg
bXVjaCBhYm91dCB0aGUgdW5kZXJseWluZyBkaXNrIGZzIEkgc3VzcGVjdC4KPiAKPiBCdXQgY3Vy
cmVudGx5IGl0J3MganVzdCBhIHdheSB0byBhZGQgT1NUcywgbm90IG1vdmUgb2JqZWN0cyBsYXRl
cmFsbHkKPiBmcm9tIG9uZSBPU1QgdG8gYW5vdGhlciBhbmQgaGVuY2UgdGhpcyBwcm9wb3NhbCBJ
IGltYWdpbmUgLSB3aGVyZSBPU1RzCj4gd291bGQgZ3JvdyAid2FydHMiIGZvciBsZXNzIHdhbnRl
ZCBkYXRhLgo+IAo+IEkgYW0gbm90IHN1cmUgaXQncyBhIG11Y2ggYmV0dGVyIGlkZWEgdGhhbiB0
aGUgYWxyZWFkeSBleGlzdGluZyBIU00KPiBjYXBhYmlsaXRpZXMgd2UgaGF2ZSB0aGF0IHdvdWxk
IGFsbG93IHlvdSB0byBoYXZlICJvZmZsaW5lIiBvYmplY3RzCj4gdGhhdCB3b3VsZCBiZSBwdWxs
ZWQgYmFjayBpbiB3aGVuIHVzZWQsIGJ1dCBhcmUgb3RoZXJ3aXNlIGp1c3QgdmlzaWJsZQo+IGlu
IHRoZSBtZXRhZGF0YSBvbmx5Lgo+IFRoZSB1bmRlcmx5aW5nIGNhcGFiaWxpdGllcyBhcmUgcHJl
dHR5IHJpY2ggZXNwLiBpZiB3ZSBhbHNvIHRha2UgaW50bwo+IGFjY291bnQgdGhlIGV2ZW50dWFs
IFdCQyBzdHVmZi4KClRoZSBtYWpvciBwcm9ibGVtIG9mIGN1cnJlbnQgSFNNIGlzIHRoYXQgaXQg
aGFzIHRvIGhhdmUgZGVkaWNhdGVkIGNsaWVudHMgdG8gbW92ZSBkYXRhLiBBbHNvLCBzY2Fubmlu
ZyB0aGUgZW50aXJlIEx1c3RyZSBmaWxlIHN5c3RlbSB0YWtlcyB2ZXJ5IGxvbmcgdGltZSBzbyBp
dCByZXNvcnRzIHRvIGRhdGFiYXNlcyBpbiBvcmRlciB0byBtYWtlIGNvcnJlY3QgZGVjaXNpb25z
IGFib3V0IHdoaWNoIGZpbGUgc2hvdWxkIGJlIHJlbGVhc2VkLiBCeSB0aGUgdGltZSwgdGhlIHR3
byBzeXN0ZW0gd2lsbCBiZSBvdXQgb2Ygc3luYy4gVGhhdCBtYWtlcyBpdCBwcmFjdGljYWxseSB1
bnVzYWJsZS4KCj4gCj4gSWYgdGhlIGFyZ3VtZW50IGlzICJidXQgT1NUcyBrbm93IGJlc3Qgd2hh
dCBzdHVmZiBpcyB1c2VkIiAod2hpY2ggSSBhbQo+IG5vdCBzdXJlIEkgYnV5LCBhZnRlciBhbGwg
YmVmb3JlIHlvdSBjb3VsZCB1c2Ugc29tZXRoaW5nIG9mZiBPU1RzIHlvdQo+IG5lZWQgdG8gb3Bl
biBhIGZpbGUgSSB3b3VsZCBob3BlKSBldmVuIHRoZW4gT1NUcyBjb3VsZCBqdXN0IHNpZ25hbCBh
Cj4gbGlzdCBvZiAiaW5hY3RpdmUgb2JqZWN0cyIgdGhhdCB0aGVuIGEgaGlnaGVyIGxldmVsIHN5
c3RlbSB3b3VsZCB0YWtlCj4gY2FyZSBvZiBieSByZWxvY2F0aWluZyBzb21ld2hlcmUgbW9yZSBz
ZW5zaWNhbCBhbmQgY2hhbmdpbmcgdGhlIGxheW91dAo+IHRvIGluZGljYXRlIHRob3NlIG9iamVj
dHMgbm93IGxpdmUgZWxzZXdoZXJlLgo+IAo+IFRoZSBwbHVzIGhlcmUgaXMgeW91IGRvbid0IG5l
ZWQgdG8gYXR0YWNoIHRoaXMgIldhcnQiIHRvIGV2ZXJ5IE9TVCBhbmQKPiBjb25maWd1cmUgaXQg
ZXZlcnl3aGVyZSBhbmQgc3VjaCwgYnV0IHJhdGhlciBoYXZlIGEgY2VudHJhbCBsb2NhdGlvbgo+
IHRoYXQgaXMgY2VudHJhbGx5IG1hbmFnZWQuCj4gCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCmx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRl
dmVsQGxpc3RzLmx1c3RyZS5vcmcKaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dp
L2x1c3RyZS1kZXZlbC1sdXN0cmUub3JnCg==
