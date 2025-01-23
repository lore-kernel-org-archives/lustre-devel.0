Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 50B01C02182
	for <lustre-devel@archiver.kernel.org>; Thu, 23 Jan 2025 09:01:14 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ydvzw3fcFz1xNx;
	Thu, 23 Jan 2025 01:00:44 -0800 (PST)
Received: from mail-wm1-f42.google.com (mail-wm1-f42.google.com
 [209.85.128.42])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ydvzm70hCz1wPx
 for <lustre-devel@lists.lustre.org>; Thu, 23 Jan 2025 01:00:36 -0800 (PST)
Received: by mail-wm1-f42.google.com with SMTP id
 5b1f17b1804b1-43625c4a50dso4016015e9.0
 for <lustre-devel@lists.lustre.org>; Thu, 23 Jan 2025 01:00:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1737622834; x=1738227634; darn=lists.lustre.org;
 h=to:references:message-id:content-transfer-encoding:cc:date
 :in-reply-to:from:subject:mime-version:from:to:cc:subject:date
 :message-id:reply-to;
 bh=FSvXsP7hApnMQBdmmKzwtD2UmzmUgRzdj1DCmywpnP4=;
 b=Aoi2ElY2bJ8PLAo+ZPaBbkYpY+uwKLVUWp9k7hQWrb/DHN5UnkHGNdSOgtfF2QEZVB
 I3C0rqHzSTRgDH01XerDrQYDNtXcO7x1BIVSXdDIwhlu+qfVW4zlMkzdg5Y/0eKL1A/N
 kHoHiEZUnruDZPmQleD5No9BUk6aLhr5+hq39hax3Fne+WoZiqXwwzJlY3AIMZGb7qTk
 gDHn3UGe3xl2j1SgsszWCxkN3tXdvtoTFQgvziH9p4tedyhvIQiuj6y+jAH/48836cj9
 WDYtxMBLthTo8nF3JO9KJUBBEAG/qZssAD7mSZrg0ZTWgLJUnMiRvMdAbZaryX18qsKk
 kFyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1737622834; x=1738227634;
 h=to:references:message-id:content-transfer-encoding:cc:date
 :in-reply-to:from:subject:mime-version:x-gm-message-state:from:to:cc
 :subject:date:message-id:reply-to;
 bh=FSvXsP7hApnMQBdmmKzwtD2UmzmUgRzdj1DCmywpnP4=;
 b=sqCx4MwnV1r291NbLy2JBWxGvzKj3aMlLKBiH0vf/iCJcxLNEnFKzvLfOGMh09lriR
 m0tAia/5ycFRmwMAePF8hWTTJw2u48KuwovoLHxQo6cc8RhxkBVNPJMrcu1wCPrMW8hy
 4ekJErzy70yZ48e4XFFOLRXzQJSLzt9PqhB1IteNDrFBmtFJqOVvIXKDa7laiaAHR0wL
 HSHFfI/JvoTODNrCdrCOtB3fF4r4Li+g5JxyUrigXkKAbnrPT3cUt7YMjbAKisTtnFva
 AfycqT/TxG0wUHAEqm2e/g/KsHFaXzHDKDOJNhpt5SoHiY7V7A/+9rC/6UTG4kawNidU
 1MYA==
X-Forwarded-Encrypted: i=1;
 AJvYcCUheHfqerFvRchvNkUFh8tv+icm0Eavac+NMXDSg2hW1ooIT8uZI1BRlfS0ETBzuwEQQ/l9I2KwxaA/yUo=@lists.lustre.org
X-Gm-Message-State: AOJu0YzSqp26IEzkMVkxIcg05Qmy/i1W1Dcz/nz8CS6Rf/tO3UXwlPJa
 g3HrnhSzvn8JZQASLEorik9a/mKuv8qU1doeLWYHG+QegzXqm9jm
X-Gm-Gg: ASbGncvay4RZsBxIFQ/3wxRMoZvXPvNfPMUDCtlMmC2ui6mfiO426lyjI0Nz90Hniks
 GkBXD91ZXm9u7a4NY3fs3SuLACPCkK1wwYGPTJw2+hS588h2xUjHlBXS4RWQKA9P9yF26vX4s0p
 uIR0E6y3lahlKskxDnUePQykNEPyH9KO19E66IAnGgV+z+C+u1FDUQaApJjR+AOJ3M7RNhJ4J0Y
 1pI49teXV/tDWQIngudzGu5IRPOX0D36jsqCDEXAqrcgZxMGiO7ZRWSYLhAiemKpNtnGdkgAnwn
 Rwhsyo1cmagVEYFyLUob8aAoUos=
X-Google-Smtp-Source: AGHT+IEJkCAIrvJ4o3DAUa50wE7fd1x5WfKn27T7Ym9SxidiSPwz4nvALImW7Ek3Mn+gqEMhz89ycA==
X-Received: by 2002:a7b:c00f:0:b0:434:f5c0:32b1 with SMTP id
 5b1f17b1804b1-4389eecb1f5mr215246935e9.15.1737622834274; 
 Thu, 23 Jan 2025 01:00:34 -0800 (PST)
Received: from smtpclient.apple ([178.19.96.90])
 by smtp.gmail.com with ESMTPSA id
 5b1f17b1804b1-438b31de036sm53860365e9.33.2025.01.23.01.00.31
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Thu, 23 Jan 2025 01:00:33 -0800 (PST)
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3776.700.51.11.1\))
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
In-Reply-To: <F0CBB79F-37D7-4786-979D-70B34EEACA81@amazon.com>
Date: Thu, 23 Jan 2025 12:00:19 +0300
Message-Id: <381E2DB4-0766-41F0-821E-32C3C724B2FA@gmail.com>
References: <3139EEF5-91BF-4F8E-A112-1D66455AE3D2@amazon.com>
 <173716111777.22054.8452560203667698532@noble.neil.brown.name>
 <785a407c987a57ddf6bbfbed05230981af66cd26.camel@whamcloud.com>
 <A2A33C79-3467-4E93-952D-9646346E0349@amazon.com>
 <e5dea863089af0d377beb7f5d9c5d735d192bd94.camel@whamcloud.com>
 <F0CBB79F-37D7-4786-979D-70B34EEACA81@amazon.com>
To: "Day, Timothy" <timday@amazon.com>
X-Mailer: Apple Mail (2.3776.700.51.11.1)
Subject: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Cgo+IDIwINGP0L3Qsi4gMjAyNeKAr9CzLiwg0LIgMDc6MzgsIERheSwgVGltb3RoeSA8dGltZGF5
QGFtYXpvbi5jb20+INC90LDQv9C40YHQsNC7KNCwKToKPiAKPiAKPiAKPiDvu78+IE9uIDEvMTkv
MjUsIDM6NDYgUE0sICJPbGVnIERyb2tpbiIgPGdyZWVuQHdoYW1jbG91ZC5jb20gPG1haWx0bzpn
cmVlbkB3aGFtY2xvdWQuY29tPj4gd3JvdGU6Cj4+PiBPbiBTYXQsIDIwMjUtMDEtMTggYXQgMjE6
NDYgKzAwMDAsIERheSwgVGltb3RoeSB3cm90ZToKPj4+IAo+Pj4gCj4+Pj4gT24gMS8xNy8yNSwg
MTA6MTcgUE0sICJPbGVnIERyb2tpbiIKPj4+PiA8Z3JlZW5Ad2hhbWNsb3VkLmNvbSA8bWFpbHRv
OmdyZWVuQHdoYW1jbG91ZC5jb20+IDxtYWlsdG86Z3JlZW5Ad2hhbWNsb3VkLmNvbSA8bWFpbHRv
OmdyZWVuQHdoYW1jbG91ZC5jb20+Pj4gd3JvdGU6Cj4+Pj4+IE9uIFNhdCwgMjAyNS0wMS0xOCBh
dCAxMTo0NSArMTEwMCwgTmVpbEJyb3duIHdyb3RlOgo+Pj4+PiBXZSBuZWVkIHRvIGRlbW9uc3Ry
YXRlIGEgcHJvY2VzcyBmb3IsIGFuZCBjb21taXRtZW50IHRvLCBtb3ZpbmcKPj4+Pj4gYXdheQo+
Pj4+PiBmcm9tIHRoZSBkdWFsLXRyZWUgbW9kZWwuIFdlIG5lZWQgcGF0Y2hlcyB0byB0aG9zZSBw
YXJ0cyBvZgo+Pj4+PiBMdXN0cmUKPj4+Pj4gdGhhdCBhcmUgdXBzdHJlYW0gdG8gbGFuZCBpbiB1
cHN0cmVhbSBmaXJzdCAobW9zdGx5KS4KPj4+PiAKPj4+PiAKPj4+PiBJIHRoaW5rIHRoaXMgaXMg
bm90IHZlcnkgcmVhbGlzdGljLgo+Pj4+IExhcmdlIGNodW5rICgxMDAlPykgb2YgdXNlcnMgZG8g
bm90IHJ1biBub3Qgb25seSB0aGUgbGF0ZXN0IGtlcm5lbAo+Pj4+IHJlbGVhc2UsIHRoZXkgZG9u
J3QgcnVuIHRoZSBsYXRlc3QgTFRTIGVpdGhlci4KPj4+PiAKPj4+PiAKPj4+PiBXaGVuIHdlIHdl
cmUgaW4gc3RhZ2luZyBsYXN0IHRoaXMgbWFuaWZlc3RlZCBpbiByYW5kb20gcGF0Y2hlcwo+Pj4+
IGJlaW5nCj4+Pj4gbGFuZGVkIGFuZCBicmVha2luZyB0aGUgY2xpZW50IGNvbXBsZXRlbHkgYW5k
IG5vYm9keSBub3RpY2luZyBmb3IKPj4+PiBtb250aHMuCj4+Pj4gCj4+Pj4gCj4+Pj4gT2YgY291
cnNlIHNvbWUgYXV0b21hdGljIGluZnJhc3RydWN0dXJlIGNvdWxkIGJlIGJ1aWx0IHVwIHRvIG1h
a2UKPj4+PiBpdAo+Pj4+IHNvbWV3aGF0IGJldHRlciwgYnV0IGl0IGRvZXMgbm90IHJlbW92ZSB0
aGUgcHJvYmxlbSBvZiAibm9ib2R5Cj4+Pj4gd291bGQKPj4+PiBydW4gdGhpcyBtYWlubGluZSB0
cmVlIiwgSSBhbSBhZnJhaWQuCj4+PiAKPj4+IEkgdGhpbmsgdGhlcmUncyBhIGRlY2VudCBjaHVu
ayBvZiB1c2VycyBvbiBuZXdlciBrZXJuZWxzLiBVYnVudHUKPj4+IDIyLzI0IGlzCj4+PiBvbiAo
YSBiaXQgcGFzdCBsYXRlc3QpIExUUyA2Ljgga2VybmVsIFsxXSwgQUwyMDIzIGlzIG9uIHByZXZp
b3VzIExUUwo+Pj4gNi4xIFsyXSwgYW5kCj4+PiB3b3JraW5nIG9uIHVwY29taW5nIExUUyA2LjEy
IFszXS4KPj4gCj4+IAo+PiBXZWxsLCBJIG1vc3RseSBtZWFuIGluIGNvbnRleHQgb2YgTHVzdHJl
IGNsaWVudCB1c2UgYW5kIHN1cmUgdGhlcmUncwo+PiBzb21lIDYuOCBMVFMgaW4gdXNlIG9uIHRo
b3NlIHVidW50dSBjbGllbnRzLCB0aG91Z2ggSSBjYW5ub3QgYXNzZXNzIHRoZQo+PiByZWFsIG51
bWJlcnMsIG1ham9yaXR5IG9mIHJlcG9ydHMgSSBzZWUgYXJlIHN0aWxsIG9uIDUueCBldmVuIG9u
Cj4+IFVidW50dS4KPiAKPiBZZWFoLCBJJ20gbm90IHN1cmUgb2YgdGhlIHJlYWwgbnVtYmVycy4g
SXQncyBqdXN0IG15IHBlcnNvbmFsIGV4cGVyaWVuY2UKPiB0aGF0IG5ld2VyIGtlcm5lbHMgYXJl
IGdldHRpbmcgYSBsb3Qgb2YgdHJhY3Rpb24uCgoKaHR0cHM6Ly93d3cuZW9mcy5ldS93cC1jb250
ZW50L3VwbG9hZHMvMjAyNC8wMi8xLjEtY29tbXVuaXR5X3JlbGVhc2VfdXBkYXRlLnBkZgoKaHR0
cHM6Ly93aWtpLm9wZW5zZnMub3JnL2ltYWdlcy8xLzFkL09wZW5TRlNfU3VydmV5X1Jlc3VsdHNf
TWFyY2hfMjAyNC5wZGYKCkFuZCBzaW1pbGFyIHByZXNlbnRhdGlvbnMgZnJvbSBMQUQvTFVHLgoK
CkFsZXgKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbHVz
dHJlLWRldmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpodHRw
Oi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcK
